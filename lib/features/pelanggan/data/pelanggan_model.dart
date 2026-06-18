import '../../../core/database/db_constants.dart';

/// Model data pelanggan servis.
class PelangganModel {
  final int? id;
  final String nama;
  final String? noHp;
  final String? noKendaraan;
  final String? jenisKendaraan;
  final DateTime? createdAt;

  const PelangganModel({
    this.id,
    required this.nama,
    this.noHp,
    this.noKendaraan,
    this.jenisKendaraan,
    this.createdAt,
  });

  factory PelangganModel.fromMap(Map<String, dynamic> map) {
    final created = map[DbConstants.plgCreatedAt] as String?;
    return PelangganModel(
      id: map[DbConstants.plgId] as int?,
      nama: map[DbConstants.plgNama] as String,
      noHp: map[DbConstants.plgNoHp] as String?,
      noKendaraan: map[DbConstants.plgNoKendaraan] as String?,
      jenisKendaraan: map[DbConstants.plgJenisKendaraan] as String?,
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.plgId: id,
      DbConstants.plgNama: nama,
      DbConstants.plgNoHp: noHp,
      DbConstants.plgNoKendaraan: noKendaraan,
      DbConstants.plgJenisKendaraan: jenisKendaraan,
      DbConstants.plgCreatedAt:
          (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  PelangganModel copyWith({
    int? id,
    String? nama,
    String? noHp,
    String? noKendaraan,
    String? jenisKendaraan,
    DateTime? createdAt,
  }) {
    return PelangganModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      noKendaraan: noKendaraan ?? this.noKendaraan,
      jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
