import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/provider/auth_provider.dart';
import '../data/sparepart_model.dart';
import '../provider/sparepart_provider.dart';
import 'sparepart_form_screen.dart';

/// Daftar sparepart dengan pencarian (FR-02).
class SparepartListScreen extends StatefulWidget {
  const SparepartListScreen({super.key});

  @override
  State<SparepartListScreen> createState() => _SparepartListScreenState();
}

class _SparepartListScreenState extends State<SparepartListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SparepartProvider>().load(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({SparepartModel? sparepart}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SparepartFormScreen(sparepart: sparepart),
      ),
    );
  }

  Future<void> _delete(SparepartModel item) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Sparepart',
      message: 'Hapus "${item.nama}"? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<SparepartProvider>().delete(item.id!);
    if (!mounted) return;
    AppSnackbar.success(context, 'Sparepart dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final provider = context.watch<SparepartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Sparepart')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
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
                hintText: 'Cari nama atau kode sparepart...',
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
          Expanded(
            child: _buildBody(provider, isAdmin),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SparepartProvider provider, bool isAdmin) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.items.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada sparepart',
        subtitle: 'Tekan tombol "Tambah" untuk menambah data.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: provider.items.length,
      itemBuilder: (_, i) => _SparepartCard(
        item: provider.items[i],
        isAdmin: isAdmin,
        onEdit: () => _openForm(sparepart: provider.items[i]),
        onDelete: () => _delete(provider.items[i]),
      ),
    );
  }
}

class _SparepartCard extends StatelessWidget {
  final SparepartModel item;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SparepartCard({
    required this.item,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = item.stok <= 5;
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
                  if (item.kode != null && item.kode!.isNotEmpty)
                    Text('Kode: ${item.kode}', style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  Text(
                    Formatter.rupiah(item.hargaJual),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (lowStock ? AppColors.error : AppColors.success)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Stok: ${item.stok}${item.satuan != null && item.satuan!.isNotEmpty ? ' ${item.satuan}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: lowStock ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              Column(
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
          ],
        ),
      ),
    );
  }
}
