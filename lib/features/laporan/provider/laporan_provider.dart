import 'package:flutter/foundation.dart';

import '../../sparepart/data/sparepart_model.dart';
import '../../sparepart/data/sparepart_repository.dart';
import '../data/laporan_model.dart';
import '../data/laporan_repository.dart';

/// State modul Laporan: pendapatan (harian/bulanan) & laporan stok.
class LaporanProvider extends ChangeNotifier {
  final LaporanRepository _repo;
  final SparepartRepository _sparepartRepo;

  LaporanProvider({
    LaporanRepository? repo,
    SparepartRepository? sparepartRepo,
  })  : _repo = repo ?? LaporanRepository(),
        _sparepartRepo = sparepartRepo ?? SparepartRepository();

  // ---- Pendapatan ----
  bool _harian = true; // true = harian, false = bulanan
  DateTime _periode = DateTime.now();
  RingkasanPendapatan _ringkasan = const RingkasanPendapatan();
  List<PendapatanPerHari> _rincian = [];
  bool _loadingPendapatan = false;

  bool get harian => _harian;
  DateTime get periode => _periode;
  RingkasanPendapatan get ringkasan => _ringkasan;
  List<PendapatanPerHari> get rincian => _rincian;
  bool get loadingPendapatan => _loadingPendapatan;

  // ---- Stok ----
  List<SparepartModel> _stok = [];
  bool _loadingStok = false;

  List<SparepartModel> get stok => _stok;
  bool get loadingStok => _loadingStok;

  int get totalItemStok => _stok.length;
  int get totalUnitStok => _stok.fold(0, (sum, s) => sum + s.stok);
  double get nilaiStok =>
      _stok.fold(0, (sum, s) => sum + s.stok * s.hargaBeli);
  List<SparepartModel> get stokMenipis =>
      _stok.where((s) => s.stok <= 5).toList();

  Future<void> loadPendapatan() async {
    _loadingPendapatan = true;
    notifyListeners();
    if (_harian) {
      _ringkasan = await _repo.pendapatanHarian(_periode);
      _rincian = [];
    } else {
      _ringkasan = await _repo.pendapatanBulanan(_periode.year, _periode.month);
      _rincian = await _repo.rincianBulanan(_periode.year, _periode.month);
    }
    _loadingPendapatan = false;
    notifyListeners();
  }

  Future<void> loadStok() async {
    _loadingStok = true;
    notifyListeners();
    _stok = await _sparepartRepo.getAll();
    _loadingStok = false;
    notifyListeners();
  }

  void setMode({required bool harian}) {
    if (_harian == harian) return;
    _harian = harian;
    loadPendapatan();
  }

  void setPeriode(DateTime value) {
    _periode = value;
    loadPendapatan();
  }
}
