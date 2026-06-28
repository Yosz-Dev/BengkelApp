import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/provider/auth_provider.dart';
import '../../jasa/provider/jasa_provider.dart';
import '../../pelanggan/data/pelanggan_model.dart';
import '../../pelanggan/provider/pelanggan_provider.dart';
import '../../sparepart/provider/sparepart_provider.dart';
import '../provider/servis_provider.dart';
import 'pembayaran_screen.dart';

/// Layar transaksi servis (FR-06): pilih pelanggan (opsional) + jasa +
/// sparepart terpakai → hitung total → bayar.
class ServisScreen extends StatefulWidget {
  const ServisScreen({super.key});

  @override
  State<ServisScreen> createState() => _ServisScreenState();
}

class _ServisScreenState extends State<ServisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServisProvider>().clear();
      context.read<JasaProvider>().load();
      context.read<SparepartProvider>().load();
      context.read<PelangganProvider>().load();
    });
  }

  Future<void> _goToPembayaran() async {
    final servis = context.read<ServisProvider>();
    if (servis.isEmpty) {
      AppSnackbar.info(context, 'Tambahkan jasa atau sparepart dahulu');
      return;
    }
    final sparepart = context.read<SparepartProvider>();
    final auth = context.read<AuthProvider>();

    final lines = [
      ...servis.jasaItems.map((e) => PembayaranLine(
            label: '${e.jasa.nama}  x${e.qty}',
            subtotal: e.subtotal,
          )),
      ...servis.sparepartItems.map((e) => PembayaranLine(
            label: '${e.sparepart.nama}  x${e.qty}',
            subtotal: e.subtotal,
          )),
    ];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PembayaranScreen(
          title: 'Pembayaran Servis',
          lines: lines,
          calc: servis.calc,
          onCheckout: (bayar) async {
            final user = auth.currentUser;
            if (user == null) return null;
            final trx = await servis.checkout(bayar: bayar, kasir: user);
            if (trx != null) await sparepart.load();
            return trx;
          },
        ),
      ),
    );
  }

  // ---------- Pickers ----------

  Future<void> _pickPelanggan() async {
    final servis = context.read<ServisProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(
        title: 'Pilih Pelanggan',
        searchHint: 'Cari pelanggan...',
        onSearch: (q) => context.read<PelangganProvider>().search(q),
        leading: ListTile(
          leading: const Icon(Icons.person_off_outlined),
          title: const Text('Tanpa pelanggan'),
          onTap: () {
            servis.clearPelanggan();
            Navigator.pop(context);
          },
        ),
        body: Consumer<PelangganProvider>(
          builder: (_, p, __) {
            if (p.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (p.items.isEmpty) {
              return const EmptyState(
                icon: Icons.people_alt_outlined,
                message: 'Belum ada pelanggan',
              );
            }
            return ListView.builder(
              itemCount: p.items.length,
              itemBuilder: (_, i) {
                final plg = p.items[i];
                return ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: Text(plg.nama),
                  subtitle: Text(_pelangganSubtitle(plg)),
                  onTap: () {
                    servis.setPelanggan(plg);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ),
    );
    if (mounted) context.read<PelangganProvider>().search('');
  }

  Future<void> _pickJasa() async {
    final servis = context.read<ServisProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(
        title: 'Tambah Jasa',
        searchHint: 'Cari jasa...',
        onSearch: (q) => context.read<JasaProvider>().search(q),
        body: Consumer<JasaProvider>(
          builder: (_, p, __) {
            if (p.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (p.items.isEmpty) {
              return const EmptyState(
                icon: Icons.handyman_outlined,
                message: 'Belum ada jasa',
              );
            }
            return ListView.builder(
              itemCount: p.items.length,
              itemBuilder: (_, i) {
                final jasa = p.items[i];
                return ListTile(
                  leading: const Icon(Icons.handyman, color: AppColors.primary),
                  title: Text(jasa.nama),
                  subtitle: Text(Formatter.rupiah(jasa.harga)),
                  trailing: const Icon(Icons.add_circle, color: AppColors.primary),
                  onTap: () {
                    servis.addJasa(jasa);
                    AppSnackbar.success(context, '${jasa.nama} ditambahkan');
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ),
    );
    if (mounted) context.read<JasaProvider>().search('');
  }

  Future<void> _pickSparepart() async {
    final servis = context.read<ServisProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(
        title: 'Tambah Sparepart',
        searchHint: 'Cari sparepart...',
        onSearch: (q) => context.read<SparepartProvider>().search(q),
        body: Consumer<SparepartProvider>(
          builder: (_, p, __) {
            if (p.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (p.items.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'Belum ada sparepart',
              );
            }
            return ListView.builder(
              itemCount: p.items.length,
              itemBuilder: (_, i) {
                final sp = p.items[i];
                final habis = sp.stok <= 0;
                return ListTile(
                  enabled: !habis,
                  leading:
                      const Icon(Icons.inventory_2, color: AppColors.primary),
                  title: Text(sp.nama),
                  subtitle: Text(
                    '${Formatter.rupiah(sp.hargaJual)} · ${habis ? 'Stok habis' : 'Stok: ${sp.stok}'}',
                  ),
                  trailing: habis
                      ? null
                      : const Icon(Icons.add_circle, color: AppColors.primary),
                  onTap: habis
                      ? null
                      : () {
                          servis.addSparepart(sp);
                          AppSnackbar.success(context, '${sp.nama} ditambahkan');
                          Navigator.pop(context);
                        },
                );
              },
            );
          },
        ),
      ),
    );
    if (mounted) context.read<SparepartProvider>().search('');
  }

  String _pelangganSubtitle(PelangganModel p) {
    final parts = <String>[];
    if (p.noKendaraan != null && p.noKendaraan!.isNotEmpty) {
      parts.add(p.noKendaraan!);
    }
    if (p.jenisKendaraan != null && p.jenisKendaraan!.isNotEmpty) {
      parts.add(p.jenisKendaraan!);
    }
    return parts.isEmpty ? (p.noHp ?? '-') : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final servis = context.watch<ServisProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Servis')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _PelangganCard(
            pelanggan: servis.pelanggan,
            subtitle: servis.pelanggan != null
                ? _pelangganSubtitle(servis.pelanggan!)
                : null,
            onTap: _pickPelanggan,
            onClear: servis.pelanggan != null ? servis.clearPelanggan : null,
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Jasa',
            icon: Icons.handyman,
            onAdd: _pickJasa,
          ),
          const SizedBox(height: 8),
          if (servis.jasaItems.isEmpty)
            const _EmptyHint('Belum ada jasa dipilih')
          else
            ...servis.jasaItems.map(
              (e) => _LineTile(
                nama: e.jasa.nama,
                harga: e.jasa.harga,
                qty: e.qty,
                subtotal: e.subtotal,
                canIncrement: true,
                onIncrement: () => servis.incJasa(e.jasa.id!),
                onDecrement: () => servis.decJasa(e.jasa.id!),
              ),
            ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Sparepart',
            icon: Icons.inventory_2,
            onAdd: _pickSparepart,
          ),
          const SizedBox(height: 8),
          if (servis.sparepartItems.isEmpty)
            const _EmptyHint('Belum ada sparepart dipilih')
          else
            ...servis.sparepartItems.map(
              (e) => _LineTile(
                nama: e.sparepart.nama,
                harga: e.sparepart.hargaJual,
                qty: e.qty,
                subtotal: e.subtotal,
                canIncrement: e.qty < e.sparepart.stok,
                onIncrement: () => servis.incSparepart(e.sparepart.id!),
                onDecrement: () => servis.decSparepart(e.sparepart.id!),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _TotalBar(
        itemCount: servis.itemCount,
        total: servis.calc.total,
        onPressed: _goToPembayaran,
      ),
    );
  }
}

class _PelangganCard extends StatelessWidget {
  final PelangganModel? pelanggan;
  final String? subtitle;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _PelangganCard({
    required this.pelanggan,
    required this.subtitle,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(pelanggan?.nama ?? 'Pilih Pelanggan (opsional)'),
        subtitle: pelanggan != null ? Text(subtitle ?? '') : null,
        trailing: onClear != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.title),
        const Spacer(),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('Tambah $title'),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  final String nama;
  final double harga;
  final int qty;
  final double subtotal;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _LineTile({
    required this.nama,
    required this.harga,
    required this.qty,
    required this.subtotal,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatter.rupiah(harga)} · ${Formatter.rupiah(subtotal)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.error,
            ),
            SizedBox(
              width: 22,
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
        ),
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onPressed;

  const _TotalBar({
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

/// Scaffold modal bottom sheet untuk picker: judul, search, dan body.
class _PickerSheet extends StatelessWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String> onSearch;
  final Widget body;
  final Widget? leading;

  const _PickerSheet({
    required this.title,
    required this.searchHint,
    required this.onSearch,
    required this.body,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppConstants.paddingM,
            right: AppConstants.paddingM,
            top: AppConstants.paddingM,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Text(title, style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              if (leading != null) leading!,
              Expanded(
                child: PrimaryScrollController(
                  controller: scrollController,
                  child: body,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
