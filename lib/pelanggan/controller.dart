import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganController {
  final _supabase = Supabase.instance.client;
  
  // Mendapatkan semua data pelanggan
  Future<List<Map<String, dynamic>>> getAllPelanggan() async {
    try {
      final response = await _supabase
          .from('pelanggan')
          .select()
          .order('namapelanggan', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat data pelanggan: $e');
    }
  }
  
  // Mendapatkan pelanggan berdasarkan ID
  Future<Map<String, dynamic>?> getPelangganById(String pelangganID) async {
    try {
      final response = await _supabase
          .from('pelanggan')
          .select()
          .eq('pelangganID', pelangganID)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data pelanggan: $e');
    }
  }
  
  // Menambahkan pelanggan baru
  Future<void> addPelanggan(String namapelanggan, String alamat, String nomortelepon) async {
    try {
      await _supabase.from('pelanggan').insert({
        'namapelanggan': namapelanggan,
        'alamat': alamat,
        'nomortelepon': nomortelepon,
      });
    } catch (e) {
      throw Exception('Gagal menambahkan pelanggan: $e');
    }
  }
  
  // Mengupdate pelanggan
  Future<void> updatePelanggan(String pelangganID, String namapelanggan, String alamat, String nomortelepon) async {
    try {
      await _supabase.from('pelanggan').update({
        'namapelanggan': namapelanggan,
        'alamat': alamat,
        'nomortelepon': nomortelepon,
      }).eq('pelangganID', pelangganID);
    } catch (e) {
      throw Exception('Gagal mengupdate pelanggan: $e');
    }
  }
  
  // Menghapus pelanggan
  Future<void> deletePelanggan(String pelangganID) async {
    try {
      await _supabase.from('pelanggan').delete().eq('pelangganID', pelangganID);
    } catch (e) {
      throw Exception('Gagal menghapus pelanggan: $e');
    }
  }
}
