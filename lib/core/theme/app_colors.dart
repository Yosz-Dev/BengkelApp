import 'package:flutter/material.dart';

/// Palet warna aplikasi POS Bengkel.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1565C0); // biru bengkel
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color secondary = Color(0xFFFF8F00); // oranye aksen
  static const Color secondaryDark = Color(0xFFC56000);

  // Netral
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);

  // Teks
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);
}
