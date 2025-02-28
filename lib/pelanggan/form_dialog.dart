import 'package:flutter/material.dart';
import 'controller.dart';

class PelangganFormDialog extends StatefulWidget {
  final PelangganController controller;
  final Map<String, dynamic>? pelanggan;
  final Function onSuccess;
  
  const PelangganFormDialog({
    super.key, 
    required this.controller, 
    this.pelanggan, 
    required this.onSuccess,
  });

  @override
  _PelangganFormDialogState createState() => _PelangganFormDialogState();
}

class _PelangganFormDialogState extends State<PelangganFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _nomorTeleponController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.pelanggan?['namapelanggan'] ?? '');
    _alamatController = TextEditingController(text: widget.pelanggan?['alamat'] ?? '');
    _nomorTeleponController = TextEditingController(text: widget.pelanggan?['nomortelepon'] ?? '');
  }
  
  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }
  
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        if (widget.pelanggan == null) {
          await widget.controller.addPelanggan(
            _namaController.text,
            _alamatController.text,
            _nomorTeleponController.text,
          );
        } else {
          await widget.controller.updatePelanggan(
            widget.pelanggan!['pelangganID'],
            _namaController.text,
            _alamatController.text,
            _nomorTeleponController.text,
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
      title: Text(widget.pelanggan == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pelanggan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomorTeleponController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
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
              : Text(widget.pelanggan == null ? 'Simpan' : 'Update'),
        ),
      ],
    );
  }
}
