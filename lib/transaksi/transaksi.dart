// lib/screens/transaksi_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'controller.dart';
import 'widgets.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final _transaksiService = TransaksiService();

  List<Produk> _produkList = [];
  List<Pelanggan> _pelangganList = [];
  List<KeranjangItem> _keranjang = [];

  Pelanggan? _selectedPelanggan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final produkData = await _transaksiService.getProdukList();
      final pelangganData = await _transaksiService.getPelangganList();

      setState(() {
        _produkList = produkData;
        _pelangganList = pelangganData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _tambahKeKeranjang(Produk produk) {
    setState(() {
      final index =
          _keranjang.indexWhere((item) => item.produkID == produk.produkID);

      if (index >= 0) {
        _keranjang[index].tambahJumlah();
      } else {
        _keranjang.add(KeranjangItem.fromProduk(produk));
      }
    });
  }

  void _kurangDariKeranjang(int index) {
    setState(() {
      if (_keranjang[index].jumlahproduk > 1) {
        _keranjang[index].kurangJumlah();
      } else {
        _keranjang.removeAt(index);
      }
    });
  }

  void _hapusDariKeranjang(int index) {
    setState(() {
      _keranjang.removeAt(index);
    });
  }

  double _hitungTotal() {
    return _keranjang.fold(0, (sum, item) => sum + item.subtotal);
  }

  void _onPelangganSelected(Pelanggan? pelanggan) {
    setState(() {
      _selectedPelanggan = pelanggan;
    });
  }

  void _cariProduk(String keyword) async {
    if (keyword.isEmpty) {
      await _loadData();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _transaksiService.cariProduk(keyword);
      setState(() {
        _produkList = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _prosesPembayaran() async {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong!')),
      );
      return;
    }

    if (_selectedPelanggan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pelanggan terlebih dahulu!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StrukDialog(
        keranjang: _keranjang,
        pelanggan: _selectedPelanggan!,
        totalHarga: _hitungTotal(),
        onSubmit: () => _submitTransaksi(_hitungTotal()),
      ),
    );
  }

  Future<void> _submitTransaksi(double totalHarga) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _transaksiService.submitTransaksi(
        _selectedPelanggan!,
        _keranjang,
        totalHarga,
      );

      setState(() {
        _keranjang = [];
        _selectedPelanggan = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Baru'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel kiri: Produk
                Expanded(
                  flex: 3,
                  child: ProdukList(
                    produkList: _produkList,
                    onAddToCart: _tambahKeKeranjang,
                    onSearch: _cariProduk,
                  ),
                ),

                // Panel kanan: Keranjang & Pelanggan
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Pelanggan
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PelangganDropdown(
                            pelangganList: _pelangganList,
                            selectedPelanggan: _selectedPelanggan,
                            onChanged: _onPelangganSelected,
                          ),
                        ),

                        // Keranjang
                        Expanded(
                          child: KeranjangWidget(
                            keranjang: _keranjang,
                            onRemoveItem: _hapusDariKeranjang,
                            onDecreaseQuantity: _kurangDariKeranjang,
                          ),
                        ),

                        // Total & Checkout
                        _buildCheckoutPanel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCheckoutPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(_hitungTotal()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Proses Transaksi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _prosesPembayaran,
            ),
          ),
        ],
      ),
    );
  }
}
