import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import 'profil_model.dart';

/// Akses data profil bengkel (baca & simpan).
class ProfilRepository {
  final DatabaseHelper _dbHelper;

  ProfilRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengambil profil bengkel (baris pertama). Null bila belum ada.
  Future<ProfilModel?> getProfile() async {
    final db = await _dbHelper.database;
    final rows = await db.query(DbConstants.tableProfile, limit: 1);
    if (rows.isEmpty) return null;
    return ProfilModel.fromMap(rows.first);
  }

  /// Menyimpan profil bengkel (update bila sudah ada id, insert bila belum).
  Future<void> save(ProfilModel profil) async {
    final db = await _dbHelper.database;
    if (profil.id != null) {
      await db.update(
        DbConstants.tableProfile,
        profil.toMap(),
        where: '${DbConstants.profileId} = ?',
        whereArgs: [profil.id],
      );
    } else {
      await db.insert(DbConstants.tableProfile, profil.toMap());
    }
  }
}
