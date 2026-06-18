import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/pelanggan_model.dart';
import '../provider/pelanggan_provider.dart';

/// Form tambah / edit pelanggan.
class PelangganFormScreen extends StatefulWidget {
  final PelangganModel? pelanggan;

  const PelangganFormScreen({super.key, this.pelanggan});

  @override
  State<PelangganFormScreen> createState() => _PelangganFormScreenState();
}

class _PelangganFormScreenState extends State<PelangganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _noHpCtrl;
  late final TextEditingController _noKendaraanCtrl;
  late final TextEditingController _jenisKendaraanCtrl;
  bool _saving = false;

  bool get _isEdit => widget.pelanggan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pelanggan;
    _namaCtrl = TextEditingController(text: p?.nama ?? '');
    _noHpCtrl = TextEditingController(text: p?.noHp ?? '');
    _noKendaraanCtrl = TextEditingController(text: p?.noKendaraan ?? '');
    _jenisKendaraanCtrl = TextEditingController(text: p?.jenisKendaraan ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noHpCtrl.dispose();
    _noKendaraanCtrl.dispose();
    _jenisKendaraanCtrl.dispose();
    super.dispose();
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = PelangganModel(
      id: widget.pelanggan?.id,
      nama: _namaCtrl.text.trim(),
      noHp: _emptyToNull(_noHpCtrl.text),
      noKendaraan: _emptyToNull(_noKendaraanCtrl.text),
      jenisKendaraan: _emptyToNull(_jenisKendaraanCtrl.text),
      createdAt: widget.pelanggan?.createdAt,
    );

    await context.read<PelangganProvider>().save(item);
    if (!mounted) return;
    AppSnackbar.success(
      context,
      _isEdit ? 'Pelanggan diperbarui' : 'Pelanggan ditambahkan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            CustomTextField(
              controller: _namaCtrl,
              label: 'Nama Pelanggan *',
              hint: 'Mis. Budi Santoso',
              prefixIcon: Icons.person_outline,
              validator: (v) => Validators.required(v, field: 'Nama'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _noHpCtrl,
              label: 'No. HP (opsional)',
              hint: '08xxxxxxxxxx',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _noKendaraanCtrl,
              label: 'No. Kendaraan (opsional)',
              hint: 'Mis. B 1234 ABC',
              prefixIcon: Icons.confirmation_number_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _jenisKendaraanCtrl,
              label: 'Jenis Kendaraan (opsional)',
              hint: 'Mis. Honda Beat',
              prefixIcon: Icons.two_wheeler_outlined,
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
