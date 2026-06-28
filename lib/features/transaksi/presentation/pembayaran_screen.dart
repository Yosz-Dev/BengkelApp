import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/provider/auth_provider.dart';
import '../../sparepart/provider/sparepart_provider.dart';
import '../provider/penjualan_provider.dart';
import 'struk_screen.dart';

/// Layar pembayaran: ringkasan transaksi + input uang & kembalian.
class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  final _bayarCtrl = TextEditingController();
  double _bayar = 0;

  @override
  void dispose() {
    _bayarCtrl.dispose();
    super.dispose();
  }

  void _setBayar(String value) {
    setState(() => _bayar = double.tryParse(value) ?? 0);
  }

  void _setNominal(double value) {
    _bayarCtrl.text = value.toInt().toString();
    _setBayar(_bayarCtrl.text);
  }

  Future<void> _proses() async {
    final penjualan = context.read<PenjualanProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final trx = await penjualan.checkout(bayar: _bayar, kasir: user);
    if (!mounted) return;
    if (trx == null) {
      AppSnackbar.error(context, 'Pembayaran gagal. Periksa nominal & keranjang.');
      return;
    }
    // Segarkan stok sparepart setelah pengurangan.
    await context.read<SparepartProvider>().load();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StrukScreen(transaksi: trx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final penjualan = context.watch<PenjualanProvider>();
    final calc = penjualan.calc;
    final kembalian = _bayar - calc.total;
    final cukup = _bayar >= calc.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                children: [
                  ...penjualan.cart.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.sparepart.nama}  x${item.qty}',
                              style: AppTextStyles.body,
                            ),
                          ),
                          Text(
                            Formatter.rupiah(item.subtotal),
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  _SummaryRow('Subtotal', calc.subtotal),
                  if (calc.diskon > 0)
                    _SummaryRow('Diskon (10%)', -calc.diskon),
                  if (calc.pajak > 0) _SummaryRow('Pajak (11%)', calc.pajak),
                  const Divider(),
                  _SummaryRow('Total', calc.total, emphasize: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Uang Bayar', style: AppTextStyles.title),
          const SizedBox(height: 8),
          TextField(
            controller: _bayarCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.heading2,
            onChanged: _setBayar,
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: '0',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickNominals(calc.total)
                .map(
                  (n) => ActionChip(
                    label: Text(Formatter.rupiah(n)),
                    onPressed: () => _setNominal(n),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: (cukup ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kembalian', style: AppTextStyles.title),
                Text(
                  Formatter.rupiah(kembalian < 0 ? 0 : kembalian),
                  style: AppTextStyles.heading2.copyWith(
                    color: cukup ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Proses Pembayaran',
            icon: Icons.check_circle,
            isLoading: penjualan.processing,
            onPressed: cukup ? _proses : null,
          ),
        ],
      ),
    );
  }

  /// Saran nominal cepat: pas, lalu pembulatan ke atas yang umum.
  List<double> _quickNominals(double total) {
    final result = <double>{total.ceilToDouble()};
    for (final step in [5000, 10000, 20000, 50000, 100000]) {
      final rounded = (total / step).ceil() * step;
      result.add(rounded.toDouble());
    }
    final list = result.where((n) => n >= total).toList()..sort();
    return list.take(4).toList();
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _SummaryRow(this.label, this.value, {this.emphasize = false});

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
