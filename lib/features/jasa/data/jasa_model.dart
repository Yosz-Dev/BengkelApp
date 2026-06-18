import '../../../core/database/db_constants.dart';

/// Model data jasa servis.
class JasaModel {
  final int? id;
  final String nama;
  final double harga;
  final String? deskripsi;
  final DateTime? createdAt;

  const JasaModel({
    this.id,
    required this.nama,
    this.harga = 0,
    this.deskripsi,
    this.createdAt,
  });

  factory JasaModel.fromMap(Map<String, dynamic> map) {
    final created = map[DbConstants.jasaCreatedAt] as String?;
    return JasaModel(
      id: map[DbConstants.jasaId] as int?,
      nama: map[DbConstants.jasaNama] as String,
      harga: (map[DbConstants.jasaHarga] as num?)?.toDouble() ?? 0,
      deskripsi: map[DbConstants.jasaDeskripsi] as String?,
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.jasaId: id,
      DbConstants.jasaNama: nama,
      DbConstants.jasaHarga: harga,
      DbConstants.jasaDeskripsi: deskripsi,
      DbConstants.jasaCreatedAt:
          (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  JasaModel copyWith({
    int? id,
    String? nama,
    double? harga,
    String? deskripsi,
    DateTime? createdAt,
  }) {
    return JasaModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
