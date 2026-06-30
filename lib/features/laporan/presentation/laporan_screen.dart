import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../sparepart/data/sparepart_model.dart';
import '../data/laporan_model.dart';
import '../provider/laporan_provider.dart';

/// Laporan pendapatan (harian/bulanan) & laporan stok sparepart (FR-08).
class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LaporanProvider>();
      provider.loadPendapatan();
      provider.loadStok();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendapatan', icon: Icon(Icons.payments)),
              Tab(text: 'Stok', icon: Icon(Icons.inventory_2)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendapatanTab(),
            _StokTab(),
          ],
        ),
      ),
    );
  }
}

// ============================ Pendapatan ============================

class _PendapatanTab extends StatelessWidget {
  const _PendapatanTab();

  Future<void> _pick(BuildContext context, LaporanProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.periode,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      helpText: provider.harian ? 'Pilih Tanggal' : 'Pilih Bulan',
    );
    if (picked != null) provider.setPeriode(picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();
    final r = provider.ringkasan;
    final periodeLabel = provider.harian
        ? Formatter.date(provider.periode)
        : DateFormat('MMMM yyyy', 'id_ID').format(provider.periode);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Harian')),
            ButtonSegment(value: false, label: Text('Bulanan')),
          ],
          selected: {provider.harian},
          onSelectionChanged: (s) => provider.setMode(harian: s.first),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _pick(context, provider),
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(periodeLabel),
        ),
        const SizedBox(height: 16),
        if (provider.loadingPendapatan)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          _TotalCard(total: r.total, jumlah: r.jumlahTransaksi),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Penjualan',
                  value: Formatter.rupiah(r.totalPenjualan),
                  color: AppColors.primary,
                  icon: Icons.point_of_sale,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Servis',
                  value: Formatter.rupiah(r.totalServis),
                  color: AppColors.secondary,
                  icon: Icons.build,
                ),
              ),
            ],
          ),
          if (!provider.harian) ...[
            const SizedBox(height: 20),
            Text('Rincian Harian', style: AppTextStyles.title),
            const SizedBox(height: 8),
            if (provider.rincian.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.bar_chart,
                  message: 'Tidak ada transaksi pada bulan ini',
                ),
              )
            else
              ...provider.rincian.map((d) => _RincianRow(item: d)),
          ],
        ],
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  final int jumlah;

  const _TotalCard({required this.total, required this.jumlah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pendapatan',
            style: TextStyle(color: AppColors.textOnPrimary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            Formatter.rupiah(total),
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$jumlah transaksi',
            style: TextStyle(
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RincianRow extends StatelessWidget {
  final PendapatanPerHari item;

  const _RincianRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.event, color: AppColors.textSecondary),
        title: Text(Formatter.date(item.tanggal)),
        subtitle: Text('${item.jumlah} transaksi'),
        trailing: Text(
          Formatter.rupiah(item.total),
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ============================ Stok ============================

class _StokTab extends StatelessWidget {
  const _StokTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();

    if (provider.loadingStok) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.stok.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada sparepart',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Jenis Item',
                value: '${provider.totalItemStok}',
                color: AppColors.info,
                icon: Icons.category,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Total Unit',
                value: Formatter.number(provider.totalUnitStok),
                color: AppColors.success,
                icon: Icons.numbers,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Nilai Stok (modal)',
                value: Formatter.rupiah(provider.nilaiStok),
                color: AppColors.primary,
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Stok Menipis',
                value: '${provider.stokMenipis.length}',
                color: AppColors.error,
                icon: Icons.warning_amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Daftar Stok', style: AppTextStyles.title),
        const SizedBox(height: 8),
        ...provider.stok.map((s) => _StokRow(item: s)),
      ],
    );
  }
}

class _StokRow extends StatelessWidget {
  final SparepartModel item;

  const _StokRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final low = item.stok <= 5;
    final satuan =
        item.satuan != null && item.satuan!.isNotEmpty ? ' ${item.satuan}' : '';
    return Card(
      child: ListTile(
        dense: true,
        title: Text(item.nama, style: AppTextStyles.body),
        subtitle: item.kode != null && item.kode!.isNotEmpty
            ? Text('Kode: ${item.kode}', style: AppTextStyles.caption)
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (low ? AppColors.error : AppColors.success)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${item.stok}$satuan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: low ? AppColors.error : AppColors.success,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ Shared ============================

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.title.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
