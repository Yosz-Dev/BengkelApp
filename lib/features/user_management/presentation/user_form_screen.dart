import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/data/user_model.dart';
import '../provider/user_provider.dart';

/// Form tambah / edit user (admin / kasir).
class UserFormScreen extends StatefulWidget {
  final UserModel? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late String _role;
  bool _saving = false;
  bool _obscure = true;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _namaCtrl = TextEditingController(text: u?.nama ?? '');
    _usernameCtrl = TextEditingController(text: u?.username ?? '');
    _passwordCtrl = TextEditingController();
    _role = u?.role ?? AppConstants.roleKasir;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    // Saat edit, password boleh dikosongkan (artinya tidak diubah).
    if (_isEdit && (value == null || value.trim().isEmpty)) return null;
    return Validators.minLength(value, 6, field: 'Password');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final existing = widget.user;
    final password = _passwordCtrl.text.trim().isEmpty
        ? (existing?.password ?? '')
        : _passwordCtrl.text.trim();

    final user = UserModel(
      id: existing?.id,
      username: _usernameCtrl.text.trim(),
      password: password,
      nama: _namaCtrl.text.trim(),
      role: _role,
      createdAt: existing?.createdAt,
    );

    final error = await context.read<UserProvider>().save(user);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }
    AppSnackbar.success(
      context,
      _isEdit ? 'User diperbarui' : 'User ditambahkan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit User' : 'Tambah User')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            CustomTextField(
              controller: _namaCtrl,
              label: 'Nama Lengkap *',
              hint: 'Mis. Budi Santoso',
              prefixIcon: Icons.person_outline,
              validator: (v) => Validators.required(v, field: 'Nama'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _usernameCtrl,
              label: 'Username *',
              hint: 'Mis. kasir1',
              prefixIcon: Icons.alternate_email,
              validator: (v) => Validators.minLength(v, 3, field: 'Username'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordCtrl,
              label: _isEdit ? 'Password (kosongkan jika tetap)' : 'Password *',
              hint: 'Minimal 6 karakter',
              obscureText: _obscure,
              prefixIcon: Icons.lock_outline,
              validator: _validatePassword,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Role *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(
                  value: AppConstants.roleAdmin,
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: AppConstants.roleKasir,
                  child: Text('Kasir'),
                ),
              ],
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: _isEdit ? 'Simpan Perubahan' : 'Simpan',
              icon: Icons.save,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
