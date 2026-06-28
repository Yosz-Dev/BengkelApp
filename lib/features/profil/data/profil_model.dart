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
}
