import '../../../core/constants/app_constants.dart';
import '../../../core/database/db_constants.dart';

/// Model data user (admin / kasir).
class UserModel {
  final int? id;
  final String username;
  final String password;
  final String nama;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role == AppConstants.roleAdmin;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final created = map[DbConstants.userCreatedAt] as String?;
    return UserModel(
      id: map[DbConstants.userId] as int?,
      username: map[DbConstants.userUsername] as String,
      password: map[DbConstants.userPassword] as String,
      nama: map[DbConstants.userNama] as String,
      role: map[DbConstants.userRole] as String,
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.userId: id,
      DbConstants.userUsername: username,
      DbConstants.userPassword: password,
      DbConstants.userNama: nama,
      DbConstants.userRole: role,
      DbConstants.userCreatedAt:
          (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? nama,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
