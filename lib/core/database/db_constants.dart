/// Nama tabel & kolom database SQLite.
class DbConstants {
  DbConstants._();

  static const String databaseName = 'pos_bengkel.db';
  static const int databaseVersion = 1;

  // ---- Tabel users ----
  static const String tableUsers = 'users';
  static const String userId = 'id';
  static const String userUsername = 'username';
  static const String userPassword = 'password';
  static const String userNama = 'nama';
  static const String userRole = 'role'; // admin / kasir
  static const String userCreatedAt = 'created_at';

  // ---- Tabel shop_profile ----
  static const String tableProfile = 'shop_profile';
  static const String profileId = 'id';
  static const String profileNama = 'nama';
  static const String profileAlamat = 'alamat';
  static const String profileTelepon = 'telepon';

  // ---- Tabel spareparts ----
  static const String tableSparepart = 'spareparts';
  static const String spId = 'id';
  static const String spKode = 'kode';
  static const String spNama = 'nama';
  static const String spStok = 'stok';
  static const String spHargaBeli = 'harga_beli';
  static const String spHargaJual = 'harga_jual';
  static const String spSatuan = 'satuan';
  static const String spCreatedAt = 'created_at';
  static const String spUpdatedAt = 'updated_at';

  // ---- Tabel jasa ----
  static const String tableJasa = 'jasa';
  static const String jasaId = 'id';
  static const String jasaNama = 'nama';
  static const String jasaHarga = 'harga';
  static const String jasaDeskripsi = 'deskripsi';
  static const String jasaCreatedAt = 'created_at';

  // ---- Tabel pelanggan ----
  static const String tablePelanggan = 'pelanggan';
  static const String plgId = 'id';
  static const String plgNama = 'nama';
  static const String plgNoHp = 'no_hp';
  static const String plgNoKendaraan = 'no_kendaraan';
  static const String plgJenisKendaraan = 'jenis_kendaraan';
  static const String plgCreatedAt = 'created_at';

  // ---- Tabel transactions ----
  static const String tableTransaksi = 'transactions';
  static const String trxId = 'id';
  static const String trxTipe = 'tipe'; // penjualan / servis
  static const String trxPelangganId = 'pelanggan_id';
  static const String trxPelangganNama = 'pelanggan_nama'; // snapshot
  static const String trxSubtotal = 'subtotal';
  static const String trxDiskon = 'diskon';
  static const String trxPajak = 'pajak';
  static const String trxTotal = 'total';
  static const String trxBayar = 'bayar';
  static const String trxKembalian = 'kembalian';
  static const String trxKasirId = 'kasir_id';
  static const String trxKasirNama = 'kasir_nama'; // snapshot
  static const String trxCreatedAt = 'created_at';

  // ---- Tabel transaction_items ----
  static const String tableTransaksiItem = 'transaction_items';
  static const String itemId = 'id';
  static const String itemTransaksiId = 'transaction_id';
  static const String itemJenis = 'jenis_item'; // sparepart / jasa
  static const String itemRefId = 'item_id';
  static const String itemNama = 'nama_snapshot';
  static const String itemHarga = 'harga_snapshot';
  static const String itemQty = 'qty';
  static const String itemSubtotal = 'subtotal';
}
