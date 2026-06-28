import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/struk_pdf.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../profil/data/profil_model.dart';
import '../../profil/data/profil_repository.dart';
import '../data/transaksi_model.dart';

/// Struk hasil transaksi: tampilan di layar + opsi cetak/PDF.
class StrukScreen extends StatefulWidget {
  final TransaksiModel transaksi;

  const StrukScreen({super.key, required this.transaksi});

  @override
  State<StrukScreen> createState() => _StrukScreenState();
}

class _StrukScreenState extends State<StrukScreen> {
  final _profilRepo = ProfilRepository();
  ProfilModel? _profil;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    final profil = await _profilRepo.getProfile();
    if (!mounted) return;
    setState(() => _profil = profil);
  }

  Future<void> _cetak() async {
    setState(() => _printing = true);
    try {
      final doc = StrukPdf.build(widget.transaksi, _profil);
      await Printing.layoutPdf(onLayout: (format) => doc.save());
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Gagal mencetak: $e');
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  void _selesai() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final trx = widget.transaksi;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selesai();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Struk Transaksi'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textOnPrimary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Transaksi Berhasil',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        _profil?.nama ?? AppConstants.appName,
                        style: AppTextStyles.title,
                      ),
                    ),
                    if (_profil?.alamat != null &&
                        _profil!.alamat!.isNotEmpty)
                      Center(
                        child: Text(
                          _profil!.alamat!,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const Divider(height: 20),
                    _InfoRow('No', '#${trx.id ?? '-'}'),
                    _InfoRow('Tanggal', Formatter.dateTime(trx.createdAt)),
                    if (trx.kasirNama != null)
                      _InfoRow('Kasir', trx.kasirNama!),
                    const Divider(height: 20),
                    ...trx.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nama, style: AppTextStyles.body),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.qty} x ${Formatter.rupiah(item.harga)}',
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  Formatter.rupiah(item.subtotal),
                                  style: AppTextStyles.body,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    _AmountRow('Subtotal', trx.subtotal),
                    if (trx.diskon > 0) _AmountRow('Diskon', -trx.diskon),
                    if (trx.pajak > 0) _AmountRow('Pajak', trx.pajak),
                    _AmountRow('Total', trx.total, emphasize: true),
                    _AmountRow('Bayar', trx.bayar),
                    _AmountRow('Kembalian', trx.kembalian),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _printing ? null : _cetak,
              icon: _printing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print),
              label: const Text('Cetak / PDF'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selesai,
              icon: const Icon(Icons.home),
              label: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _AmountRow(this.label, this.value, {this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? AppTextStyles.title.copyWith(color: AppColors.primary)
        : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(Formatter.rupiah(value), style: style),
        ],
      ),
    );
  }
}
