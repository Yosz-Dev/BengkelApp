import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import 'jasa_model.dart';

/// Akses data CRUD jasa servis.
class JasaRepository {
  final DatabaseHelper _dbHelper;

  JasaRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<JasaModel>> getAll({String? query}) async {
    final db = await _dbHelper.database;
    final hasQuery = query != null && query.trim().isNotEmpty;
    final rows = await db.query(
      DbConstants.tableJasa,
      where: hasQuery ? '${DbConstants.jasaNama} LIKE ?' : null,
      whereArgs: hasQuery ? ['%$query%'] : null,
      orderBy: '${DbConstants.jasaNama} COLLATE NOCASE ASC',
    );
    return rows.map(JasaModel.fromMap).toList();
  }

  Future<int> insert(JasaModel item) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tableJasa, item.toMap());
  }

  Future<int> update(JasaModel item) async {
    final db = await _dbHelper.database;
    return db.update(
      DbConstants.tableJasa,
      item.toMap(),
      where: '${DbConstants.jasaId} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DbConstants.tableJasa,
      where: '${DbConstants.jasaId} = ?',
      whereArgs: [id],
    );
  }
}
