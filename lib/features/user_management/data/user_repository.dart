import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import '../../auth/data/user_model.dart';

/// Akses data CRUD user (admin / kasir) untuk modul Kelola User.
class UserRepository {
  final DatabaseHelper _dbHelper;

  UserRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<UserModel>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DbConstants.tableUsers,
      orderBy: '${DbConstants.userNama} COLLATE NOCASE ASC',
    );
    return rows.map(UserModel.fromMap).toList();
  }

  /// Cek apakah [username] sudah dipakai user lain (selain [excludeId]).
  Future<bool> usernameExists(String username, {int? excludeId}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DbConstants.tableUsers,
      where: excludeId == null
          ? '${DbConstants.userUsername} = ?'
          : '${DbConstants.userUsername} = ? AND ${DbConstants.userId} != ?',
      whereArgs:
          excludeId == null ? [username] : [username, excludeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> insert(UserModel user) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tableUsers, user.toMap());
  }

  Future<int> update(UserModel user) async {
    final db = await _dbHelper.database;
    return db.update(
      DbConstants.tableUsers,
      user.toMap(),
      where: '${DbConstants.userId} = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DbConstants.tableUsers,
      where: '${DbConstants.userId} = ?',
      whereArgs: [id],
    );
  }

  /// Jumlah admin saat ini (untuk mencegah menghapus admin terakhir).
  Future<int> countAdmin() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DbConstants.tableUsers,
      where: '${DbConstants.userRole} = ?',
      whereArgs: [AppConstants.roleAdmin],
    );
    return rows.length;
  }
}
