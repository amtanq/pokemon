import 'package:flutter/widgets.dart';

final navigatorKey = new GlobalKey<NavigatorState>();

class Images {
  static const coin = 'assets/image/coin.png';
  static const egg = 'assets/image/egg.png';
  static const player = 'assets/image/player.png';
  static const pokemon = 'assets/image/pokemon.png';
  static const star = 'assets/image/star.png';
  static const confetti = 'assets/flare/confetti.flr';
  static const pokeball = 'assets/flare/pokeball.flr';

  static const targets = [
    'assets/target/abra.png',
    'assets/target/bellsprout.png',
    'assets/target/bullbasaur.png',
    'assets/target/caterpie.png',
    'assets/target/charmander.png',
    'assets/target/dratini.png',
    'assets/target/eevee.png',
    'assets/target/jigglypuff.png',
    'assets/target/mankey.png',
    'assets/target/meowth.png',
    'assets/target/mew.png',
    'assets/target/pidgey.png',
    'assets/target/pikachu.png',
    'assets/target/psyduck.png',
    'assets/target/rattata.png',
    'assets/target/snorlax.png',
    'assets/target/squirtle.png',
    'assets/target/venonat.png',
    'assets/target/weedle.png',
    'assets/target/zubat.png',
  ];
}

class Power {
  static const freezer = 'assets/image/power-1.png';
  static const incubator = 'assets/image/power-2.png';
  static const multiplier = 'assets/image/power-3.png';
  static const skipper = 'assets/image/power-4.png';
  static const lucky = 'assets/image/power-5.png';
  static const collection = [freezer, incubator, multiplier, skipper];
}

class Routes {
  static const connect = 'connect';
  static const game = 'game';
  static const home = 'home';
  static const host = 'host';
  static const result = 'result';
  static const store = 'store';
}

class Sounds {
  static const blocks = 'sound/blocks.wav';
  static const bubble = 'sound/bubble.wav';
  static const count = 'sound/count.wav';
  static const error = 'sound/error.wav';
  static const level = 'sound/level.wav';
}
