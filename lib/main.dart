import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'global.dart';
import 'screen/connect.dart';
import 'screen/game.dart';
import 'screen/home.dart';
import 'screen/host.dart';
import 'screen/result.dart';
import 'screen/store.dart';
import 'state/app.dart';
import 'state/game.dart';

void main() => runApp(MyApp());

class SilentScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(_, Widget child, __) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  Widget _pageTransition(_, Animation animation, __, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<GameState>(create: (_) => GameState()),
      ],
      child: MaterialApp(
        title: 'Pokemon',
        navigatorKey: navigatorKey,
        builder: (_, Widget child) => ScrollConfiguration(behavior: SilentScroll(), child: child),
        theme: ThemeData(
          fontFamily: 'Quicksand',
          primarySwatch: Colors.blueGrey,
          iconTheme: IconThemeData(color: Colors.blueGrey),
          textTheme: TextTheme(
            title: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 20),
            body1: TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
        ),
        initialRoute: Routes.home,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case Routes.connect:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => ConnectScreen(id: settings.arguments),
                transitionsBuilder: _pageTransition,
              );
            case Routes.game:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => GameScreen(),
                transitionsBuilder: _pageTransition,
              );
            case Routes.home:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => HomeScreen(),
                transitionsBuilder: _pageTransition,
              );
            case Routes.host:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => HostScreen(),
                transitionsBuilder: _pageTransition,
              );
            case Routes.result:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => ResultScreen(score: settings.arguments),
                transitionsBuilder: _pageTransition,
              );
            case Routes.store:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => StoreScreen(),
                transitionsBuilder: _pageTransition,
              );
            default:
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => HomeScreen(),
                transitionsBuilder: _pageTransition,
              );
          }
        },
      ),
    );
  }
}
