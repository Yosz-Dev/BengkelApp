import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import '../../sparepart/data/sparepart_repository.dart';
import 'transaksi_item_model.dart';
import 'transaksi_model.dart';

/// Akses data transaksi (penjualan & servis).
class TransaksiRepository {
  final DatabaseHelper _dbHelper;
  final SparepartRepository _sparepartRepo;

  TransaksiRepository({
    DatabaseHelper? dbHelper,
    SparepartRepository? sparepartRepo,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _sparepartRepo = sparepartRepo ?? SparepartRepository();

  /// Menyimpan transaksi beserta itemnya secara atomik.
  ///
  /// Dalam satu SQL transaction: insert header → insert tiap item →
  /// kurangi stok untuk item sparepart. Jika ada kegagalan, seluruh
  /// perubahan di-rollback otomatis. Mengembalikan id transaksi baru.
  Future<int> createTransaksi(TransaksiModel trx) async {
    final db = await _dbHelper.database;
    return db.transaction<int>((txn) async {
      final trxId = await txn.insert(
        DbConstants.tableTransaksi,
        trx.toMapHeader(),
      );

      for (final item in trx.items) {
        await txn.insert(
          DbConstants.tableTransaksiItem,
          item.copyWith(transaksiId: trxId).toMap(),
        );

        if (item.jenis == TransaksiItemModel.jenisSparepart &&
            item.refId != null) {
          await _sparepartRepo.decreaseStock(item.refId!, item.qty, txn: txn);
        }
      }

      return trxId;
    });
  }

  /// Daftar transaksi (header saja) untuk layar Riwayat.
  ///
  /// [date] memfilter berdasarkan tanggal (mengabaikan jam). [tipe] memfilter
  /// jenis transaksi (penjualan / servis). Terbaru tampil paling atas.
  Future<List<TransaksiModel>> getAll({DateTime? date, String? tipe}) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];

    if (date != null) {
      final prefix =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      where.add('${DbConstants.trxCreatedAt} LIKE ?');
      args.add('$prefix%');
    }
    if (tipe != null && tipe.isNotEmpty) {
      where.add('${DbConstants.trxTipe} = ?');
      args.add(tipe);
    }

    final rows = await db.query(
      DbConstants.tableTransaksi,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '${DbConstants.trxCreatedAt} DESC',
    );
    return rows.map((m) => TransaksiModel.fromMap(m)).toList();
  }

  /// Mengambil satu transaksi lengkap dengan itemnya. Null bila tidak ada.
  Future<TransaksiModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final headerRows = await db.query(
      DbConstants.tableTransaksi,
      where: '${DbConstants.trxId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (headerRows.isEmpty) return null;

    final itemRows = await db.query(
      DbConstants.tableTransaksiItem,
      where: '${DbConstants.itemTransaksiId} = ?',
      whereArgs: [id],
      orderBy: '${DbConstants.itemId} ASC',
    );
    final items = itemRows.map(TransaksiItemModel.fromMap).toList();

    return TransaksiModel.fromMap(headerRows.first, items: items);
  }
}
