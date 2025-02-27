import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukController {
  final _supabase = Supabase.instance.client;
  
  // Mendapatkan semua data produk
  Future<List<Map<String, dynamic>>> getAllProduk() async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .order('namaproduk', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat data produk: $e');
    }
  }
  
  // Mendapatkan produk berdasarkan ID
  Future<Map<String, dynamic>?> getProdukById(String produkID) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .eq('produkID', produkID)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data produk: $e');
    }
  }
  
  // Menambahkan produk baru
  Future<void> addProduk(String namaproduk, double harga, int stok) async {
    try {
      // Produk ID otomatis dibuat dengan UUID
      await _supabase.from('produk').insert({
        'namaproduk': namaproduk,
        'harga': harga,
        'stok': stok,
      });
    } catch (e) {
      throw Exception('Gagal menambahkan produk: $e');
    }
  }
  
  // Mengupdate produk
  Future<void> updateProduk(String produkID, String namaproduk, double harga, int stok) async {
    try {
      await _supabase.from('produk').update({
        'namaproduk': namaproduk,
        'harga': harga,
        'stok': stok,
      }).eq('produkID', produkID);
    } catch (e) {
      throw Exception('Gagal mengupdate produk: $e');
    }
  }
  
  // Menghapus produk
  Future<void> deleteProduk(String produkID) async {
    try {
      await _supabase.from('produk').delete().eq('produkID', produkID);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}