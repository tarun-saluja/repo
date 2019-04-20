import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:memob/api_service.dart';
import 'package:memob/dateTimeFormatter.dart' as DateTimeFormatter;
import 'package:memob/utilities.dart' as utilities;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './attachmentListDialog.dart';
import './cameraPage.dart';
import './constants.dart';
import './dashboard.dart';
import './share.dart';
import './speechDialog.dart';
import './api_service.dart';
import './webView.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
final flutterWebviewPlugin = new FlutterWebviewPlugin();
BuildContext m;
final _scaffoldKey = new GlobalKey<ScaffoldState>();

class Detail extends StatefulWidget {
  final String meetingUuid;
  final String meetingTitle;
  final String meetingEventId;

  Detail([this.meetingUuid, this.meetingTitle, this.meetingEventId]);

  @override
  State<StatefulWidget> createState() {
    return _DetailState();
  }
}

class _DetailState extends State<Detail> {
  InAppWebViewController webView;
  Map<String, dynamic> data;
  List<dynamic> attachmentCountData;
  List<dynamic> attachmentData;
  String userToken;
  String url = "";
  bool noteLoaded = false;
  bool attachmentCountLoaded = false;
  bool attachmentLoaded = false;
  bool emptyAttachment = false;
  String noteText;
  String title;
  List<String> attendeesEmail;
  String rawHtml;
  String delta;
  bool recordPermission = false;
  bool _connectionStatus = false;
  final Connectivity _connectivity = new Connectivity();
  int attachmentCount;
  var finalDateTime;

  Future<Null> _goback() {
    flutterWebviewPlugin.close();
    Navigator.popUntil(context, ModalRoute.withName('Dashboard'));
  }

  @override
  Widget build(BuildContext context) {
    print(context);
    print('p');
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double height1 = MediaQuery.of(context).size.height;
    double width1 = MediaQuery.of(context).size.width;
    print(height);
    print(width);
    String url = "https://app.meetnotes.co/m/${widget.meetingUuid}/";
    CookieManager.setCookie(
        url, 'sessionid', 'ocbq6fjxtl8w5nqqlz9a4ppp8izjjrwo');
    
    flutterWebviewPlugin.launch(url,
        rect: new Rect.fromLTWH(0.0, 0.0, width, height * 0.91),
        userAgent: kAndroidUserAgent);
    return WillPopScope(
      onWillPop: _goback,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(children: [
          Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.fromLTRB(0.0, height1 * 0.8127, 0.0, 0.0),
              child: new Row(
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
//                    child: new RaisedButton.icon(
//                        onPressed: (){print('pressed');},
//                        icon: new Image.asset(
//                          'assets/captures.png',
//                          height: 20,
//                          width: 50,
//                        ),
//                        label: new Text('',
//                            style: new TextStyle(
//                              fontSize: 20.0,
//                            )),
//                        ),
                      child: FlatButton(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        onPressed:(){
                          flutterWebviewPlugin.hide();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => new CameraPage(
                                widget.meetingTitle, widget.meetingUuid)));
                        },
                        child: new Image.asset('assets/camera.png',
                          fit: BoxFit.cover,
                        height: height*0.06162241887,
                        width:width*0.13152777777,
                        ),
                      ),
//                    child: new FlatButton.icon(
//                      color: Colors.red,
//                      icon: Icon(Icons.add_a_photo), //`Icon` to display
//                      label: Text('Add a Photo'), //`Text` to display
//                      onPressed: () {
//                        flutterWebviewPlugin.hide();
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (BuildContext context) => new CameraPage(
//                                widget.meetingTitle, widget.meetingUuid)));
//                      },
//                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.fromLTRB(width1 * 0.57215, 0.0, 0.0, 0.0),
                      child: FlatButton(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        onPressed:(){
                          flutterWebviewPlugin.hide();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new Speech(widget.meetingUuid)));
                        },
                        child: new Image.asset('assets/audio_meeting.png',
                          fit: BoxFit.cover,
                          height: height*0.05162241887,
                          width:width*0.04861111111,
                        ),
                      ),
//                    child: new FlatButton.icon(
//                      color: Colors.red,
//                      icon: Icon(Icons.add_a_photo), //`Icon` to display
//                      label: Text('Hide'), //`Text` to display
//                      onPressed: () {
////              Code to execute when Floating Action Button is clicked
////              ...
//                        flutterWebviewPlugin.hide();
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (BuildContext context) =>
//                                new Speech(widget.meetingUuid)));
//                      },
//                    ),
                  ),
                ],
              ))
        ]),
      ),
    );
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

  Future<Null> fetchData() async {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        userToken = value;
        getRecentNotes();
        getRecentNotesCount(value);
      } else {
        utilities.showLongToast(value);
      }
    });
  }

  Future<String> getRecentNotes() async {
    final response = await api.getRecentNotes(widget.meetingUuid);
    if (response.statusCode == 200) {
      this.setState(() {
        data = json.decode(response.body);
        List<dynamic> rawNote = data['raw_note'];
        List<dynamic> attendees = data['attendees'];
        title = data['title'];
        if (data['raw_note'] != null && rawNote.length != 0) {
          rawHtml = data['raw_note'][0]['raw_html'];
          delta = data['raw_note'][0]['delta'];
          noteText = data['raw_note'][0]['body'];
        }
        attendeesEmail = new List();
        for (int i = 0; i < attendees.length; i++) {
          attendeesEmail.add('${data['attendees'][i]['email']}');
        }
        noteLoaded = true;
        finalDateTime = DateTimeFormatter.getDateTimeFormat(data['start_time']);
      });
    } else {
      // If that response was not OK, throw an error.
      noteLoaded = true;
      throw Exception('Failed to load post');
    }
    return '$SUCCESS';
  }

  Future<String> getRecentNotesCount(String token) async {
    final response =
        await api.getRecentNotesCount(token, widget.meetingEventId);
    if (response.statusCode == 200) {
      this.setState(() {
        attachmentCountData = json.decode(response.body);
        if (attachmentCountData.isNotEmpty) {
          attachmentCount = attachmentCountData[0]['count'];
        } else {
          attachmentCount = 0;
        }
        attachmentCountLoaded = true;
      });
    } else {
      // If that response was not OK, throw an error.
      attachmentCountLoaded = true;
      throw Exception('Failed to load post');
    }
    return '$SUCCESS';
  }

  @override
  void initState() {
    super.initState();
    BuildContext context;
    initConnectivity().then((result) {
      if (result) {
        this.fetchData();
      } else {
        noteLoaded = true;
        attachmentCountLoaded = true;
      }
    });
    flutterWebviewPlugin.close();
    onChangedValue4(context);
    int count=0;
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if(count==1) {
        if(url.startsWith('https://meetnotes-uploads.s3.amazonaws.com')){
          _downloadFile(url,'attachment-1');
        }
        else {
          launch(url);
          flutterWebviewPlugin.goBack();
        }
      }
      if(count==0){
        count=1;
      }
      print(url);
      print(count);
      print('TestinURL');


//      onData=url;
//      if (onData.toString() != url.toString()){
//        print(url);
//        print(onData);
//        flutterWebviewPlugin.close();
//        flutterWebviewPlugin.launch(url, rect: new Rect.fromLTWH(
//            0.0, 80.0, 430, 600.0),
//            userAgent: kAndroidUserAgent);
//      }
    });
  }

  bool value4 = false;
  MyInAppBrowser inAppBrowser = new MyInAppBrowser();

  void onChangedValue4(BuildContext contxt) {
    print(contxt);
    print('m');
//    double height = MediaQuery.of(contxt).size.height;
//    double width = MediaQuery.of(contxt).size.width;
//    print(height);
//    print(width);

//    inAppBrowser.open(
//        url: "https://app.meetnotes.co/m/${widget.meetingUuid}/",
//        rect: new Rect.fromLTWH(
//            0.0, 80.0, 430, 600.0),
//        options: {
//          "useShouldOverrideUrlLoading": true,
//          "useOnLoadResource": true,
//          "toolbarTop": false,
//        });
//    flutterWebviewPlugin.onUrlChanged.listen((onData) {
//
//
////      onData=selectedUrl;
//      if (onData.toString() != url.toString()){
//        print(url);
//        print(onData);
//        flutterWebviewPlugin.close();
//        flutterWebviewPlugin.launch(url, rect: new Rect.fromLTWH(
//            0.0, 80.0, 430, 600.0),
//            userAgent: kAndroidUserAgent);
//      }
//    });
  }
  static var httpClient = new HttpClient();
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
  void choiceAction(String choice) {
    if (choice == Constants.Share) {
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new Share(widget.meetingTitle, '$noteText',
                attendeesEmail, rawHtml, delta, widget.meetingUuid),
          ));
    } else {
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => Dashboard(),
          ));
    }
  }
}

class Constants {
  static const String Share = 'Share';
  static const String Leave = 'Leave';
  static const List<String> choices = <String>[
    Share,
    Leave,
  ];
}
