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
  
  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      produkID: json['produkID'],
      namaproduk: json['namaproduk'] ?? '',
      harga: (json['harga'] is int) 
        ? (json['harga'] as int).toDouble() 
        : (json['harga'] ?? 0).toDouble(),
      stok: json['stok'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'produkID': produkID,
      'namaproduk': namaproduk,
      'harga': harga,
      'stok': stok,
    };
  }
}

class Transaksi {
  final String penjualanID;  // Pastikan ada
  final String namapelanggan;
  final DateTime tanggalpenjualan;
  final double totalharga;

  Transaksi({
    required this.penjualanID,
    required this.namapelanggan,
    required this.tanggalpenjualan,
    required this.totalharga,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      penjualanID: json['penjualanID'],  // Pastikan diambil dari JSON
      namapelanggan: json['pelanggan']['namapelanggan'] ?? 'Tanpa Nama',
      tanggalpenjualan: DateTime.parse(json['tanggalpenjualan']),
      totalharga: (json['totalharga'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Pelanggan {
  final String pelangganID;
  final String namapelanggan;
  
  Pelanggan({
    required this.pelangganID,
    required this.namapelanggan,
  });
  
  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      pelangganID: json['pelangganID'],
      namapelanggan: json['namapelanggan'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'pelangganID': pelangganID,
      'namapelanggan': namapelanggan,
    };
  }
}

class KeranjangItem {
  final String produkID;
  final String namaproduk;
  final double harga;
  int jumlahproduk;
  
  KeranjangItem({
    required this.produkID,
    required this.namaproduk,
    required this.harga,
    this.jumlahproduk = 1,
  });
  
  double get subtotal => harga * jumlahproduk;
  
  void tambahJumlah() {
    jumlahproduk++;
  }
  
  void kurangJumlah() {
    if (jumlahproduk > 1) {
      jumlahproduk--;
    }
  }
  
  factory KeranjangItem.fromProduk(Produk produk) {
    return KeranjangItem(
      produkID: produk.produkID,
      namaproduk: produk.namaproduk,
      harga: produk.harga,
      jumlahproduk: 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'produkID': produkID,
      'namaproduk': namaproduk,
      'harga': harga,
      'jumlahproduk': jumlahproduk,
      'subtotal': subtotal,
    };
  }
}