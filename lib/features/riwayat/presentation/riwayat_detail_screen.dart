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
import '../../transaksi/data/transaksi_model.dart';
import '../../transaksi/data/transaksi_repository.dart';

/// Detail satu transaksi dari Riwayat, lengkap dengan opsi cetak/PDF.
class RiwayatDetailScreen extends StatefulWidget {
  final int transaksiId;

  const RiwayatDetailScreen({super.key, required this.transaksiId});

  @override
  State<RiwayatDetailScreen> createState() => _RiwayatDetailScreenState();
}

class _RiwayatDetailScreenState extends State<RiwayatDetailScreen> {
  final _trxRepo = TransaksiRepository();
  final _profilRepo = ProfilRepository();

  TransaksiModel? _trx;
  ProfilModel? _profil;
  bool _loading = true;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trx = await _trxRepo.getById(widget.transaksiId);
    final profil = await _profilRepo.getProfile();
    if (!mounted) return;
    setState(() {
      _trx = trx;
      _profil = profil;
      _loading = false;
    });
  }

  Future<void> _cetak() async {
    final trx = _trx;
    if (trx == null) return;
    setState(() => _printing = true);
    try {
      final doc = StrukPdf.build(trx, _profil);
      await Printing.layoutPdf(onLayout: (format) => doc.save());
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Gagal mencetak: $e');
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final trx = _trx;
    if (trx == null) {
      return const Center(child: Text('Transaksi tidak ditemukan.'));
    }

    final isServis = trx.tipe == TransaksiModel.tipeServis;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${trx.id}', style: AppTextStyles.title),
                    _TipeBadge(isServis: isServis),
                  ],
                ),
                const Divider(height: 20),
                _InfoRow('Tanggal', Formatter.dateTime(trx.createdAt)),
                if (trx.kasirNama != null) _InfoRow('Kasir', trx.kasirNama!),
                if (trx.pelangganNama != null &&
                    trx.pelangganNama!.isNotEmpty)
                  _InfoRow('Pelanggan', trx.pelangganNama!),
                const Divider(height: 20),
                ...trx.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item.jenis == 'jasa'
                                  ? Icons.handyman
                                  : Icons.inventory_2,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(item.nama, style: AppTextStyles.body),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (trx.bayar > 0) _AmountRow('Bayar', trx.bayar),
                if (trx.bayar > 0) _AmountRow('Kembalian', trx.kembalian),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }
}

class _TipeBadge extends StatelessWidget {
  final bool isServis;

  const _TipeBadge({required this.isServis});

  @override
  Widget build(BuildContext context) {
    final color = isServis ? AppColors.secondary : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isServis ? 'SERVIS' : 'PENJUALAN',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
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
