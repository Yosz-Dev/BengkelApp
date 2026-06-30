import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../transaksi/data/transaksi_model.dart';
import '../provider/riwayat_provider.dart';
import 'riwayat_detail_screen.dart';

/// Daftar riwayat transaksi dengan pencarian per tanggal & filter tipe (FR-07).
class RiwayatListScreen extends StatefulWidget {
  const RiwayatListScreen({super.key});

  @override
  State<RiwayatListScreen> createState() => _RiwayatListScreenState();
}

class _RiwayatListScreenState extends State<RiwayatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RiwayatProvider>().load(),
    );
  }

  Future<void> _pickDate() async {
    final provider = context.read<RiwayatProvider>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.date ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) provider.setDate(picked);
  }

  Future<void> _openDetail(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RiwayatDetailScreen(transaksiId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: Column(
        children: [
          _FilterBar(
            provider: provider,
            onPickDate: _pickDate,
          ),
          if (provider.items.isNotEmpty) _SummaryBar(provider: provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(RiwayatProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.items.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Belum ada transaksi',
        subtitle: 'Transaksi penjualan & servis akan muncul di sini.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: provider.items.length,
      itemBuilder: (_, i) {
        final trx = provider.items[i];
        return _RiwayatCard(
          trx: trx,
          onTap: () => _openDetail(trx.id!),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final RiwayatProvider provider;
  final VoidCallback onPickDate;

  const _FilterBar({required this.provider, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    final hasFilter = provider.date != null || provider.tipe != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    provider.date != null
                        ? Formatter.date(provider.date!)
                        : 'Semua Tanggal',
                  ),
                ),
              ),
              if (hasFilter) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Hapus filter',
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: provider.clearFilter,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TipeChip(
                label: 'Semua',
                selected: provider.tipe == null,
                onTap: () => provider.setTipe(null),
              ),
              const SizedBox(width: 8),
              _TipeChip(
                label: 'Penjualan',
                selected: provider.tipe == TransaksiModel.tipePenjualan,
                onTap: () => provider.setTipe(TransaksiModel.tipePenjualan),
              ),
              const SizedBox(width: 8),
              _TipeChip(
                label: 'Servis',
                selected: provider.tipe == TransaksiModel.tipeServis,
                onTap: () => provider.setTipe(TransaksiModel.tipeServis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TipeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final RiwayatProvider provider;

  const _SummaryBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${provider.items.length} transaksi',
            style: AppTextStyles.caption,
          ),
          Text(
            Formatter.rupiah(provider.totalNilai),
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final TransaksiModel trx;
  final VoidCallback onTap;

  const _RiwayatCard({required this.trx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isServis = trx.tipe == TransaksiModel.tipeServis;
    final color = isServis ? AppColors.secondary : AppColors.primary;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isServis ? Icons.build : Icons.point_of_sale,
            color: color,
          ),
        ),
        title: Text(
          '#${trx.id} · ${isServis ? 'Servis' : 'Penjualan'}',
          style: AppTextStyles.title,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatter.dateTime(trx.createdAt)),
            if (trx.pelangganNama != null && trx.pelangganNama!.isNotEmpty)
              Text(
                trx.pelangganNama!,
                style: AppTextStyles.caption,
              ),
          ],
        ),
        trailing: Text(
          Formatter.rupiah(trx.total),
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
