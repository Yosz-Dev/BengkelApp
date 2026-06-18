import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/sparepart_model.dart';
import '../provider/sparepart_provider.dart';

/// Form tambah / edit sparepart.
class SparepartFormScreen extends StatefulWidget {
  final SparepartModel? sparepart;

  const SparepartFormScreen({super.key, this.sparepart});

  @override
  State<SparepartFormScreen> createState() => _SparepartFormScreenState();
}

class _SparepartFormScreenState extends State<SparepartFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kodeCtrl;
  late final TextEditingController _namaCtrl;
  late final TextEditingController _stokCtrl;
  late final TextEditingController _hargaBeliCtrl;
  late final TextEditingController _hargaJualCtrl;
  late final TextEditingController _satuanCtrl;
  bool _saving = false;

  bool get _isEdit => widget.sparepart != null;

  @override
  void initState() {
    super.initState();
    final sp = widget.sparepart;
    _kodeCtrl = TextEditingController(text: sp?.kode ?? '');
    _namaCtrl = TextEditingController(text: sp?.nama ?? '');
    _stokCtrl = TextEditingController(text: sp != null ? '${sp.stok}' : '');
    _hargaBeliCtrl = TextEditingController(
      text: sp != null && sp.hargaBeli > 0 ? '${sp.hargaBeli.toInt()}' : '',
    );
    _hargaJualCtrl = TextEditingController(
      text: sp != null && sp.hargaJual > 0 ? '${sp.hargaJual.toInt()}' : '',
    );
    _satuanCtrl = TextEditingController(text: sp?.satuan ?? '');
  }

  @override
  void dispose() {
    _kodeCtrl.dispose();
    _namaCtrl.dispose();
    _stokCtrl.dispose();
    _hargaBeliCtrl.dispose();
    _hargaJualCtrl.dispose();
    _satuanCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = SparepartModel(
      id: widget.sparepart?.id,
      kode: _kodeCtrl.text.trim().isEmpty ? null : _kodeCtrl.text.trim(),
      nama: _namaCtrl.text.trim(),
      stok: int.tryParse(_stokCtrl.text.trim()) ?? 0,
      hargaBeli: double.tryParse(_hargaBeliCtrl.text.trim()) ?? 0,
      hargaJual: double.tryParse(_hargaJualCtrl.text.trim()) ?? 0,
      satuan: _satuanCtrl.text.trim().isEmpty ? null : _satuanCtrl.text.trim(),
      createdAt: widget.sparepart?.createdAt,
    );

    await context.read<SparepartProvider>().save(item);
    if (!mounted) return;
    AppSnackbar.success(
      context,
      _isEdit ? 'Sparepart diperbarui' : 'Sparepart ditambahkan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Sparepart' : 'Tambah Sparepart'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            CustomTextField(
              controller: _namaCtrl,
              label: 'Nama Sparepart *',
              hint: 'Mis. Oli Mesin',
              validator: (v) => Validators.required(v, field: 'Nama'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _kodeCtrl,
              label: 'Kode (opsional)',
              hint: 'Mis. SP-001',
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _stokCtrl,
                    label: 'Stok *',
                    hint: '0',
                    numberOnly: true,
                    validator: (v) => Validators.number(v, field: 'Stok'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _satuanCtrl,
                    label: 'Satuan (opsional)',
                    hint: 'pcs / botol',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hargaJualCtrl,
              label: 'Harga Jual *',
              hint: '0',
              numberOnly: true,
              prefixIcon: Icons.sell_outlined,
              validator: (v) => Validators.number(v, field: 'Harga jual'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hargaBeliCtrl,
              label: 'Harga Beli (opsional)',
              hint: '0',
              numberOnly: true,
              prefixIcon: Icons.shopping_cart_outlined,
              validator: (v) =>
                  Validators.optionalNumber(v, field: 'Harga beli'),
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
