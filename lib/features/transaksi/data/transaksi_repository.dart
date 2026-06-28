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
}
