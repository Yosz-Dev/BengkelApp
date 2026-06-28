import '../../../core/database/db_constants.dart';

/// Satu item dalam sebuah transaksi (snapshot sparepart / jasa).
///
/// Nama & harga disimpan sebagai snapshot agar riwayat tetap akurat
/// meskipun data master berubah di kemudian hari.
class TransaksiItemModel {
  /// Jenis item.
  static const String jenisSparepart = 'sparepart';
  static const String jenisJasa = 'jasa';

  final int? id;
  final int? transaksiId;
  final String jenis; // sparepart / jasa
  final int? refId; // id sparepart / jasa asal
  final String nama; // snapshot
  final double harga; // snapshot
  final int qty;
  final double subtotal;

  const TransaksiItemModel({
    this.id,
    this.transaksiId,
    required this.jenis,
    this.refId,
    required this.nama,
    required this.harga,
    this.qty = 1,
    required this.subtotal,
  });

  factory TransaksiItemModel.fromMap(Map<String, dynamic> map) {
    return TransaksiItemModel(
      id: map[DbConstants.itemId] as int?,
      transaksiId: map[DbConstants.itemTransaksiId] as int?,
      jenis: map[DbConstants.itemJenis] as String,
      refId: map[DbConstants.itemRefId] as int?,
      nama: map[DbConstants.itemNama] as String,
      harga: (map[DbConstants.itemHarga] as num?)?.toDouble() ?? 0,
      qty: (map[DbConstants.itemQty] as num?)?.toInt() ?? 1,
      subtotal: (map[DbConstants.itemSubtotal] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.itemId: id,
      if (transaksiId != null) DbConstants.itemTransaksiId: transaksiId,
      DbConstants.itemJenis: jenis,
      DbConstants.itemRefId: refId,
      DbConstants.itemNama: nama,
      DbConstants.itemHarga: harga,
      DbConstants.itemQty: qty,
      DbConstants.itemSubtotal: subtotal,
    };
  }

  TransaksiItemModel copyWith({
    int? id,
    int? transaksiId,
    String? jenis,
    int? refId,
    String? nama,
    double? harga,
    int? qty,
    double? subtotal,
  }) {
    return TransaksiItemModel(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      jenis: jenis ?? this.jenis,
      refId: refId ?? this.refId,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
