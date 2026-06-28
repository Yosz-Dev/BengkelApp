import '../../../core/database/db_constants.dart';
import 'transaksi_item_model.dart';

/// Header sebuah transaksi (penjualan / servis) beserta daftar itemnya.
///
/// [items] bersifat transien — diisi saat membuat transaksi baru atau
/// saat memuat detail dari database; tidak ikut ke kolom tabel header.
class TransaksiModel {
  /// Tipe transaksi.
  static const String tipePenjualan = 'penjualan';
  static const String tipeServis = 'servis';

  final int? id;
  final String tipe;
  final int? pelangganId;
  final String? pelangganNama; // snapshot
  final double subtotal;
  final double diskon;
  final double pajak;
  final double total;
  final double bayar;
  final double kembalian;
  final int? kasirId;
  final String? kasirNama; // snapshot
  final DateTime createdAt;
  final List<TransaksiItemModel> items;

  const TransaksiModel({
    this.id,
    required this.tipe,
    this.pelangganId,
    this.pelangganNama,
    required this.subtotal,
    this.diskon = 0,
    this.pajak = 0,
    required this.total,
    this.bayar = 0,
    this.kembalian = 0,
    this.kasirId,
    this.kasirNama,
    required this.createdAt,
    this.items = const [],
  });

  factory TransaksiModel.fromMap(
    Map<String, dynamic> map, {
    List<TransaksiItemModel> items = const [],
  }) {
    return TransaksiModel(
      id: map[DbConstants.trxId] as int?,
      tipe: map[DbConstants.trxTipe] as String,
      pelangganId: map[DbConstants.trxPelangganId] as int?,
      pelangganNama: map[DbConstants.trxPelangganNama] as String?,
      subtotal: (map[DbConstants.trxSubtotal] as num?)?.toDouble() ?? 0,
      diskon: (map[DbConstants.trxDiskon] as num?)?.toDouble() ?? 0,
      pajak: (map[DbConstants.trxPajak] as num?)?.toDouble() ?? 0,
      total: (map[DbConstants.trxTotal] as num?)?.toDouble() ?? 0,
      bayar: (map[DbConstants.trxBayar] as num?)?.toDouble() ?? 0,
      kembalian: (map[DbConstants.trxKembalian] as num?)?.toDouble() ?? 0,
      kasirId: map[DbConstants.trxKasirId] as int?,
      kasirNama: map[DbConstants.trxKasirNama] as String?,
      createdAt:
          DateTime.tryParse(map[DbConstants.trxCreatedAt] as String? ?? '') ??
              DateTime.now(),
      items: items,
    );
  }

  /// Map untuk kolom tabel header (tanpa [items]).
  Map<String, dynamic> toMapHeader() {
    return {
      if (id != null) DbConstants.trxId: id,
      DbConstants.trxTipe: tipe,
      DbConstants.trxPelangganId: pelangganId,
      DbConstants.trxPelangganNama: pelangganNama,
      DbConstants.trxSubtotal: subtotal,
      DbConstants.trxDiskon: diskon,
      DbConstants.trxPajak: pajak,
      DbConstants.trxTotal: total,
      DbConstants.trxBayar: bayar,
      DbConstants.trxKembalian: kembalian,
      DbConstants.trxKasirId: kasirId,
      DbConstants.trxKasirNama: kasirNama,
      DbConstants.trxCreatedAt: createdAt.toIso8601String(),
    };
  }
}
