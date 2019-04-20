import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memob/utilities.dart' as utilities;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

final flutterWebviewPlugin = new FlutterWebviewPlugin();

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.close();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    top: 0.0,
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: new Image.asset(
                      'assets/meetnotes_icon.png',
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        Navigator.pushReplacementNamed(
          context,
          'Dashboard',
        );
      } else {
        Navigator.pushReplacementNamed(context, 'Login');
      }
    });
  }
}
