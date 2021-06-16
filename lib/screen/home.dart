import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global.dart';
import '../state/app.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          _StateManager(),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(Routes.game),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(10),
              child: Column(children: <Widget>[
                Spacer(),
                Image.asset(Images.pokemon),
                Spacer(),
                Text('TAP TO PLAY'),
              ]),
            ),
          ),
          Row(children: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.store),
              icon: Icon(Icons.store, size: 30),
            ),
            Spacer(),
            Builder(builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(title: Text('OPTIONS', style: Theme.of(context).textTheme.title)),
                          Divider(height: 0),
                          Consumer<AppState>(builder: (_, AppState value, __) {
                            final icon = value.sound ? Icons.volume_up : Icons.volume_off;
                            return ListTile(
                              onTap: () {
                                value.sound = !value.sound;
                                if (!value.sound) return;
                                AudioCache().play(Sounds.bubble);
                              },
                              title: Text('Music', style: Theme.of(context).textTheme.body1),
                              trailing: Icon(icon),
                            );
                          }),
                          Divider(height: 0),
                          ListTile(
                            onTap: () => Navigator.pushReplacementNamed(context, Routes.host),
                            title: Text('MutiPlayer', style: Theme.of(context).textTheme.body1),
                            trailing: Icon(Icons.storage),
                          ),
                          Divider(height: 0),
                          ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              Share.share('Catch pokemons with friends at https://bit.ly/_poke');
                            },
                            title: Text('Share', style: Theme.of(context).textTheme.body1),
                            trailing: Icon(Icons.share),
                          ),
                          Divider(height: 0),
                          ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              launch('https://tanqq.now.sh');
                            },
                            title: Text('About', style: Theme.of(context).textTheme.body1),
                            trailing: Icon(Icons.book),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }),
          ]),
        ]),
      ),
    );
  }
}

class _StateManager extends StatefulWidget {
  @override
  _StateManagerState createState() => _StateManagerState();
}

class _StateManagerState extends State<_StateManager> {
  @override
  void initState() {
    super.initState();
    FirebaseDynamicLinks.instance.getInitialLink().then(_router);
    FirebaseDynamicLinks.instance.onLink(onSuccess: _router, onError: (_) async {});
  }

  Future<void> _router(PendingDynamicLinkData data) async {
    final query = data?.link?.queryParameters;
    if (query == null || query['id'] == null) return;
    Navigator.pushNamed(context, Routes.connect, arguments: query['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
