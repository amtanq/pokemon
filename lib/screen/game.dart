import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../state/app.dart';
import '../state/game.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Consumer<GameState>(
              builder: (_, GameState value, Widget child) {
                return Row(children: <Widget>[
                  child,
                  SizedBox(width: 3),
                  Text('${value.score}', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Spacer(),
                  if (value.factive == null || value.status != '') Text(value.status, style: TextStyle(fontSize: 20)),
                  if (value.status == '' && value.factive != null) ...[
                    child,
                    SizedBox(width: 3),
                    Text('${value.fscore}', style: TextStyle(fontSize: 20)),
                  ],
                ]);
              },
              child: Image.asset(Images.coin, height: 20),
            ),
          ),
          Divider(height: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: _GameGrid(),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GameGrid extends StatefulWidget {
  @override
  _GameGridState createState() => _GameGridState();
}

class _GameGridState extends State<_GameGrid> with WidgetsBindingObserver {
  String _target = Images.egg, _reflection = Images.egg, _power = '';
  int _cell = -1, _cellTrack = -1, _powerCount = 0, _lucky = 0;
  bool _active = true;
  GameState _gameState;
  AppState _appState;
  AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _appState = Provider.of<AppState>(context, listen: false);
      _gameState = Provider.of<GameState>(context, listen: false);
      _gameState.fscore = 0;
      _gameState.score = 0;

      _lucky = _appState.powers[Power.lucky];
      if (_lucky == 1) {
        _appState.promote(Power.lucky, offset: -1);
        _lucky = 5;
      }

      final countdown = ['READY', 'STEADY', 'PLAY'];
      for (var index = 0; index < countdown.length && mounted; ++index) {
        _play(Sounds.count);
        _gameState.status = countdown[index];
        await Future.delayed(Duration(seconds: 1));
      }

      _play(Sounds.blocks, loop: true);
      _active = true;
      while (_active && mounted) await _loop();
      if (_gameState.factive != null) _gameState.socket.emit('state');

      if (!mounted) return;
      if (_gameState.score > _appState.score) _appState.score = _gameState.score;
      _appState.coin += _gameState.score;
      if (_gameState.factive != null) {
        if (_gameState.fstate == false)
          Navigator.pushReplacementNamed(context, Routes.result, arguments: -1);
        else
          Navigator.pushReplacementNamed(context, Routes.result, arguments: -2);
      } else
        Navigator.pushReplacementNamed(context, Routes.result, arguments: _gameState.score);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameState.disconnect();
    _player?.release();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Navigator.of(context).pop();
  }

  @override
  void setState(Function function) {
    if (!mounted) return;
    super.setState(function);
  }

  void _play(file, {loop = false}) async {
    if (!_appState.sound || !mounted) return;
    if (loop)
      _player = await AudioCache().loop(file);
    else
      AudioCache().play(file);
  }

  String _image() {
    final type = Random().nextInt(100);
    if (type < 40 && _power != Power.incubator) return Images.egg;
    if (type < 45 + _lucky && _powerCount == 0) return Power.collection[Random().nextInt(Power.collection.length)];
    _active = false;

    final target = Random().nextInt(Images.targets.length);
    return _target == Images.targets[target]
        ? Images.targets[(target + 1) % Images.targets.length]
        : Images.targets[target];
  }

  Future<void> _loop() {
    if (_gameState.factive != null && _gameState.fstate == false) {
      _active = false;
      return Future.delayed(Duration.zero);
    }

    final cell = Random().nextInt(12);
    var time = (800 - 2 * _gameState.score);
    _cell = _cellTrack = (cell == _cellTrack ? (cell + 1) % 12 : cell);
    _reflection = _target;
    _target = _image();
    setState(() {});

    if (_powerCount > 0)
      --_powerCount;
    else
      _power = _gameState.status = '';
    if (_power == Power.freezer) time *= 1.5;
    return Future.delayed(Duration(milliseconds: time.floor()));
  }

  void _tap(int cell) {
    if (cell != _cell) return;
    _reflection = _target;
    _cell = -1;
    setState(() {});

    if (_target == Images.egg) {
      _play(Sounds.error);
      if (_power == Power.skipper) return;
      _active = false;
      return;
    }

    if (Images.targets.indexOf(_target) != -1) {
      _play(Sounds.bubble);
      _gameState.score = _power == Power.multiplier ? _gameState.score + 2 : _gameState.score + 1;
      _active = true;
      if (_gameState.factive != null) _gameState.socket.emit('score', _gameState.score);
      return;
    }

    switch (_target) {
      case Power.multiplier:
        _gameState.status = 'Multiplier';
        break;
      case Power.freezer:
        _gameState.status = 'Freeze';
        break;
      case Power.skipper:
        _gameState.status = 'Skipper';
        break;
      case Power.incubator:
        _gameState.status = 'Incubator';
        break;
    }
    _power = _target;
    _play(Sounds.level);
    _powerCount = _appState.powers[_power] * 5;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: Row(children: <Widget>[
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 0 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(0),
                child: Image.asset(_cell == 0 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 1 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(1),
                child: Image.asset(_cell == 1 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 2 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(2),
                child: Image.asset(_cell == 2 ? _target : _reflection),
              ),
            ),
          ),
        ]),
      ),
      Expanded(
        child: Row(children: <Widget>[
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 3 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(3),
                child: Image.asset(_cell == 3 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 4 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(4),
                child: Image.asset(_cell == 4 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 5 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(5),
                child: Image.asset(_cell == 5 ? _target : _reflection),
              ),
            ),
          ),
        ]),
      ),
      Expanded(
        child: Row(children: <Widget>[
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 6 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(6),
                child: Image.asset(_cell == 6 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 7 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(7),
                child: Image.asset(_cell == 7 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 8 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(8),
                child: Image.asset(_cell == 8 ? _target : _reflection),
              ),
            ),
          ),
        ]),
      ),
      Expanded(
        child: Row(children: <Widget>[
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 9 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(9),
                child: Image.asset(_cell == 9 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 10 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(10),
                child: Image.asset(_cell == 10 ? _target : _reflection),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _cell == 11 ? 1 : 0,
              child: Listener(
                onPointerDown: (_) => _tap(11),
                child: Image.asset(_cell == 11 ? _target : _reflection),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}
