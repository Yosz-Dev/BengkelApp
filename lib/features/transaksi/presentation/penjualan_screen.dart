import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../sparepart/data/sparepart_model.dart';
import '../../sparepart/provider/sparepart_provider.dart';
import '../provider/penjualan_provider.dart';
import 'pembayaran_screen.dart';

/// Layar transaksi penjualan sparepart (FR-05).
/// Pilih sparepart → atur qty → lanjut ke pembayaran.
class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PenjualanProvider>().clear();
      context.read<SparepartProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToPembayaran() async {
    final penjualan = context.read<PenjualanProvider>();
    if (penjualan.isEmpty) {
      AppSnackbar.info(context, 'Keranjang masih kosong');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PembayaranScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sparepartProvider = context.watch<SparepartProvider>();
    final penjualan = context.watch<PenjualanProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Penjualan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                context.read<SparepartProvider>().search(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari sparepart...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<SparepartProvider>().search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(child: _buildList(sparepartProvider, penjualan)),
        ],
      ),
      bottomNavigationBar: _CartBar(
        itemCount: penjualan.itemCount,
        total: penjualan.calc.total,
        onPressed: _goToPembayaran,
      ),
    );
  }

  Widget _buildList(SparepartProvider provider, PenjualanProvider penjualan) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.items.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada sparepart',
        subtitle: 'Tambahkan data sparepart terlebih dahulu.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: provider.items.length,
      itemBuilder: (_, i) {
        final item = provider.items[i];
        return _SparepartTile(
          item: item,
          qty: item.id != null ? penjualan.qtyOf(item.id!) : 0,
          onAdd: () => context.read<PenjualanProvider>().addItem(item),
          onIncrement: () =>
              context.read<PenjualanProvider>().increment(item.id!),
          onDecrement: () =>
              context.read<PenjualanProvider>().decrement(item.id!),
        );
      },
    );
  }
}

class _SparepartTile extends StatelessWidget {
  final SparepartModel item;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _SparepartTile({
    required this.item,
    required this.qty,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final habis = item.stok <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    Formatter.rupiah(item.hargaJual),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habis ? 'Stok habis' : 'Stok: ${item.stok}',
                    style: AppTextStyles.caption.copyWith(
                      color: habis ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (habis)
              const SizedBox.shrink()
            else if (qty == 0)
              IconButton.filled(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Tambah ke keranjang',
              )
            else
              _QtyStepper(
                qty: qty,
                canIncrement: qty < item.stok,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyStepper({
    required this.qty,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.error,
        ),
        SizedBox(
          width: 24,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),
        ),
        IconButton(
          onPressed: canIncrement ? onIncrement : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _CartBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onPressed;

  const _CartBar({
    required this.itemCount,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: itemCount > 0 ? onPressed : null,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.textOnPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Bayar'),
                const Spacer(),
                Text(
                  Formatter.rupiah(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
