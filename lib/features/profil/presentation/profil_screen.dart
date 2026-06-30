import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/profil_model.dart';
import '../provider/profil_provider.dart';

/// Layar profil bengkel: nama, alamat, telepon (dipakai pada header struk).
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final provider = context.read<ProfilProvider>();
    await provider.load();
    final p = provider.profil;
    if (!mounted) return;
    setState(() {
      _namaCtrl.text = p?.nama ?? '';
      _alamatCtrl.text = p?.alamat ?? '';
      _teleponCtrl.text = p?.telepon ?? '';
      _initialized = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final existing = context.read<ProfilProvider>().profil;
    final profil = ProfilModel(
      id: existing?.id,
      nama: _namaCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim().isEmpty ? null : _alamatCtrl.text.trim(),
      telepon:
          _teleponCtrl.text.trim().isEmpty ? null : _teleponCtrl.text.trim(),
    );

    await context.read<ProfilProvider>().save(profil);
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Profil bengkel disimpan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Bengkel')),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.store,
                        size: 36,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _namaCtrl,
                    label: 'Nama Bengkel *',
                    hint: 'Mis. Bengkel Jaya Motor',
                    prefixIcon: Icons.store_outlined,
                    validator: (v) => Validators.required(v, field: 'Nama'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _alamatCtrl,
                    label: 'Alamat',
                    hint: 'Alamat bengkel',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _teleponCtrl,
                    label: 'Nomor Telepon',
                    hint: 'Mis. 0812xxxxxxx',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: 'Simpan',
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
