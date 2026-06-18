import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import 'user_model.dart';

/// Akses data autentikasi ke tabel users.
class AuthRepository {
  final DatabaseHelper _dbHelper;

  AuthRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengembalikan user bila username & password cocok, selain itu null.
  Future<UserModel?> login(String username, String password) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DbConstants.tableUsers,
      where: '${DbConstants.userUsername} = ? AND ${DbConstants.userPassword} = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  /// Mengambil user berdasarkan id (dipakai saat auto-login).
  Future<UserModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DbConstants.tableUsers,
      where: '${DbConstants.userId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }
}
