import 'package:flutter/foundation.dart';

import '../../transaksi/data/transaksi_model.dart';
import '../../transaksi/data/transaksi_repository.dart';

/// State daftar riwayat transaksi dengan filter tanggal & tipe.
class RiwayatProvider extends ChangeNotifier {
  final TransaksiRepository _repo;

  RiwayatProvider({TransaksiRepository? repo})
      : _repo = repo ?? TransaksiRepository();

  List<TransaksiModel> _items = [];
  bool _loading = false;
  DateTime? _date;
  String? _tipe; // null = semua

  List<TransaksiModel> get items => _items;
  bool get loading => _loading;
  DateTime? get date => _date;
  String? get tipe => _tipe;

  /// Total nilai transaksi yang sedang ditampilkan.
  double get totalNilai =>
      _items.fold(0, (sum, trx) => sum + trx.total);

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _repo.getAll(date: _date, tipe: _tipe);
    _loading = false;
    notifyListeners();
  }

  void setDate(DateTime? value) {
    _date = value;
    load();
  }

  void setTipe(String? value) {
    _tipe = value;
    load();
  }

  void clearFilter() {
    _date = null;
    _tipe = null;
    load();
  }
}
