import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/data/user_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/user_provider.dart';
import 'user_form_screen.dart';

/// Daftar user dengan CRUD (khusus admin).
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UserProvider>().load(),
    );
  }

  Future<void> _openForm({UserModel? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
    );
  }

  Future<void> _delete(UserModel user) async {
    final currentId = context.read<AuthProvider>().currentUser?.id;
    if (user.id == currentId) {
      AppSnackbar.error(context, 'Tidak dapat menghapus akun sendiri');
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus User',
      message: 'Hapus user "${user.nama}"?',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final error = await context.read<UserProvider>().delete(user);
    if (!mounted) return;
    if (error != null) {
      AppSnackbar.error(context, error);
    } else {
      AppSnackbar.success(context, 'User dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final currentId = context.watch<AuthProvider>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola User')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: _buildBody(provider, currentId),
    );
  }

  Widget _buildBody(UserProvider provider, int? currentId) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.items.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Belum ada user',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: provider.items.length,
      itemBuilder: (_, i) {
        final user = provider.items[i];
        return _UserCard(
          user: user,
          isSelf: user.id == currentId,
          onEdit: () => _openForm(user: user),
          onDelete: () => _delete(user),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isSelf,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == AppConstants.roleAdmin;
    final roleColor = isAdmin ? AppColors.primary : AppColors.secondary;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.12),
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: roleColor,
          ),
        ),
        title: Row(
          children: [
            Flexible(child: Text(user.nama, style: AppTextStyles.title)),
            if (isSelf) ...[
              const SizedBox(width: 6),
              const Text('(Anda)', style: AppTextStyles.caption),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}', style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
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
