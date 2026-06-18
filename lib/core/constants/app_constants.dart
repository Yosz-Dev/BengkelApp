/// Konstanta umum aplikasi.
class AppConstants {
  AppConstants._();

  static const String appName = 'POS Bengkel';
  static const String appVersion = '1.0.0';

  // Aturan transaksi (sesuai PRD)
  static const double diskonThreshold = 200000; // total minimal untuk diskon
  static const double diskonRate = 0.10; // 10%
  static const double pajakRate = 0.11; // 11%

  // Spacing / radius
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double radius = 12;

  // Role
  static const String roleAdmin = 'admin';
  static const String roleKasir = 'kasir';
}
