import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './constants.dart';

class SendButton extends StatelessWidget {
  SendButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      splashColor: Colors.orange,
      fillColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.send,
              color: Colors.white,
            ),
            const Text("Send", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}
