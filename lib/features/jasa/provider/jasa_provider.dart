import 'package:flutter/foundation.dart';

import '../data/jasa_model.dart';
import '../data/jasa_repository.dart';

/// State management daftar & CRUD jasa.
class JasaProvider extends ChangeNotifier {
  final JasaRepository _repo;

  JasaProvider({JasaRepository? repo}) : _repo = repo ?? JasaRepository();

  List<JasaModel> _items = [];
  bool _loading = false;
  String _query = '';

  List<JasaModel> get items => _items;
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

  Future<bool> save(JasaModel item) async {
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
