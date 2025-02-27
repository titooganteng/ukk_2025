class Produk {
  final String produkID;
  final String namaproduk;
  final double harga;
  final int stok;
  
  Produk({
    required this.produkID,
    required this.namaproduk,
    required this.harga,
    required this.stok,
  });
  
  // Dari JSON (Supabase) ke objek Produk
  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      produkID: json['produkID'],
      namaproduk: json['namaproduk'],
      harga: json['harga'].toDouble(),
      stok: json['stok'],
    );
  }
  
  // Dari objek Produk ke JSON (untuk Supabase)
  Map<String, dynamic> toJson() {
    return {
      'produkID': produkID,
      'namaproduk': namaproduk,
      'harga': harga,
      'stok': stok,
    };
  }
  
  // Membuat salinan objek dengan nilai yang diperbarui
  Produk copyWith({
    String? produkID,
    String? namaproduk,
    double? harga,
    int? stok,
  }) {
    return Produk(
      produkID: produkID ?? this.produkID,
      namaproduk: namaproduk ?? this.namaproduk,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
    );
  }
}