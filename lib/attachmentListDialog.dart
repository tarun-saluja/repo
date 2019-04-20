import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:memob/utilities.dart' as utilities;
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import './constants.dart';

class AttachmentDialog extends StatefulWidget {
  final String meetingUuid;

  @override
  State createState() => new AttachmentDialogState();

  AttachmentDialog(this.meetingUuid);
}

class AttachmentDialogState extends State<AttachmentDialog> {
  String meetingUuid;
  bool attachmentLoaded = false;
  List<dynamic> attachmentData;

  bool _connectionStatus = false;
  final Connectivity _connectivity = new Connectivity();

  String userToken;
  bool storagePermission = false;

  static var httpClient = new HttpClient();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return new CupertinoAlertDialog(
      title: new Column(
        children: <Widget>[new Text("$ATTACHMENT"), new Divider()],
      ),
      content: new Container(
          height: height * 0.50,
          child: new MaterialApp(
              title: '$ATTACHMENT',
              home: new Scaffold(
                body: this.attachmentLoaded == true
                    ? new ListView.builder(
                        primary: true,
                        itemCount: attachmentData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new ListTile(
                            title: new Card(
                              elevation: 5.0,
                              child: new Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 2.0, 10.0, 2.0),
                                margin: new EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text(
                                              '${attachmentData[index]['file_name']}',
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              textAlign: TextAlign.left,
                                              style: new TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    new Icon(
                                      Icons.file_download,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              checkStoragePermission().then((value) {
                                if (storagePermission == true) {
                                  downloadAttachment(userToken,
                                          attachmentData[index]['uuid'])
                                      .then((url) {
                                    _downloadFile(url,
                                        attachmentData[index]['file_name']);
                                  });
                                } else {
                                  utilities
                                      .showLongToast('Permission required');
                                }
                              });
                            },
                          );
                        },
                      )
                    : new Center(
                        child: new CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.blueGrey)),
                      ),
              ))),
      actions: <Widget>[
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

  Future<File> _downloadFile(String url, String filename) async {
    print(url);
    print(filename);
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getExternalStorageDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    utilities.showLongToast('Downloaded Successfully..!');
    return file;
  }


  Future<bool> initConnectivity() async {
    var connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity());

      this.setState(() {
        if (connectionStatus == ConnectivityResult.none) {
          _connectionStatus = false;
        } else {
          _connectionStatus = true;
        }
      });
    } on PlatformException catch (e) {
      print(e);
      _connectionStatus = false;
    }

    if (!mounted) {
      return false;
    }
    return _connectionStatus;
  }

  Future<Null> checkStoragePermission() async {
    bool res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    if (res.toString() == 'true') {
      storagePermission = true;
    } else {
      final res = await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      if (res.toString() == 'true') {
        storagePermission = true;
      }
    }
  }

  Future<String> getAttachments(String token) async {
    final response = await http.get(
        Uri.encodeFull(
            'https://app.meetnotes.co/api/v2/attachments/?meeting=${widget.meetingUuid}'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    if (response.statusCode == 200) {
      this.setState(() {
        attachmentData = json.decode(response.body);

        if (attachmentData.isEmpty) {
          // emptyAttachment = true;
        }
        attachmentLoaded = true;
      });
    } else {
      // If that response was not OK, throw an error.
      attachmentLoaded = true;
      throw Exception('Failed to load attachments');
    }
    return '$SUCCESS';
  }

  Future<String> downloadAttachment(String token, String attachmentId) async {
    var attachmentData;

    final response = await http.get(
        Uri.encodeFull(
            'https://app.meetnotes.co/api/v2/attachments/$attachmentId/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });

    if (response.statusCode == 200) {
      this.setState(() {
        attachmentData = json.decode(response.body);

        if (attachmentData.isEmpty) {
          // emptyAttachment = true;
        }
        //attachmentLoaded = true;
      });
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load attachments');
    }
    return attachmentData['url'].toString();
  }

  Future<Null> fetchData() async {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        userToken = value;
        getAttachments(value);
      } else {
        utilities.showLongToast(value);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    initConnectivity().then((result) {
      if (result) {
        this.fetchData();
      } else {
        attachmentLoaded = true;
      }
    });
  }
}
