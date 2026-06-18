import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../data/session_service.dart';
import '../data/user_model.dart';

/// State autentikasi: login, auto-login, dan logout.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final SessionService _session;

  AuthProvider({AuthRepository? repo, SessionService? session})
      : _repo = repo ?? AuthRepository(),
        _session = session ?? SessionService();

  UserModel? _currentUser;
  bool _loading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get loading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Login dengan username & password. Return true bila berhasil.
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _repo.login(username.trim(), password);
      if (user == null) return false;
      _currentUser = user;
      if (user.id != null) {
        await _session.saveSession(user.id!);
      }
      return true;
    } finally {
      _setLoading(false);
    }
  }

  /// Coba memulihkan sesi tersimpan. Return true bila masih login.
  Future<bool> tryAutoLogin() async {
    final userId = await _session.getUserId();
    if (userId == null) return false;
    final user = await _repo.getById(userId);
    if (user == null) {
      await _session.clear();
      return false;
    }
    _currentUser = user;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _session.clear();
    _currentUser = null;
    notifyListeners();
  }
}
