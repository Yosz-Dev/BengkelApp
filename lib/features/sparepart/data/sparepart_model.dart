import '../../../core/database/db_constants.dart';

/// Model data sparepart.
class SparepartModel {
  final int? id;
  final String? kode;
  final String nama;
  final int stok;
  final double hargaBeli;
  final double hargaJual;
  final String? satuan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SparepartModel({
    this.id,
    this.kode,
    required this.nama,
    this.stok = 0,
    this.hargaBeli = 0,
    this.hargaJual = 0,
    this.satuan,
    this.createdAt,
    this.updatedAt,
  });

  factory SparepartModel.fromMap(Map<String, dynamic> map) {
    return SparepartModel(
      id: map[DbConstants.spId] as int?,
      kode: map[DbConstants.spKode] as String?,
      nama: map[DbConstants.spNama] as String,
      stok: (map[DbConstants.spStok] as num?)?.toInt() ?? 0,
      hargaBeli: (map[DbConstants.spHargaBeli] as num?)?.toDouble() ?? 0,
      hargaJual: (map[DbConstants.spHargaJual] as num?)?.toDouble() ?? 0,
      satuan: map[DbConstants.spSatuan] as String?,
      createdAt: _parse(map[DbConstants.spCreatedAt] as String?),
      updatedAt: _parse(map[DbConstants.spUpdatedAt] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();
    return {
      if (id != null) DbConstants.spId: id,
      DbConstants.spKode: kode,
      DbConstants.spNama: nama,
      DbConstants.spStok: stok,
      DbConstants.spHargaBeli: hargaBeli,
      DbConstants.spHargaJual: hargaJual,
      DbConstants.spSatuan: satuan,
      DbConstants.spCreatedAt:
          (createdAt ?? DateTime.now()).toIso8601String(),
      DbConstants.spUpdatedAt: now,
    };
  }

  SparepartModel copyWith({
    int? id,
    String? kode,
    String? nama,
    int? stok,
    double? hargaBeli,
    double? hargaJual,
    String? satuan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SparepartModel(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      stok: stok ?? this.stok,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      satuan: satuan ?? this.satuan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parse(String? value) =>
      value != null ? DateTime.tryParse(value) : null;
}
