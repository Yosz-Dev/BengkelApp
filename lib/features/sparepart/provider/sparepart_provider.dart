import 'package:flutter/foundation.dart';

import '../data/sparepart_model.dart';
import '../data/sparepart_repository.dart';

/// State management daftar & CRUD sparepart.
class SparepartProvider extends ChangeNotifier {
  final SparepartRepository _repo;

  SparepartProvider({SparepartRepository? repo})
      : _repo = repo ?? SparepartRepository();

  List<SparepartModel> _items = [];
  bool _loading = false;
  String _query = '';

  List<SparepartModel> get items => _items;
  bool get loading => _loading;
  String get query => _query;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _repo.getAll(query: _query);
    _loading = false;
    notifyListeners();
  }

  void search(String value) {
    _query = value;
    load();
  }

  Future<bool> save(SparepartModel item) async {
    if (item.id == null) {
      await _repo.insert(item);
    } else {
      await _repo.update(item);
    }
    await load();
    return true;
  }

  Future<bool> delete(int id) async {
    await _repo.delete(id);
    await load();
    return true;
  }
}
