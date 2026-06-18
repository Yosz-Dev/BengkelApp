import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/provider/auth_provider.dart';

/// Item menu pada dashboard.
class _MenuItem {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  final bool adminOnly;

  const _MenuItem(
    this.label,
    this.icon,
    this.route,
    this.color, {
    this.adminOnly = false,
  });
}

/// Dashboard utama — hub navigasi seluruh modul.
/// (Ringkasan/statistik akan ditambahkan pada Fase 7.)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<_MenuItem> _menus = [
    _MenuItem('Penjualan', Icons.point_of_sale, AppRoutes.penjualan,
        AppColors.primary),
    _MenuItem('Servis', Icons.build, AppRoutes.servis, AppColors.secondary),
    _MenuItem('Riwayat', Icons.receipt_long, AppRoutes.riwayat,
        Color(0xFF6A1B9A)),
    _MenuItem('Sparepart', Icons.inventory_2, AppRoutes.sparepart,
        Color(0xFF00838F)),
    _MenuItem('Jasa', Icons.handyman, AppRoutes.jasa, Color(0xFF2E7D32)),
    _MenuItem('Pelanggan', Icons.people_alt, AppRoutes.pelanggan,
        Color(0xFFAD1457), adminOnly: true),
    _MenuItem('Laporan', Icons.bar_chart, AppRoutes.laporan,
        Color(0xFFEF6C00), adminOnly: true),
    _MenuItem('Kelola User', Icons.manage_accounts, AppRoutes.userManagement,
        Color(0xFF455A64), adminOnly: true),
    _MenuItem('Profil Bengkel', Icons.store, AppRoutes.profil,
        Color(0xFF5D4037), adminOnly: true),
  ];

  Future<void> _logout(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Apakah Anda yakin ingin keluar?',
      confirmLabel: 'Logout',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final menus =
        _menus.where((m) => !m.adminOnly || auth.isAdmin).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Greeting(nama: user?.nama ?? '-', role: user?.role ?? '-'),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              crossAxisCount: 3,
              mainAxisSpacing: AppConstants.paddingM,
              crossAxisSpacing: AppConstants.paddingM,
              children: menus
                  .map((m) => _MenuCard(
                        item: m,
                        onTap: () => Navigator.pushNamed(context, m.route),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String nama;
  final String role;

  const _Greeting({required this.nama, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $nama',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _MenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
