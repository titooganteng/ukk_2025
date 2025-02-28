import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'controller.dart';
import 'model.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final TransaksiService _transaksiService = TransaksiService();

  Future<List<Transaksi>> _fetchRiwayatTransaksi() async {
    return await _transaksiService.getRiwayatTransaksi();
  }

void showStrukDialog(BuildContext context, Transaksi transaksi) async {
  final transaksiService = TransaksiService();
  final keranjang = await transaksiService.getDetailTransaksi(transaksi.penjualanID);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Detail Transaksi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(transaksi.tanggalpenjualan)}'),
              Text('Pelanggan: ${transaksi.namapelanggan}'),
              const Divider(),
              const Text('Item:'),
              ...keranjang.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${item.namaproduk} (${item.jumlahproduk}x) - ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.subtotal)}',
                ),
              )),
              const Divider(),
              Text(
                'Total: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transaksi.totalharga)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: FutureBuilder<List<Transaksi>>(
        future: _fetchRiwayatTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada transaksi."));
          }

          List<Transaksi> transaksiList = snapshot.data!;

          return ListView.builder(
            itemCount: transaksiList.length,
            itemBuilder: (context, index) {
              final transaksi = transaksiList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        DateFormat('dd/MM/yyyy HH:mm').format(transaksi.tanggalpenjualan),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
      ),
      const SizedBox(height: 4),
      Text(
        transaksi.namapelanggan,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        "Rp ${transaksi.totalharga.toStringAsFixed(0)}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    ],
  ),
  trailing: const Icon(Icons.receipt_long),
  onTap: () => showStrukDialog(context, transaksi),
),

              );
            },
          );
        },
      ),
    );
  }
}
