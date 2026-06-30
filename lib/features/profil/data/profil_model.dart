import '../../../core/database/db_constants.dart';

/// Data profil bengkel (nama, alamat, telepon) untuk header struk & laporan.
class ProfilModel {
  final int? id;
  final String nama;
  final String? alamat;
  final String? telepon;

  const ProfilModel({
    this.id,
    required this.nama,
    this.alamat,
    this.telepon,
  });

  factory ProfilModel.fromMap(Map<String, dynamic> map) {
    return ProfilModel(
      id: map[DbConstants.profileId] as int?,
      nama: map[DbConstants.profileNama] as String,
      alamat: map[DbConstants.profileAlamat] as String?,
      telepon: map[DbConstants.profileTelepon] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.profileId: id,
      DbConstants.profileNama: nama,
      DbConstants.profileAlamat: alamat,
      DbConstants.profileTelepon: telepon,
    };
  }

  ProfilModel copyWith({
    int? id,
    String? nama,
    String? alamat,
    String? telepon,
  }) {
    return ProfilModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
    );
  }
}
