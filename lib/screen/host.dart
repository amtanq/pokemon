import 'package:flutter/material.dart';
import 'package:pokemon/state/game.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class HostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StateManager(),
            ListTile(title: Text('MultiPlayer', style: Theme.of(context).textTheme.title)),
            Divider(height: 0),
            Consumer<GameState>(
              builder: (_, GameState value, Widget child) {
                return ListTile(
                  onTap: () {
                    if (value.fid == null) return;
                    Share.share('Pokemon Room: https://igame.netlify.app/${value.fid}');
                  },
                  title: Text(value.fid == null ? 'LOADING' : value.fid,
                      style: Theme.of(context).textTheme.body1),
                  trailing: child,
                );
              },
              child: Icon(Icons.storage),
            ),
            Divider(height: 0),
            ListTile(
              onTap: () {},
              title: Text('HOST', style: Theme.of(context).textTheme.body1),
              trailing: Icon(Icons.cloud, color: Colors.teal),
            ),
            Divider(height: 0),
            ListTile(
              onTap: () {},
              title: Text('CLIENT', style: Theme.of(context).textTheme.body1),
              trailing: Icon(Icons.cloud, color: Colors.redAccent),
            ),
            Divider(height: 0),
          ],
        ),
      ),
    );
  }
}

class _StateManager extends StatefulWidget {
  @override
  _StateManagerState createState() => _StateManagerState();
}

class _StateManagerState extends State<_StateManager> {
  GameState _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<GameState>(context, listen: false);
    _provider.connect();
    if (_provider.fid != null) return;
    _provider.socket.emit('create');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
