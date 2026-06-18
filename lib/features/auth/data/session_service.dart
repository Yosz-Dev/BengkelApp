import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan sesi login pada SharedPreferences (auto-login).
class SessionService {
  static const String _keyUserId = 'session_user_id';

  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}
