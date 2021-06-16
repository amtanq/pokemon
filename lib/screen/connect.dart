import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game.dart';

class ConnectScreen extends StatelessWidget {
  final String _id;
  ConnectScreen({@required String id}) : _id = id;

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<GameState>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StateManager(),
            ListTile(title: Text('MultiPlayer', style: Theme.of(context).textTheme.title)),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.only(top: 15, right: 15, left: 15),
              child: Text('Your friend invited you to play Pokemon.\nDo you want to play now?\nRoom #$_id'),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 0),
                RaisedButton(
                  color: Colors.teal,
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    _provider.socket.emit('enter', _id);
                  },
                  child: Text('YES'),
                ),
                RaisedButton(
                  color: Colors.redAccent,
                  onPressed: () => Navigator.pop(context),
                  child: Text('NO'),
                ),
              ],
            ),
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
