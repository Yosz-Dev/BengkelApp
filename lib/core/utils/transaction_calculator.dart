import '../constants/app_constants.dart';

/// Hasil perhitungan satu transaksi.
class TransactionResult {
  final double subtotal;
  final double diskon;
  final double dpp; // dasar pengenaan pajak (subtotal - diskon)
  final double pajak;
  final double total;

  const TransactionResult({
    required this.subtotal,
    required this.diskon,
    required this.dpp,
    required this.pajak,
    required this.total,
  });

  double kembalian(double bayar) => bayar - total;
}

/// Perhitungan transaksi sesuai aturan PRD:
/// subtotal → diskon 10% (jika subtotal ≥ Rp200.000) → DPP → pajak 11% → total.
class TransactionCalculator {
  TransactionCalculator._();

  static TransactionResult calculate(double subtotal) {
    final diskon = subtotal >= AppConstants.diskonThreshold
        ? subtotal * AppConstants.diskonRate
        : 0.0;
    final dpp = subtotal - diskon;
    final pajak = dpp * AppConstants.pajakRate;
    final total = dpp + pajak;

    return TransactionResult(
      subtotal: subtotal,
      diskon: diskon,
      dpp: dpp,
      pajak: pajak,
      total: total,
    );
  }
}
