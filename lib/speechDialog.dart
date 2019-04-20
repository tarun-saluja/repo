import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memob/uploadAttachment.dart' as UploadAttachment;
import 'package:memob/utilities.dart' as utilities;
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:speech_recognition/speech_recognition.dart';

class Speech extends StatefulWidget {
  final String meetingUuid;

  @override
  _MyAppState createState() => new _MyAppState();

  Speech(this.meetingUuid);
}

class _MyAppState extends State<Speech> {
  String _platformVersion = 'Unknown';

  //Permission permission;
  String userToken;
  SpeechRecognition _speech;

  String textFilePath;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';

  String _currentLocale = 'en_US';

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
    fetchData();
    checkPermission();
    getPermissionStatus();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  Future<String> get _localPath async {
    String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Text/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/Document_${timestamp()}.txt';
    return filePath;
  }

  Future<File> _localFile() async {
    final path = await _localPath;
    return File(path);
  }

  Future<File> writeToFile() async {
    final file = await _localFile();
    // Write the file
    return file.writeAsString(transcription);
  }

  Future<Null> fetchData() async {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        userToken = value;
      } else {
        utilities.showLongToast(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return new CupertinoAlertDialog(
      title: new Column(
        children: <Widget>[
          new Text("Voice note"),
          new Divider(),
        ],
      ),
      content: new Container(
        child: new Container(
          child: new Padding(
              padding: new EdgeInsets.all(1.0),
              child: new Center(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Container(child: new Text(transcription)),
                    new Container(
                      child: new Column(
                        children: <Widget>[
                          new ButtonTheme(
                            child: _buildButton(
                              onPressed:
                                  _speechRecognitionAvailable && !_isListening
                                      ? () => start()
                                      : null,
                              label: _isListening ? 'Listening...' : 'Listen',
                            ),
                            minWidth: double.infinity,
                          ),
                          new ButtonTheme(
                            child: _buildButton(
                              onPressed: _isListening ? () => stop() : null,
                              label: 'Stop',
                            ),
                            minWidth: double.infinity,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
        height: height * 0.50,
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();

              writeToFile().then((file) {
                UploadAttachment.uploadAttachment(
                    userToken, file.path, widget.meetingUuid);

                utilities.showLongToast('Transcription saved successfully..!');
              });
            },
            child: new Icon(
              Icons.done,
              color: Colors.green,
            )),
        new FlatButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: new Icon(
              Icons.close,
              color: Colors.red,
            ))
      ],
    );
  }

  Widget _buildButton({String label, VoidCallback onPressed}) => new Padding(
      padding: new EdgeInsets.all(3.0),
      child: new RaisedButton(
        color: Colors.cyan.shade600,
        onPressed: onPressed,
        child: new Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ));

  void start() => _speech
      .listen(locale: _currentLocale)
      .then((result) => print('_MyAppState.start => result $result'));

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() =>
      _speech.stop().then((result) => setState(() => _isListening = result));

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) =>
      setState(() => _currentLocale = locale);

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => setState(() => transcription = text);

  void onRecognitionComplete() => setState(() => _isListening = false);
}

void requestPermission() async {
  final res = await SimplePermissions.requestPermission(Permission.RecordAudio);
}

Future<bool> checkPermission() async {
  bool res = await SimplePermissions.checkPermission(Permission.RecordAudio);
  return res;
}

void getPermissionStatus() async {
  final res =
      await SimplePermissions.getPermissionStatus(Permission.RecordAudio);
}
