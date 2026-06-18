import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'db_constants.dart';

/// Singleton pengelola koneksi & skema database SQLite.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DbConstants.databaseName);
    return openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onConfigure: (db) async {
        // Aktifkan foreign key constraint.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableUsers} (
        ${DbConstants.userId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.userUsername} TEXT NOT NULL UNIQUE,
        ${DbConstants.userPassword} TEXT NOT NULL,
        ${DbConstants.userNama} TEXT NOT NULL,
        ${DbConstants.userRole} TEXT NOT NULL,
        ${DbConstants.userCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableProfile} (
        ${DbConstants.profileId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.profileNama} TEXT NOT NULL,
        ${DbConstants.profileAlamat} TEXT,
        ${DbConstants.profileTelepon} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableSparepart} (
        ${DbConstants.spId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.spKode} TEXT,
        ${DbConstants.spNama} TEXT NOT NULL,
        ${DbConstants.spStok} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.spHargaBeli} REAL NOT NULL DEFAULT 0,
        ${DbConstants.spHargaJual} REAL NOT NULL DEFAULT 0,
        ${DbConstants.spSatuan} TEXT,
        ${DbConstants.spCreatedAt} TEXT NOT NULL,
        ${DbConstants.spUpdatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableJasa} (
        ${DbConstants.jasaId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.jasaNama} TEXT NOT NULL,
        ${DbConstants.jasaHarga} REAL NOT NULL DEFAULT 0,
        ${DbConstants.jasaDeskripsi} TEXT,
        ${DbConstants.jasaCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tablePelanggan} (
        ${DbConstants.plgId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.plgNama} TEXT NOT NULL,
        ${DbConstants.plgNoHp} TEXT,
        ${DbConstants.plgNoKendaraan} TEXT,
        ${DbConstants.plgJenisKendaraan} TEXT,
        ${DbConstants.plgCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableTransaksi} (
        ${DbConstants.trxId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.trxTipe} TEXT NOT NULL,
        ${DbConstants.trxPelangganId} INTEGER,
        ${DbConstants.trxPelangganNama} TEXT,
        ${DbConstants.trxSubtotal} REAL NOT NULL DEFAULT 0,
        ${DbConstants.trxDiskon} REAL NOT NULL DEFAULT 0,
        ${DbConstants.trxPajak} REAL NOT NULL DEFAULT 0,
        ${DbConstants.trxTotal} REAL NOT NULL DEFAULT 0,
        ${DbConstants.trxBayar} REAL NOT NULL DEFAULT 0,
        ${DbConstants.trxKembalian} REAL NOT NULL DEFAULT 0,
        ${DbConstants.trxKasirId} INTEGER,
        ${DbConstants.trxKasirNama} TEXT,
        ${DbConstants.trxCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableTransaksiItem} (
        ${DbConstants.itemId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.itemTransaksiId} INTEGER NOT NULL,
        ${DbConstants.itemJenis} TEXT NOT NULL,
        ${DbConstants.itemRefId} INTEGER,
        ${DbConstants.itemNama} TEXT NOT NULL,
        ${DbConstants.itemHarga} REAL NOT NULL DEFAULT 0,
        ${DbConstants.itemQty} INTEGER NOT NULL DEFAULT 1,
        ${DbConstants.itemSubtotal} REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (${DbConstants.itemTransaksiId})
          REFERENCES ${DbConstants.tableTransaksi} (${DbConstants.trxId})
          ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  /// Data awal: akun admin default & profil bengkel kosong.
  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert(DbConstants.tableUsers, {
      DbConstants.userUsername: 'admin',
      DbConstants.userPassword: 'admin123',
      DbConstants.userNama: 'Administrator',
      DbConstants.userRole: AppConstants.roleAdmin,
      DbConstants.userCreatedAt: now,
    });

    await db.insert(DbConstants.tableProfile, {
      DbConstants.profileNama: AppConstants.appName,
      DbConstants.profileAlamat: '',
      DbConstants.profileTelepon: '',
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
