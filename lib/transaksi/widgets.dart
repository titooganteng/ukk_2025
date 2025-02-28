// lib/widgets/produk_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model.dart';

class ProdukList extends StatelessWidget {
  final List<Produk> produkList;
  final Function(Produk) onAddToCart;
  final Function(String) onSearch;
  
  const ProdukList({
    super.key,
    required this.produkList,
    required this.onAddToCart,
    required this.onSearch,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari Produk',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearch,
            ),
          ),
          Expanded(
            child: produkList.isEmpty
                ? const Center(child: Text('Tidak ada produk yang ditemukan'))
                : ListView.builder(
                    itemCount: produkList.length,
                    itemBuilder: (context, index) {
                      final produk = produkList[index];
                      return ListTile(
                        title: Text(produk.namaproduk),
                        subtitle: Text(
                          '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(produk.harga)} - Stok: ${produk.stok}',
                        ),
                        trailing: produk.stok > 0
                            ? IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () => onAddToCart(produk),
                              )
                            : const Chip(
                                label: Text('Habis'),
                                backgroundColor: Colors.red,
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PelangganDropdown extends StatelessWidget {
  final List<Pelanggan> pelangganList;
  final Pelanggan? selectedPelanggan;
  final Function(Pelanggan?) onChanged;
  
  const PelangganDropdown({
    super.key,
    required this.pelangganList,
    required this.selectedPelanggan,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Pelanggan>(
      decoration: const InputDecoration(
        labelText: 'Pilih Pelanggan',
        border: OutlineInputBorder(),
      ),
      hint: const Text('Pilih Pelanggan'),
      value: selectedPelanggan,
      items: pelangganList.map((pelanggan) {
        return DropdownMenuItem<Pelanggan>(
          value: pelanggan,
          child: Text(pelanggan.namapelanggan),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class KeranjangWidget extends StatelessWidget {
  final List<KeranjangItem> keranjang;
  final Function(int) onRemoveItem;
  final Function(int) onDecreaseQuantity;
  
  const KeranjangWidget({
    super.key,
    required this.keranjang,
    required this.onRemoveItem,
    required this.onDecreaseQuantity,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Keranjang',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Expanded(
          child: keranjang.isEmpty
              ? const Center(
                  child: Text('Keranjang kosong'),
                )
              : ListView.builder(
                  itemCount: keranjang.length,
                  itemBuilder: (context, index) {
                    final item = keranjang[index];
                    return ListTile(
                      title: Text(item.namaproduk),
                      subtitle: Text(
                        '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.harga)} x ${item.jumlahproduk}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => onDecreaseQuantity(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => onRemoveItem(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class StrukDialog extends StatelessWidget {
  final List<KeranjangItem> keranjang;
  final Pelanggan pelanggan;
  final double totalHarga;
  final bool showActions;
  final VoidCallback? onSubmit;

  const StrukDialog({
    super.key,
    required this.keranjang,
    required this.pelanggan,
    required this.totalHarga,
    this.showActions = true, // Default: true (hanya untuk transaksi baru)
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final tanggal = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return AlertDialog(
      title: const Text('Struk Transaksi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: $tanggal'),
            Text('Pelanggan: ${pelanggan.namapelanggan}'),
            const Divider(),
            const Text('Item:'),
            ...keranjang.map((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${item.namaproduk} (${item.jumlahproduk}x) - ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.subtotal)}',
                ),
              );
            }),
            const Divider(),
            Text('Total: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalHarga)}'),
          ],
        ),
      ),
      actions: showActions
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onSubmit != null) {
                    onSubmit!();
                  }
                },
                child: const Text('Submit'),
              ),
            ]
          : null, // Tidak ada tombol jika showActions = false
    );
  }
}
