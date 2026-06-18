import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/jasa_model.dart';
import '../provider/jasa_provider.dart';

/// Form tambah / edit jasa servis.
class JasaFormScreen extends StatefulWidget {
  final JasaModel? jasa;

  const JasaFormScreen({super.key, this.jasa});

  @override
  State<JasaFormScreen> createState() => _JasaFormScreenState();
}

class _JasaFormScreenState extends State<JasaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _hargaCtrl;
  late final TextEditingController _deskripsiCtrl;
  bool _saving = false;

  bool get _isEdit => widget.jasa != null;

  @override
  void initState() {
    super.initState();
    final j = widget.jasa;
    _namaCtrl = TextEditingController(text: j?.nama ?? '');
    _hargaCtrl = TextEditingController(
      text: j != null && j.harga > 0 ? '${j.harga.toInt()}' : '',
    );
    _deskripsiCtrl = TextEditingController(text: j?.deskripsi ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = JasaModel(
      id: widget.jasa?.id,
      nama: _namaCtrl.text.trim(),
      harga: double.tryParse(_hargaCtrl.text.trim()) ?? 0,
      deskripsi:
          _deskripsiCtrl.text.trim().isEmpty ? null : _deskripsiCtrl.text.trim(),
      createdAt: widget.jasa?.createdAt,
    );

    await context.read<JasaProvider>().save(item);
    if (!mounted) return;
    AppSnackbar.success(
      context,
      _isEdit ? 'Jasa diperbarui' : 'Jasa ditambahkan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Jasa' : 'Tambah Jasa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            CustomTextField(
              controller: _namaCtrl,
              label: 'Nama Jasa *',
              hint: 'Mis. Servis Ringan',
              validator: (v) => Validators.required(v, field: 'Nama'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hargaCtrl,
              label: 'Harga *',
              hint: '0',
              numberOnly: true,
              prefixIcon: Icons.sell_outlined,
              validator: (v) => Validators.number(v, field: 'Harga'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _deskripsiCtrl,
              label: 'Deskripsi (opsional)',
              hint: 'Keterangan jasa',
              maxLines: 3,
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
