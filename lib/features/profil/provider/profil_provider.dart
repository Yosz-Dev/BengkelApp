import 'package:flutter/foundation.dart';

import '../data/profil_model.dart';
import '../data/profil_repository.dart';

/// State management profil bengkel.
class ProfilProvider extends ChangeNotifier {
  final ProfilRepository _repo;

  ProfilProvider({ProfilRepository? repo})
      : _repo = repo ?? ProfilRepository();

  ProfilModel? _profil;
  bool _loading = false;

  ProfilModel? get profil => _profil;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _profil = await _repo.getProfile();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(ProfilModel profil) async {
    await _repo.save(profil);
    await load();
  }
}
