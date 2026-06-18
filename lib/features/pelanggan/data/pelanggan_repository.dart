import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import 'pelanggan_model.dart';

/// Akses data CRUD pelanggan servis.
class PelangganRepository {
  final DatabaseHelper _dbHelper;

  PelangganRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<PelangganModel>> getAll({String? query}) async {
    final db = await _dbHelper.database;
    final hasQuery = query != null && query.trim().isNotEmpty;
    final rows = await db.query(
      DbConstants.tablePelanggan,
      where: hasQuery
          ? '${DbConstants.plgNama} LIKE ? OR ${DbConstants.plgNoKendaraan} LIKE ?'
          : null,
      whereArgs: hasQuery ? ['%$query%', '%$query%'] : null,
      orderBy: '${DbConstants.plgNama} COLLATE NOCASE ASC',
    );
    return rows.map(PelangganModel.fromMap).toList();
  }

  Future<int> insert(PelangganModel item) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tablePelanggan, item.toMap());
  }

  Future<int> update(PelangganModel item) async {
    final db = await _dbHelper.database;
    return db.update(
      DbConstants.tablePelanggan,
      item.toMap(),
      where: '${DbConstants.plgId} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DbConstants.tablePelanggan,
      where: '${DbConstants.plgId} = ?',
      whereArgs: [id],
    );
  }
}
