import '../../../core/database/database_helper.dart';
import '../../../core/database/db_constants.dart';
import '../../transaksi/data/transaksi_model.dart';
import 'laporan_model.dart';

/// Akses data agregat untuk modul Laporan (FR-08).
class LaporanRepository {
  final DatabaseHelper _dbHelper;

  LaporanRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Ringkasan pendapatan untuk satu hari [date].
  Future<RingkasanPendapatan> pendapatanHarian(DateTime date) {
    final prefix =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return _ringkasan('$prefix%');
  }

  /// Ringkasan pendapatan untuk satu bulan ([year]-[month]).
  Future<RingkasanPendapatan> pendapatanBulanan(int year, int month) {
    final prefix =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}';
    return _ringkasan('$prefix%');
  }

  /// Rincian pendapatan per hari dalam satu bulan ([year]-[month]).
  Future<List<PendapatanPerHari>> rincianBulanan(int year, int month) async {
    final db = await _dbHelper.database;
    final prefix =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}';
    final rows = await db.rawQuery(
      '''
      SELECT substr(${DbConstants.trxCreatedAt}, 1, 10) AS tgl,
             SUM(${DbConstants.trxTotal}) AS total,
             COUNT(*) AS jumlah
      FROM ${DbConstants.tableTransaksi}
      WHERE ${DbConstants.trxCreatedAt} LIKE ?
      GROUP BY tgl
      ORDER BY tgl ASC
      ''',
      ['$prefix%'],
    );

    return rows.map((r) {
      return PendapatanPerHari(
        tanggal: DateTime.tryParse(r['tgl'] as String? ?? '') ??
            DateTime(year, month),
        total: (r['total'] as num?)?.toDouble() ?? 0,
        jumlah: (r['jumlah'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  /// Agregasi pendapatan berdasarkan pola tanggal ISO (mis. "2026-06%").
  Future<RingkasanPendapatan> _ringkasan(String pattern) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT ${DbConstants.trxTipe} AS tipe,
             SUM(${DbConstants.trxTotal}) AS total,
             COUNT(*) AS jumlah
      FROM ${DbConstants.tableTransaksi}
      WHERE ${DbConstants.trxCreatedAt} LIKE ?
      GROUP BY ${DbConstants.trxTipe}
      ''',
      [pattern],
    );

    double penjualan = 0;
    double servis = 0;
    int jumlah = 0;
    for (final r in rows) {
      final tipe = r['tipe'] as String?;
      final total = (r['total'] as num?)?.toDouble() ?? 0;
      jumlah += (r['jumlah'] as num?)?.toInt() ?? 0;
      if (tipe == TransaksiModel.tipeServis) {
        servis += total;
      } else {
        penjualan += total;
      }
    }

    return RingkasanPendapatan(
      totalPenjualan: penjualan,
      totalServis: servis,
      jumlahTransaksi: jumlah,
    );
  }
}
