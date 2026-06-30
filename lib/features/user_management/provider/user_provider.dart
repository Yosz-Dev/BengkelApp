import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/data/user_model.dart';
import '../data/user_repository.dart';

/// State management daftar & CRUD user.
class UserProvider extends ChangeNotifier {
  final UserRepository _repo;

  UserProvider({UserRepository? repo}) : _repo = repo ?? UserRepository();

  List<UserModel> _items = [];
  bool _loading = false;

  List<UserModel> get items => _items;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  /// Simpan user (insert / update). Mengembalikan pesan error, atau null bila sukses.
  Future<String?> save(UserModel user) async {
    final exists = await _repo.usernameExists(
      user.username,
      excludeId: user.id,
    );
    if (exists) return 'Username "${user.username}" sudah digunakan';

    if (user.id == null) {
      await _repo.insert(user);
    } else {
      await _repo.update(user);
    }
    await load();
    return null;
  }

  /// Hapus user. Mengembalikan pesan error, atau null bila sukses.
  /// Mencegah penghapusan admin terakhir.
  Future<String?> delete(UserModel user) async {
    if (user.role == AppConstants.roleAdmin) {
      final adminCount = await _repo.countAdmin();
      if (adminCount <= 1) {
        return 'Tidak dapat menghapus admin terakhir';
      }
    }
    await _repo.delete(user.id!);
    await load();
    return null;
  }
}
