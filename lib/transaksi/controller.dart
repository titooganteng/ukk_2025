import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model.dart';

class TransaksiService {
  final _supabase = Supabase.instance.client;

  Future<List<Produk>> getProdukList() async {
    final response = await _supabase
        .from('produk')
        .select('produkID, namaproduk, harga, stok')
        .order('namaproduk', ascending: true);

    return (response as List).map((data) => Produk.fromJson(data)).toList();
  }

  Future<List<Pelanggan>> getPelangganList() async {
    final response = await _supabase
        .from('pelanggan')
        .select('pelangganID, namapelanggan')
        .order('namapelanggan', ascending: true);

    return (response as List).map((data) => Pelanggan.fromJson(data)).toList();
  }

  Future<List<Produk>> cariProduk(String keyword) async {
    final response = await _supabase
        .from('produk')
        .select('produkID, namaproduk, harga, stok')
        .ilike('namaproduk', '%$keyword%')
        .order('namaproduk', ascending: true);

    return (response as List).map((data) => Produk.fromJson(data)).toList();
  }

  Future<void> submitTransaksi(
    Pelanggan pelanggan,
    List<KeranjangItem> keranjang,
    double totalHarga,
  ) async {
    // 1. Insert data penjualan
    final penjualanResult = await _supabase
        .from('penjualan')
        .insert({
          'totalharga': totalHarga,
          'pelangganID': pelanggan.pelangganID,
          'tanggalpenjualan': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final String penjualanID = penjualanResult['penjualanID'];

    // 2. Insert detail penjualan
    final detailData = keranjang
        .map((item) => {
              'penjualanID': penjualanID,
              'produkID': item.produkID,
              'jumlahproduk': item.jumlahproduk,
              'subtotal': item.subtotal,
            })
        .toList();

    await _supabase.from('detailpenjualan').insert(detailData);

    // 3. Update stok produk
    for (var item in keranjang) {
      final produkResponse = await _supabase
          .from('produk')
          .select('stok')
          .eq('produkID', item.produkID)
          .single();

      final int currentStok = produkResponse['stok'] ?? 0;
      final int newStok = currentStok - item.jumlahproduk;

      await _supabase
          .from('produk')
          .update({'stok': newStok}).eq('produkID', item.produkID);
    }
  }

  Future<List<Transaksi>> getRiwayatTransaksi() async {
    final response = await _supabase.from('penjualan').select('''
          penjualanID, 
          totalharga, 
          tanggalpenjualan, 
          pelanggan:pelangganID(namapelanggan)
        ''').order('tanggalpenjualan', ascending: false);
    debugPrint('list penjualan: $response');
    if (response == null) {
      return [];
    }

    return response.map<Transaksi>((data) => Transaksi.fromJson(data)).toList();
  }

  Future<List<KeranjangItem>> getDetailTransaksi(String penjualanID) async {
    final response = await _supabase.from('detailpenjualan').select('''
        produk(produkID, namaproduk, harga), jumlahproduk, subtotal
      ''').eq('penjualanID', penjualanID);
    debugPrint('detail: $response');

    if (response.isEmpty) {
      return [];
    }

    return response
        .map((item) => KeranjangItem(
              produkID: item['produk']['produkID'] ?? '',
              namaproduk:
                  item['produk']['namaproduk'] ?? 'Produk Tidak Diketahui',
              jumlahproduk: item['jumlahproduk'] ?? 0,
              harga: (item['produk']['harga'] as num?)?.toDouble() ?? 0,
            ))
        .toList();
  }
}
