import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import './cancelbutton.dart';
import './constants.dart';
import './drawer.dart';
import './sendbutton.dart';
import './api_service.dart';
import './utilities.dart';

final ThemeData iOSTheme = new ThemeData(
  primarySwatch: Colors.red,
  primaryColor: Colors.grey[400],
  primaryColorBrightness: Brightness.dark,
);

final ThemeData androidTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.green,
);

const String defaultUserName = "User";

class Share extends StatefulWidget {
  final String meetingTitle;
  final String meetingBody;
  final List<String> asigneeEmail;
  final String rawHtml;
  final String delta;
  final String meetingUuid;

  Share(
      [this.meetingTitle,
      this.meetingBody,
      this.asigneeEmail,
      this.rawHtml,
      this.delta,
      this.meetingUuid]);

  @override
  State<StatefulWidget> createState() {
    return ShareWindow();
  }
}

class ShareWindow extends State<Share> with TickerProviderStateMixin {
  final List<Msg> _messages = List<Msg>();
  var map = new Map<String, Msg>();

  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;
  String userToken;
  Map body;

  @override
  void initState() {
    super.initState();
    _initAdd();
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("$LOGO"),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
      ),
      drawer: new Dwidget(),
      body: new Column(children: <Widget>[
        new Divider(),
        new Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CancelButton(onPressed: () {
                  Navigator.pop(context);
                }),
                Text(
                  "$SHARE_NOTES",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SendButton(
                  onPressed: () async {
                    String _mail = "";
                    List<String> mail = new List();

                    for (var temp in _messages) {
                      if (temp.status) mail.add(temp.txt);
                    }

                    body = {
                      "type": "EMAIL",
                      "mailRecipients": mail,
                      "rawHTML": "${widget.rawHtml}",
                    };

                    postData(body);
                  },
                ),
              ]),
        ),
        new Divider(
          color: Colors.black,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("All Attendees"),
            Text("Only Me"),
            Text("Domain"),
          ],
        ),
        new Divider(
          color: Colors.black,
        ),
        new Flexible(
            child: new ListView.builder(
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
          reverse: true,
          padding: new EdgeInsets.all(6.0),
        )),
        new Divider(height: 1.0),
        new Container(
          child: _buildComposer(),
          decoration: new BoxDecoration(color: Theme.of(ctx).cardColor),
        ),
      ]),
    );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  onSubmitted: _submitMsg,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Add email"),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoButton(
                          child: new Text("Submit"),
                          onPressed: _isWriting
                              ? () => _submitMsg(_textController.text)
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.add),
                          onPressed: _isWriting
                              ? () => _submitMsg(_textController.text)
                              : null,
                        )),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.brown)))
              : null),
    );
  }

  void _initAdd() {
    for (String temp in widget.asigneeEmail) _submitMsg(temp);
  }

  Future<Null> postData(Map body) async {
    Future<String> token = getTokenData();
    dynamic url = api.postData(widget.meetingUuid);
    token.then((value) {
      if (value != null) {
        userToken = value;
        sendEmail(url, body);
      } else {
        showLongToast(value);
        return null;
      }
    });

    return null;
  }

  Future<Null> sendEmail(String url, Map body) async {
    var data = jsonEncode(body);

    var response = await http.post(url,
        headers: {
          HttpHeaders.authorizationHeader: 'Token $userToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: data);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Email Sent",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _submitMsg(String txt) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = new Msg(
      txt: txt,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );
    setState(() {
      _messages.insert(0, msg);
      map.putIfAbsent(msg.txt, () => msg);
    });
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }
}

class Msg extends StatefulWidget {
  final String txt;
  bool status = true;
  final AnimationController animationController;

  Msg({this.txt, this.animationController});

  @override
  State<StatefulWidget> createState() {
    return MsgState();
  }
}

class MsgState extends State<Msg> {
  bool checkboxValue = true;

  @override
  void initState() {
    super.initState();
  }

  void toggle() {
    if (widget.status)
      this.widget.status = false;
    else
      this.widget.status = true;
  }

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: widget.animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 18.0),
              child: new CircleAvatar(child: new Text("@")),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(top: 11.0),
                    child: new Text(widget.txt),
                  ),
                ],
              ),
            ),
            Checkbox(
                value: checkboxValue,
                onChanged: (bool newValue) {
                  setState(() {
                    this.toggle();
                    checkboxValue = this.widget.status;
                  });
                }),
          ],
        ),
      ),
    );
  }
}
