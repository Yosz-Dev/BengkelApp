import '../../sparepart/data/sparepart_model.dart';

/// Satu baris di keranjang penjualan: sebuah sparepart beserta jumlahnya.
/// Menyimpan referensi [SparepartModel] agar batas stok dapat diperiksa
/// sebelum transaksi disimpan.
class CartItem {
  final SparepartModel sparepart;
  int qty;

  CartItem({required this.sparepart, this.qty = 1});

  /// Subtotal baris = harga jual × qty.
  double get subtotal => sparepart.hargaJual * qty;
}
