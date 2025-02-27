import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller.dart';

class ProdukFormDialog extends StatefulWidget {
  final ProdukController controller;
  final Map<String, dynamic>? produk; // null jika ini adalah form tambah baru
  final Function onSuccess;
  
  const ProdukFormDialog({
    super.key, 
    required this.controller, 
    this.produk, 
    required this.onSuccess,
  });

  @override
  _ProdukFormDialogState createState() => _ProdukFormDialogState();
}

class _ProdukFormDialogState extends State<ProdukFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data produk jika ini form edit
    _namaController = TextEditingController(text: widget.produk?['namaproduk'] ?? '');
    _hargaController = TextEditingController(
      text: widget.produk != null ? widget.produk!['harga'].toString() : '',
    );
    _stokController = TextEditingController(
      text: widget.produk != null ? widget.produk!['stok'].toString() : '',
    );
  }
  
  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }
  
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        if (widget.produk == null) {
          // Tambah produk baru
          await widget.controller.addProduk(
            _namaController.text,
            double.parse(_hargaController.text),
            int.parse(_stokController.text),
          );
        } else {
          // Update produk yang ada
          await widget.controller.updateProduk(
            widget.produk!['produkID'],
            _namaController.text,
            double.parse(_hargaController.text),
            int.parse(_stokController.text),
          );
        }
        
        if (mounted) {
          widget.onSuccess();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.produk == null ? 'Tambah Produk' : 'Edit Produk'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Stok harus berupa angka';
                  }
                  if (int.parse(value) < 0) {
                    return 'Stok tidak boleh negatif';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.produk == null ? 'Simpan' : 'Update'),
        ),
      ],
    );
  }
}