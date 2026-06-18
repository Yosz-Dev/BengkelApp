import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../provider/auth_provider.dart';

/// Layar pembuka: memeriksa sesi login lalu mengarahkan ke
/// Dashboard (bila masih login) atau Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.tryAutoLogin();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      loggedIn ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_circle,
              size: 96,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.textOnPrimary),
          ],
        ),
      ),
    );
  }
}
