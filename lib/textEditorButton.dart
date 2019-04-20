import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TextEditorButton extends StatelessWidget {
  TextEditorButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      splashColor: Colors.orange,
      fillColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.white,
              size: 30.0,
            ),
            const Text("Switch to Editor",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}
