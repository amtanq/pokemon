import 'package:flutter/foundation.dart';
import 'package:pokemon/global.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameState extends ChangeNotifier {
  int _score = 0;
  String _status = '';

  bool _factive, _fstate;
  int _fscore;
  String _fid;
  Socket _socket;

  get socket => _socket;
  void disconnect() => _factive = _fid = null;
  void connect() {
    if (_socket != null) return;
    _socket = io('https://pokehost.amtanq.repl.co', <String, dynamic>{
      'transports': ['websocket'],
    });
    _socket.on('create', (id) => fid = id);
    _socket.on('score', (score) => fscore = score);
    _socket.on('state', (_) => fstate = false);
    _socket.on('start', (_) {
      fscore = 0;
      factive = fstate = true;
      navigatorKey.currentState.pushReplacementNamed(Routes.game);
    });
    _socket.on('disconnect', (_) => fid = null);
  }

  get factive => _factive;
  set factive(bool state) {
    _factive = state;
    notifyListeners();
  }

  get fstate => _fstate;
  set fstate(bool state) {
    _fstate = state;
    notifyListeners();
  }

  get fid => _fid;
  set fid(String id) {
    _fid = id;
    notifyListeners();
  }

  get fscore => _fscore;
  set fscore(int score) {
    _fscore = score;
    notifyListeners();
  }

  get score => _score;
  set score(int score) {
    _score = score;
    notifyListeners();
  }

  get status => _status;
  set status(String status) {
    _status = status;
    notifyListeners();
  }
}
