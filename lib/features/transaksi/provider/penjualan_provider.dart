import 'package:flutter/foundation.dart';

import '../../../core/utils/transaction_calculator.dart';
import '../../auth/data/user_model.dart';
import '../../sparepart/data/sparepart_model.dart';
import '../data/cart_item.dart';
import '../data/transaksi_item_model.dart';
import '../data/transaksi_model.dart';
import '../data/transaksi_repository.dart';

/// State keranjang & proses checkout transaksi penjualan sparepart.
class PenjualanProvider extends ChangeNotifier {
  final TransaksiRepository _repo;

  PenjualanProvider({TransaksiRepository? repo})
      : _repo = repo ?? TransaksiRepository();

  final List<CartItem> _cart = [];
  bool _processing = false;

  List<CartItem> get cart => List.unmodifiable(_cart);
  bool get processing => _processing;
  bool get isEmpty => _cart.isEmpty;

  /// Jumlah total qty seluruh item di keranjang.
  int get itemCount => _cart.fold(0, (sum, item) => sum + item.qty);

  double get subtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  /// Hasil perhitungan transaksi (diskon + pajak) untuk subtotal saat ini.
  TransactionResult get calc => TransactionCalculator.calculate(subtotal);

  /// Qty sparepart tertentu yang sudah ada di keranjang (0 bila belum ada).
  int qtyOf(int sparepartId) {
    for (final item in _cart) {
      if (item.sparepart.id == sparepartId) return item.qty;
    }
    return 0;
  }

  /// Menambah satu sparepart ke keranjang. Tidak melebihi stok tersedia.
  void addItem(SparepartModel sparepart) {
    if (sparepart.stok <= 0) return;
    final existing = _indexOf(sparepart.id);
    if (existing == -1) {
      _cart.add(CartItem(sparepart: sparepart, qty: 1));
    } else {
      final item = _cart[existing];
      if (item.qty >= sparepart.stok) return;
      item.qty++;
    }
    notifyListeners();
  }

  void increment(int sparepartId) {
    final index = _indexOf(sparepartId);
    if (index == -1) return;
    final item = _cart[index];
    if (item.qty >= item.sparepart.stok) return;
    item.qty++;
    notifyListeners();
  }

  void decrement(int sparepartId) {
    final index = _indexOf(sparepartId);
    if (index == -1) return;
    final item = _cart[index];
    item.qty--;
    if (item.qty <= 0) {
      _cart.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int sparepartId) {
    final index = _indexOf(sparepartId);
    if (index == -1) return;
    _cart.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_cart.isEmpty) return;
    _cart.clear();
    notifyListeners();
  }

  /// Menyimpan transaksi penjualan. Mengembalikan transaksi tersimpan
  /// (untuk struk), atau null bila keranjang kosong / pembayaran kurang.
  Future<TransaksiModel?> checkout({
    required double bayar,
    required UserModel kasir,
  }) async {
    if (_cart.isEmpty) return null;
    final result = calc;
    if (bayar < result.total) return null;

    _processing = true;
    notifyListeners();
    try {
      final items = _cart
          .map(
            (c) => TransaksiItemModel(
              jenis: TransaksiItemModel.jenisSparepart,
              refId: c.sparepart.id,
              nama: c.sparepart.nama,
              harga: c.sparepart.hargaJual,
              qty: c.qty,
              subtotal: c.subtotal,
            ),
          )
          .toList();

      final trx = TransaksiModel(
        tipe: TransaksiModel.tipePenjualan,
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
      _cart.clear();
      return TransaksiModel(
        id: id,
        tipe: trx.tipe,
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

  int _indexOf(int? sparepartId) {
    if (sparepartId == null) return -1;
    return _cart.indexWhere((item) => item.sparepart.id == sparepartId);
  }
}
