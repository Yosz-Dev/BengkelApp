import 'package:flutter/foundation.dart';

import '../../../core/utils/transaction_calculator.dart';
import '../../auth/data/user_model.dart';
import '../../jasa/data/jasa_model.dart';
import '../../pelanggan/data/pelanggan_model.dart';
import '../../sparepart/data/sparepart_model.dart';
import '../data/cart_item.dart';
import '../data/jasa_cart_item.dart';
import '../data/transaksi_item_model.dart';
import '../data/transaksi_model.dart';
import '../data/transaksi_repository.dart';

/// State transaksi servis: pelanggan (opsional), daftar jasa & sparepart
/// terpakai, perhitungan total, dan proses checkout.
class ServisProvider extends ChangeNotifier {
  final TransaksiRepository _repo;

  ServisProvider({TransaksiRepository? repo})
      : _repo = repo ?? TransaksiRepository();

  PelangganModel? _pelanggan;
  final List<JasaCartItem> _jasaItems = [];
  final List<CartItem> _sparepartItems = [];
  bool _processing = false;

  PelangganModel? get pelanggan => _pelanggan;
  List<JasaCartItem> get jasaItems => List.unmodifiable(_jasaItems);
  List<CartItem> get sparepartItems => List.unmodifiable(_sparepartItems);
  bool get processing => _processing;

  /// Kosong bila belum ada jasa maupun sparepart.
  bool get isEmpty => _jasaItems.isEmpty && _sparepartItems.isEmpty;

  int get itemCount =>
      _jasaItems.fold(0, (s, e) => s + e.qty) +
      _sparepartItems.fold(0, (s, e) => s + e.qty);

  double get subtotal =>
      _jasaItems.fold(0.0, (s, e) => s + e.subtotal) +
      _sparepartItems.fold(0.0, (s, e) => s + e.subtotal);

  TransactionResult get calc => TransactionCalculator.calculate(subtotal);

  // ---- Pelanggan ----
  void setPelanggan(PelangganModel? value) {
    _pelanggan = value;
    notifyListeners();
  }

  void clearPelanggan() => setPelanggan(null);

  // ---- Jasa ----
  int jasaQtyOf(int jasaId) {
    for (final e in _jasaItems) {
      if (e.jasa.id == jasaId) return e.qty;
    }
    return 0;
  }

  void addJasa(JasaModel jasa) {
    final i = _jasaIndex(jasa.id);
    if (i == -1) {
      _jasaItems.add(JasaCartItem(jasa: jasa));
    } else {
      _jasaItems[i].qty++;
    }
    notifyListeners();
  }

  void incJasa(int jasaId) {
    final i = _jasaIndex(jasaId);
    if (i == -1) return;
    _jasaItems[i].qty++;
    notifyListeners();
  }

  void decJasa(int jasaId) {
    final i = _jasaIndex(jasaId);
    if (i == -1) return;
    _jasaItems[i].qty--;
    if (_jasaItems[i].qty <= 0) _jasaItems.removeAt(i);
    notifyListeners();
  }

  void removeJasa(int jasaId) {
    final i = _jasaIndex(jasaId);
    if (i == -1) return;
    _jasaItems.removeAt(i);
    notifyListeners();
  }

  // ---- Sparepart (dengan guard stok) ----
  int sparepartQtyOf(int sparepartId) {
    for (final e in _sparepartItems) {
      if (e.sparepart.id == sparepartId) return e.qty;
    }
    return 0;
  }

  void addSparepart(SparepartModel sparepart) {
    if (sparepart.stok <= 0) return;
    final i = _sparepartIndex(sparepart.id);
    if (i == -1) {
      _sparepartItems.add(CartItem(sparepart: sparepart, qty: 1));
    } else {
      if (_sparepartItems[i].qty >= sparepart.stok) return;
      _sparepartItems[i].qty++;
    }
    notifyListeners();
  }

  void incSparepart(int sparepartId) {
    final i = _sparepartIndex(sparepartId);
    if (i == -1) return;
    final item = _sparepartItems[i];
    if (item.qty >= item.sparepart.stok) return;
    item.qty++;
    notifyListeners();
  }

  void decSparepart(int sparepartId) {
    final i = _sparepartIndex(sparepartId);
    if (i == -1) return;
    final item = _sparepartItems[i];
    item.qty--;
    if (item.qty <= 0) _sparepartItems.removeAt(i);
    notifyListeners();
  }

  void removeSparepart(int sparepartId) {
    final i = _sparepartIndex(sparepartId);
    if (i == -1) return;
    _sparepartItems.removeAt(i);
    notifyListeners();
  }

  void clear() {
    _pelanggan = null;
    _jasaItems.clear();
    _sparepartItems.clear();
    notifyListeners();
  }

  /// Menyimpan transaksi servis. Mengembalikan transaksi tersimpan
  /// (untuk struk), atau null bila kosong / pembayaran kurang.
  Future<TransaksiModel?> checkout({
    required double bayar,
    required UserModel kasir,
  }) async {
    if (isEmpty) return null;
    final result = calc;
    if (bayar < result.total) return null;

    _processing = true;
    notifyListeners();
    try {
      final items = <TransaksiItemModel>[
        ..._jasaItems.map(
          (e) => TransaksiItemModel(
            jenis: TransaksiItemModel.jenisJasa,
            refId: e.jasa.id,
            nama: e.jasa.nama,
            harga: e.jasa.harga,
            qty: e.qty,
            subtotal: e.subtotal,
          ),
        ),
        ..._sparepartItems.map(
          (e) => TransaksiItemModel(
            jenis: TransaksiItemModel.jenisSparepart,
            refId: e.sparepart.id,
            nama: e.sparepart.nama,
            harga: e.sparepart.hargaJual,
            qty: e.qty,
            subtotal: e.subtotal,
          ),
        ),
      ];

      final trx = TransaksiModel(
        tipe: TransaksiModel.tipeServis,
        pelangganId: _pelanggan?.id,
        pelangganNama: _pelanggan?.nama,
        subtotal: result.subtotal,
        diskon: result.diskon,
        pajak: result.pajak,
        total: result.total,
        bayar: bayar,
        kembalian: bayar - result.total,
        kasirId: kasir.id,
        kasirNama: kasir.nama,
        createdAt: DateTime.now(),
        items: items,
      );

      final id = await _repo.createTransaksi(trx);
      final pelangganNama = _pelanggan?.nama;
      final pelangganId = _pelanggan?.id;
      clear();
      return TransaksiModel(
        id: id,
        tipe: trx.tipe,
        pelangganId: pelangganId,
        pelangganNama: pelangganNama,
        subtotal: trx.subtotal,
        diskon: trx.diskon,
        pajak: trx.pajak,
        total: trx.total,
        bayar: trx.bayar,
        kembalian: trx.kembalian,
        kasirId: trx.kasirId,
        kasirNama: trx.kasirNama,
        createdAt: trx.createdAt,
        items: trx.items,
      );
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  int _jasaIndex(int? id) =>
      id == null ? -1 : _jasaItems.indexWhere((e) => e.jasa.id == id);

  int _sparepartIndex(int? id) =>
      id == null ? -1 : _sparepartItems.indexWhere((e) => e.sparepart.id == id);
}
