import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import 'sparepart_model.dart';

/// Akses data CRUD sparepart.
class SparepartRepository {
  final DatabaseHelper _dbHelper;

  SparepartRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<SparepartModel>> getAll({String? query}) async {
    final db = await _dbHelper.database;
    final hasQuery = query != null && query.trim().isNotEmpty;
    final rows = await db.query(
      DbConstants.tableSparepart,
      where: hasQuery
          ? '${DbConstants.spNama} LIKE ? OR ${DbConstants.spKode} LIKE ?'
          : null,
      whereArgs: hasQuery ? ['%$query%', '%$query%'] : null,
      orderBy: '${DbConstants.spNama} COLLATE NOCASE ASC',
    );
    return rows.map(SparepartModel.fromMap).toList();
  }

  Future<SparepartModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DbConstants.tableSparepart,
      where: '${DbConstants.spId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SparepartModel.fromMap(rows.first);
  }

  Future<int> insert(SparepartModel item) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tableSparepart, item.toMap());
  }

  Future<int> update(SparepartModel item) async {
    final db = await _dbHelper.database;
    return db.update(
      DbConstants.tableSparepart,
      item.toMap(),
      where: '${DbConstants.spId} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DbConstants.tableSparepart,
      where: '${DbConstants.spId} = ?',
      whereArgs: [id],
    );
  }

  /// Mengurangi stok (dipakai saat transaksi). Aman dari nilai negatif.
  Future<void> decreaseStock(int id, int qty, {Transaction? txn}) async {
    final executor = txn ?? await _dbHelper.database;
    await executor.rawUpdate(
      '''
      UPDATE ${DbConstants.tableSparepart}
      SET ${DbConstants.spStok} = MAX(0, ${DbConstants.spStok} - ?),
          ${DbConstants.spUpdatedAt} = ?
      WHERE ${DbConstants.spId} = ?
      ''',
      [qty, DateTime.now().toIso8601String(), id],
    );
  }
}
