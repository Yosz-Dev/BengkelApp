import '../../jasa/data/jasa_model.dart';

/// Satu baris jasa pada transaksi servis: sebuah jasa beserta jumlahnya.
class JasaCartItem {
  final JasaModel jasa;
  int qty;

  JasaCartItem({required this.jasa, this.qty = 1});

  /// Subtotal baris = harga jasa × qty.
  double get subtotal => jasa.harga * qty;
}
