import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import 'profil_model.dart';

/// Akses data profil bengkel.
///
/// Saat ini hanya operasi baca (dipakai untuk header struk). CRUD penuh
/// modul Profil akan ditambahkan pada fase berikutnya.
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
}
