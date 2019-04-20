import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:memob/actionClass.dart';
import 'package:memob/utilities.dart' as utilities;

import './constants.dart';
import './api_service.dart';
import './duration.dart';

class Actions extends StatefulWidget {
  final List<ActionClass> allActions;
  final List<dynamic> meetings;
  final List<dynamic> assignees;

  Actions(
      [this.allActions = const [],
      this.meetings = const [],
      this.assignees = const []]);

  @override
  State<StatefulWidget> createState() {
    return _Actions();
  }
}

class _Actions extends State<Actions> {
  List<ActionClass> allActions;
  List<dynamic> meetings;
  List<dynamic> assignees;
  String userToken;

  @override
  void initState() {
    super.initState();
    allActions = widget.allActions;
    meetings = widget.meetings;
    assignees = widget.assignees;
  }

  Widget _buildActionItem(BuildContext context, int index) {
    var createdAt;
    Duration diff =
        DateTime.now().difference(DateTime.parse(allActions[index].createdAt));
    createdAt = duration(diff);

    return Container(
        height: 130,
        margin: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
        child: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                    title: Text(meetings[index]['title']),
                    content: Container(child: Text(allActions[index].note))));
          },
          child: Card(
            elevation: 100.0,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                allActions[index].profilePicture != null
                                    ? (CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          allActions[index].profilePicture,
                                        ),
                                        maxRadius: 17,
                                      ))
                                    : (CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/blank_user.jpeg'),
                                        maxRadius: 17,
                                      )),
                                Text('  '),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    (assignees[index] != null)
                                        ? Text(
                                            assignees[index]['display_name'],
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87),
                                          )
                                        : Text(NO_ASSIGNEE,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54)),
                                    Text(
                                      createdAt,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    )
                                  ],
                                )
                              ])),
                      Row(children: <Widget>[
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: (allActions[index].status == 'pending')
                                  ? Colors.pink
                                  : (allActions[index].status == 'doing'
                                      ? Colors.blue[400]
                                      : Colors.green[400])),
                          child: Text(
                            allActions[index].status,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          child: PopupMenuButton<String>(
                            onSelected: (choice) => choiceAction(choice, index),
                            itemBuilder: (BuildContext context) {
                              return Status.choices.map((String choice) {
                                return (choice != allActions[index].status)
                                    ? PopupMenuItem<String>(
                                        value: choice, child: Text(choice))
                                    : (null);
                              }).toList();
                            },
                          ),
                        ),
                      ])
                    ]),
                Container(
                  margin: EdgeInsets.fromLTRB(18, 2.0, 30, 0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(
                            allActions[index].note,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 15),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Widget actionCard = Center(
      child: CircularProgressIndicator(),
    );
    if (allActions.length > 0) {
      actionCard = ListView.builder(
        itemBuilder: _buildActionItem,
        itemCount: allActions.length,
      );
    }

    return actionCard;
  }

  void choiceAction(String choice, int index) {
    String url = api.choiceAction(allActions[index].uuid);

    Map body;
    if (choice == Status.Doing) {
      body = {'new_value': "doing", 'field': "status"};
      setState(() {
        allActions[index].status = 'doing';
      });
    } else if (choice == Status.Done) {
      body = {'new_value': "done", 'field': "status"};
      setState(() {
        allActions[index].status = 'done';
      });
    } else {
      body = {'new_value': "pending", 'field': "status"};
      setState(() {
        allActions[index].status = 'pending';
      });
    }
    apiRequest(url, body);
  }

  Future<Null> apiRequest(String url, Map body) async {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        userToken = value;
        statusUpdate(url, body);
      } else {
        utilities.showLongToast(value);
        return null;
      }
    });

    return null;
  }

  Future<Null> statusUpdate(String url, Map body) async {
    var data = json.encode(body);
    var response = await http.patch(url,
        headers: {
          HttpHeaders.authorizationHeader: 'Token $userToken',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        },
        body: data);
  }
}

class Status {
  static const String Pending = 'pending';
  static const String Doing = 'doing';
  static const String Done = 'done';

  static const List<String> choices = <String>[
    Pending,
    Doing,
    Done,
  ];
}
