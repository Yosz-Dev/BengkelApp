import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/pelanggan_model.dart';
import '../provider/pelanggan_provider.dart';
import 'pelanggan_form_screen.dart';

/// Daftar pelanggan servis (FR-04, akses admin).
class PelangganListScreen extends StatefulWidget {
  const PelangganListScreen({super.key});

  @override
  State<PelangganListScreen> createState() => _PelangganListScreenState();
}

class _PelangganListScreenState extends State<PelangganListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PelangganProvider>().load(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({PelangganModel? pelanggan}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PelangganFormScreen(pelanggan: pelanggan),
      ),
    );
  }

  Future<void> _delete(PelangganModel item) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Pelanggan',
      message: 'Hapus "${item.nama}"? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<PelangganProvider>().delete(item.id!);
    if (!mounted) return;
    AppSnackbar.success(context, 'Pelanggan dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PelangganProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Pelanggan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                context.read<PelangganProvider>().search(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau no. kendaraan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<PelangganProvider>().search('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(PelangganProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.items.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Belum ada pelanggan',
        subtitle: 'Tekan tombol "Tambah" untuk menambah data.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: provider.items.length,
      itemBuilder: (_, i) => _PelangganCard(
        item: provider.items[i],
        onEdit: () => _openForm(pelanggan: provider.items[i]),
        onDelete: () => _delete(provider.items[i]),
      ),
    );
  }
}

class _PelangganCard extends StatelessWidget {
  final PelangganModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PelangganCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (item.noKendaraan != null && item.noKendaraan!.isNotEmpty)
        item.noKendaraan!,
      if (item.jenisKendaraan != null && item.jenisKendaraan!.isNotEmpty)
        item.jenisKendaraan!,
    ].join(' • ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, color: AppColors.textOnPrimary),
        ),
        title: Text(item.nama, style: AppTextStyles.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isNotEmpty) Text(details),
            if (item.noHp != null && item.noHp!.isNotEmpty)
              Text('HP: ${item.noHp}', style: AppTextStyles.caption),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.info),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
