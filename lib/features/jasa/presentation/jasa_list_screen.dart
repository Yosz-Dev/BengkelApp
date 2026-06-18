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
import '../data/jasa_model.dart';
import '../provider/jasa_provider.dart';
import 'jasa_form_screen.dart';

/// Daftar jasa servis (FR-03).
class JasaListScreen extends StatefulWidget {
  const JasaListScreen({super.key});

  @override
  State<JasaListScreen> createState() => _JasaListScreenState();
}

class _JasaListScreenState extends State<JasaListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<JasaProvider>().load(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({JasaModel? jasa}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JasaFormScreen(jasa: jasa)),
    );
  }

  Future<void> _delete(JasaModel item) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Jasa',
      message: 'Hapus "${item.nama}"? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<JasaProvider>().delete(item.id!);
    if (!mounted) return;
    AppSnackbar.success(context, 'Jasa dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final provider = context.watch<JasaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Jasa')),
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
                context.read<JasaProvider>().search(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari nama jasa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<JasaProvider>().search('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(child: _buildBody(provider, isAdmin)),
        ],
      ),
    );
  }

  Widget _buildBody(JasaProvider provider, bool isAdmin) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.items.isEmpty) {
      return const EmptyState(
        icon: Icons.handyman_outlined,
        message: 'Belum ada jasa',
        subtitle: 'Tekan tombol "Tambah" untuk menambah data.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: provider.items.length,
      itemBuilder: (_, i) => _JasaCard(
        item: provider.items[i],
        isAdmin: isAdmin,
        onEdit: () => _openForm(jasa: provider.items[i]),
        onDelete: () => _delete(provider.items[i]),
      ),
    );
  }
}

class _JasaCard extends StatelessWidget {
  final JasaModel item;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JasaCard({
    required this.item,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                  if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.deskripsi!, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    Formatter.rupiah(item.harga),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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
