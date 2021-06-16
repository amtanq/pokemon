import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';

class _Store {
  static const coin = 'coin';
  static const score = 'score';
  static const sound = 'sound';
  static const powers = 'powers';
}

class AppState extends ChangeNotifier {
  int _coin = 0;
  int _score = 0;
  bool _sound = true;
  SharedPreferences _store;
  Map<String, int> _powers = {};

  AppState() {
    for (var power in Power.collection) _powers[power] = 1;
    _powers[Power.lucky] = 0;

    SharedPreferences.getInstance().then((SharedPreferences store) {
      _store = store;
      _coin = _store.getInt(_Store.coin) ?? _coin;
      _score = _store.getInt(_Store.score) ?? _score;
      _sound = _store.getBool(_Store.sound) ?? _sound;

      final powers = jsonDecode(_store.getString(_Store.powers) ?? '{}');
      _powers = powers.isEmpty ? _powers : Map.from(powers);
      notifyListeners();
    });
  }

  get coin => _coin;
  set coin(int coin) {
    _coin = coin;
    _store.setInt(_Store.coin, _coin);
    notifyListeners();
  }

  get score => _score;
  set score(int score) {
    _score = score;
    _store.setInt(_Store.score, _score);
    notifyListeners();
  }

  get sound => _sound;
  set sound(bool sound) {
    _sound = sound;
    _store.setBool(_Store.sound, _sound);
    notifyListeners();
  }

  get powers => _powers;
  void promote(String power, {int offset = 1}) {
    _powers[power] += offset;
    _store.setString(_Store.powers, jsonEncode(_powers));
    notifyListeners();
  }
}
