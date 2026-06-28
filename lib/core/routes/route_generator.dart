import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/jasa/presentation/jasa_list_screen.dart';
import '../../features/pelanggan/presentation/pelanggan_list_screen.dart';
import '../../features/sparepart/presentation/sparepart_list_screen.dart';
import '../../features/transaksi/presentation/penjualan_screen.dart';
import 'app_routes.dart';

/// Pembangkit route terpusat. Setiap fitur menambahkan case-nya
/// di sini secara bertahap.
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _build(const SplashScreen(), settings);
      case AppRoutes.login:
        return _build(const LoginScreen(), settings);
      case AppRoutes.dashboard:
        return _build(const DashboardScreen(), settings);
      case AppRoutes.sparepart:
        return _build(const SparepartListScreen(), settings);
      case AppRoutes.jasa:
        return _build(const JasaListScreen(), settings);
      case AppRoutes.pelanggan:
        return _build(const PelangganListScreen(), settings);
      case AppRoutes.penjualan:
        return _build(const PenjualanScreen(), settings);

      // TODO(fase berikutnya): servis, riwayat, laporan, dst.
      default:
        return _build(_NotReadyScreen(name: settings.name), settings);
    }
  }

  static MaterialPageRoute _build(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }
}

/// Layar sementara untuk route yang belum diimplementasikan.
class _NotReadyScreen extends StatelessWidget {
  final String? name;
  const _NotReadyScreen({this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segera Hadir')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 72, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Halaman "${name ?? '-'}" sedang dikembangkan.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
