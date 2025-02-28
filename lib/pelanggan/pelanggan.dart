import 'package:flutter/material.dart';
import 'controller.dart';
import 'form_dialog.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final PelangganController _controller = PelangganController();
  List<Map<String, dynamic>> _pelangganList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPelanggan();
  }

  Future<void> _loadPelanggan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final pelanggan = await _controller.getAllPelanggan();
      setState(() {
        _pelangganList = pelanggan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => PelangganFormDialog(
        controller: _controller,
        onSuccess: _loadPelanggan,
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> pelanggan) {
    showDialog(
      context: context,
      builder: (context) => PelangganFormDialog(
        controller: _controller,
        pelanggan: pelanggan,
        onSuccess: _loadPelanggan,
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> pelanggan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pelanggan "${pelanggan['namapelanggan']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _controller.deletePelanggan(pelanggan['pelangganID']);
        _loadPelanggan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pelanggan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus pelanggan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Pelanggan',
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPelanggan,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_pelangganList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pelanggan',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pelanggan'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPelanggan,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _pelangganList.length,
          itemBuilder: (context, index) {
            final pelanggan = _pelangganList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  pelanggan['namapelanggan'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alamat: ${pelanggan['alamat']}'),
                    Text('Telepon: ${pelanggan['nomortelepon']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(pelanggan),
                      tooltip: 'Edit Pelanggan',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(pelanggan),
                      tooltip: 'Hapus Pelanggan',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
