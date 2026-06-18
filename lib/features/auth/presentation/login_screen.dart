import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../provider/auth_provider.dart';

/// Layar login (FR-01).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_usernameCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      AppSnackbar.error(context, 'Username atau password salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.build_circle,
                    size: 84,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(AppConstants.appName, style: AppTextStyles.heading1),
                  const SizedBox(height: 4),
                  const Text(
                    'Silakan masuk untuk melanjutkan',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _usernameCtrl,
                    label: 'Username',
                    hint: 'Masukkan username',
                    prefixIcon: Icons.person_outline,
                    validator: (v) =>
                        Validators.required(v, field: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: 'Masukkan password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscure,
                    validator: (v) =>
                        Validators.required(v, field: 'Password'),
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: 'Masuk',
                    icon: Icons.login,
                    isLoading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
