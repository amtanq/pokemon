import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../global.dart';

class ResultScreen extends StatelessWidget {
  final int _score;

  ResultScreen({@required score}) : _score = score;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Column(children: <Widget>[
              Spacer(),
              Container(
                height: 300,
                child: FlareActor(Images.pokeball, fit: BoxFit.contain, animation: 'idle'),
              ),
              if (_score == -2) Text('YOU LOSE', style: Theme.of(context).textTheme.title),
              if (_score == -1) Text('YOU WIN', style: Theme.of(context).textTheme.title),
              if (_score > -1)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(Images.coin, height: 40),
                    SizedBox(width: 3),
                    _CounterText(target: _score)
                  ],
                ),
              Spacer(),
            ]),
          ),
          FlareActor(Images.confetti, fit: BoxFit.cover, animation: 'idle')
        ]),
      ),
    );
  }
}

class _CounterText extends StatefulWidget {
  final int _target;

  _CounterText({@required target}) : _target = target;

  @override
  _CounterTextState createState() => _CounterTextState();
}

class _CounterTextState extends State<_CounterText> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curve;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1))..addListener(() => setState(() {}));
    _curve = CurvedAnimation(curve: Curves.easeOutCubic, parent: _controller);
    _animation = IntTween(begin: 0, end: widget._target).animate(_curve);
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return Text('${_animation.value}', style: TextStyle(fontSize: 40));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
