import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../state/app.dart';

class StoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: <Widget>[
          SizedBox(height: 10),
          Container(width: 150, child: Image.asset(Images.player)),
          Text('MY STORE', style: Theme.of(context).textTheme.title),
          Container(
            width: 150,
            child: Row(children: <Widget>[
              Spacer(),
              Image.asset(Images.coin, height: 20),
              SizedBox(width: 3),
              Consumer<AppState>(builder: (_, AppState value, __) {
                return Text('${value.coin}', style: TextStyle(fontSize: 20));
              }),
              Spacer(),
              Image.asset(Images.star, height: 20),
              SizedBox(width: 3),
              Consumer<AppState>(builder: (_, AppState value, __) {
                return Text('${value.score}', style: TextStyle(fontSize: 20));
              }),
              Spacer(),
            ]),
          ),
          SizedBox(height: 5),
          Expanded(
              child: ListView(children: <Widget>[
            _LevelCard(title: 'Freeze', info: 'Slowdown Timer', power: Power.freezer),
            _LevelCard(title: 'Incubator', info: 'Prevent Obstacles', power: Power.incubator),
            _LevelCard(title: 'Multiplier', info: '2X Coin Value', power: Power.multiplier),
            _LevelCard(title: 'Skipper', info: 'Skip Obstacles', power: Power.skipper),
            _PowerCard(title: 'Lazy', info: '2X Powers', power: Power.lucky),
          ])),
        ]),
      ),
    );
  }
}

class _CoinError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Oh Oh!', style: Theme.of(context).textTheme.title),
          Text('We Don\'t Have Enough Coins.'),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String _title, _info;
  final String _power;

  const _LevelCard({@required title, @required info, @required power})
      : _title = title,
        _info = info,
        _power = power;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: ContinuousRectangleBorder(),
      child: Consumer<AppState>(
        builder: (_, AppState value, Widget child) {
          final level = value.powers[_power];
          final cost = pow(2, level - 1) * 500;
          final isMax = level == 5;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (isMax) return;
                  final valid = value.coin - cost > -1;
                  if (value.sound) AudioCache().play(valid ? Sounds.level : Sounds.error);

                  if (valid) {
                    value.coin -= cost;
                    value.promote(_power);
                    return;
                  }
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => _CoinError(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: <Widget>[
                    child,
                    Spacer(),
                    Column(children: <Widget>[
                      Row(children: <Widget>[
                        if (!isMax) Image.asset(Images.coin, height: 20),
                        SizedBox(width: 3),
                        Text(isMax ? 'MAX' : '$cost', style: Theme.of(context).textTheme.title),
                      ]),
                      Text('${level * 5} Moves'),
                    ]),
                  ]),
                ),
              ),
              FractionallySizedBox(
                widthFactor: level / 5,
                child: Container(height: 1, color: Colors.teal),
              ),
            ],
          );
        },
        child: Row(children: <Widget>[
          Image.asset(_power, width: 50),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_title, style: Theme.of(context).textTheme.title),
              Text(_info),
            ],
          ),
        ]),
      ),
    );
  }
}

class _PowerCard extends StatelessWidget {
  final String _title, _info, _power;

  const _PowerCard({@required title, @required info, @required power})
      : _title = title,
        _info = info,
        _power = power;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: ContinuousRectangleBorder(),
      child: InkWell(
        onTap: () {
          final provider = Provider.of<AppState>(context, listen: false);
          if (provider.powers[_power] == 1) return;
          final valid = provider.coin >= 2500;
          if (provider.sound) AudioCache().play(valid ? Sounds.level : Sounds.error);

          if (valid) {
            provider.coin -= 2500;
            provider.promote(_power);
            return;
          }
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => _CoinError(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: <Widget>[
            Row(children: <Widget>[
              Image.asset(_power, width: 50),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_title, style: Theme.of(context).textTheme.title),
                  Text(_info),
                ],
              )
            ]),
            Spacer(),
            Column(children: <Widget>[
              Row(children: <Widget>[
                Image.asset(Images.coin, height: 20),
                SizedBox(width: 3),
                Text('2500', style: Theme.of(context).textTheme.title),
              ]),
              Consumer<AppState>(
                  builder: (_, AppState value, __) => Text(value.powers[_power] == 0 ? 'Inactive' : 'Active')),
            ]),
          ]),
        ),
      ),
    );
  }
}
