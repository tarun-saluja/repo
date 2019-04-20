import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './constants.dart';

class CancelButton extends StatelessWidget {
  CancelButton({@required this.onPressed});

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
            const Text("cancel", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}
