import 'package:faboules/uniModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify/spotify.dart' as s;
import 'package:provider/provider.dart';

var appState = AppLifecycleState.resumed;

class LifeCycleManager extends StatefulWidget {
  final Widget child;

  const LifeCycleManager({Key? key, required this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // print('START: didChangeAppLifecycleState state = $state');
    appState = state;

    if (appState == AppLifecycleState.resumed) {
      // context.read<UniModel>().setTrackFromClipboard();
    }

    if (appState == AppLifecycleState.inactive ||
        appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.hidden) {
      try {} catch (e, s) {
        print(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
