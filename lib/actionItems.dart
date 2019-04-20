import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:memob/actionClass.dart';
import 'package:memob/actionManager.dart';
import 'package:memob/drawer.dart';
import 'package:memob/utilities.dart' as utilities;

import './constants.dart';
import './api_service.dart';

class ActionItems extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ActionItems();
  }
}

class _ActionItems extends State<ActionItems> {
  List<ActionClass> actions = new List();
  List assignees = new List();
  List meetings = new List();

  List<ActionClass> allActions = new List();
  List allAssignees = new List();
  List allMeetings = new List();

  List<ActionClass> openAllActions = new List();
  List openAssignees = new List();
  List openMeetings = new List();

  List<ActionClass> closedAllActions = new List();
  List closedAssignees = new List();
  List closedMeetings = new List();

  List<ActionClass> updatedAllActions = new List();
  List updatedAssignees = new List();
  List updatedMeetings = new List();

  List<ActionClass> myActions = new List();
  List myAssignees = new List();
  List myMeetings = new List();

  String userToken;
  int userID;
  String displayName;
  String profile_picture;
  bool _connectionStatus = false;


  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(ACTION_ITEMS),
            actions: <Widget>[
              PopupMenuButton<String>(
                // icon: Icon(
                //   Icons.filter
                // ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/filter.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                onSelected: choiceAction,
                itemBuilder: (BuildContext context) {
                  return Filters.choices.map((String filter) {
                    return PopupMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList();
                },
              )
            ],
            bottom: TabBar(
              indicatorWeight: 3,
              unselectedLabelColor: Color(0XFF8A93AA),
              labelColor: Color(0XFF1794FF),
              tabs: <Widget>[
                Tab(
                  text: 'All ' + ACTION,
                ),
                Tab(
                  text: 'My ' + ACTION,
                )
              ],
            ),
          ),
          drawer: Dwidget(userToken, displayName, profile_picture),
          body: Container(
            decoration: BoxDecoration(
              image: new DecorationImage(
                  image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
            ),
            child: TabBarView(
              children: <Widget>[
                ActionManager(actions, meetings, assignees),
                ActionManager(myActions, myMeetings, myAssignees)
              ],
            ),
          ),
        ),
      ),
    );
  }

  final Connectivity _connectivity = new Connectivity();

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
    } catch (PlatformException) {
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
        getAllActionsData();
        getRecentlyClosedActionsData();
        getRecentlyUpdatedActionsData();
        getOpenActionsData();
      } else {
        utilities.showLongToast(value);
        return null;
      }
    });
  }

  Future<Null> getAllActionsData() async {
    final response = await api.getAllActions();

    if (response.statusCode == 200) {
      this.setState(() {
        Map<String, dynamic> mData = json.decode(response.body);

        List<dynamic> list = mData['results'];

        for (int i = 0; i < list.length; i++) {
          allAssignees.add(mData['results'][i]['assignee']);
        }

        for (int i = 0; i < list.length; i++) {
          allMeetings.add(mData['results'][i]['meeting']);
        }

        for (var actionData in list) {
          if (actionData['assignee'] != null) {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              //actionData['meeting'],
              actionData['note'],
              actionData['assignee']['profile_picture'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              // actionData['tags'],
              actionData['isExternallyModified'],
              //  actionData['comments'],
            );
            allActions.add(action);
          } else {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              //actionData['meeting'],
              actionData['note'],
              actionData['assignee'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              // actionData['tags'],
              actionData['isExternallyModified'],
              //  actionData['comments'],
            );
            allActions.add(action);
          }
        }
        getUserDetails();
        for (var i = 0; i < allActions.length; i++) {
          actions.add(allActions[i]);
          assignees.add(allAssignees[i]);
          meetings.add(allMeetings[i]);
        }
        //getUserId();
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  Future<Null> getUserDetails() async {
    final response = await api.getUser();

    if (response.statusCode == 200) {
      this.setState(() {
        Map<String, dynamic> mData = json.decode(response.body);
        userID = mData['user']['id'];
        displayName = mData['user']['display_name'];
        profile_picture = mData['user']['profile_picture'];
        for (var i = 0; i < allActions.length; i++) {
          if (allAssignees[i] != null && allAssignees[i]['id'] == userID) {
            myActions.add(allActions[i]);
            myAssignees.add(allAssignees[i]);
            myMeetings.add(allMeetings[i]);
          }
        }
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  @override
  initState() {
    initConnectivity().then((result) {
      if (result) {
        this.fetchData();
      }
    });
    super.initState();
  }

  Future<Null> getOpenActionsData() async {
    final response = await api.getOpenActions();

    if (response.statusCode == 200) {
      this.setState(() {
        Map<String, dynamic> mData = json.decode(response.body);

        List<dynamic> list = mData['results'];

        for (int i = 0; i < list.length; i++) {
          openAssignees.add(mData['results'][i]['assignee']);
        }

        for (int i = 0; i < list.length; i++) {
          openMeetings.add(mData['results'][i]['meeting']);
        }

        for (var actionData in list) {
          if (actionData['assignee'] != null) {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              //actionData['meeting'],
              actionData['note'],
              actionData['assignee']['profile_picture'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              // actionData['tags'],
              actionData['isExternallyModified'],
              //  actionData['comments'],
            );
            openAllActions.add(action);
          } else {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              //actionData['meeting'],
              actionData['note'],
              actionData['assignee'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              // actionData['tags'],
              actionData['isExternallyModified'],
              //  actionData['comments'],
            );
            openAllActions.add(action);
          }
        }
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  Future<Null> getRecentlyUpdatedActionsData() async {
    final response = await api.getRecentlyUpdatedActions();

    if (response.statusCode == 200) {
      this.setState(() {
        Map<String, dynamic> mData = json.decode(response.body);

        List<dynamic> list = mData['results'];

        for (int i = 0; i < list.length; i++) {
          updatedAssignees.add(mData['results'][i]['assignee']);
        }

        for (int i = 0; i < list.length; i++) {
          updatedMeetings.add(mData['results'][i]['meeting']);
        }

        for (var actionData in list) {
          if (actionData['assignee'] != null) {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              actionData['note'],
              actionData['assignee']['profile_picture'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              actionData['isExternallyModified'],
            );
            updatedAllActions.add(action);
          } else {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              actionData['note'],
              actionData['assignee'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              actionData['isExternallyModified'],
            );
            updatedAllActions.add(action);
          }
        }
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  Future<Null> getRecentlyClosedActionsData() async {
    final response = await api.getRecentlyClosedActions();

    if (response.statusCode == 200) {
      this.setState(() {
        Map<String, dynamic> mData = json.decode(response.body);

        List<dynamic> list = mData['results'];

        for (int i = 0; i < list.length; i++) {
          closedAssignees.add(mData['results'][i]['assignee']);
        }

        for (int i = 0; i < list.length; i++) {
          closedMeetings.add(mData['results'][i]['meeting']);
        }

        for (var actionData in list) {
          if (actionData['assignee'] != null) {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              actionData['note'],
              actionData['assignee']['profile_picture'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              actionData['isExternallyModified'],
            );
            closedAllActions.add(action);
          } else {
            ActionClass action = new ActionClass(
              actionData['uuid'],
              actionData['event_uuid'],
              actionData['note'],
              actionData['assignee'],
              actionData['assigned_to'],
              actionData['status'],
              actionData['is_deleted'],
              actionData['created_at'],
              actionData['due_date'],
              actionData['isExternallyModified'],
            );
            closedAllActions.add(action);
          }
        }
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  void choiceAction(String choice) async {
    actions.clear();
    assignees.clear();
    meetings.clear();
    myActions.clear();
    myAssignees.clear();
    myMeetings.clear();
    if (choice == Filters.Everything) {
      this.setState(() {
        for (var i = 0; i < allActions.length; i++) {
          actions.add(allActions[i]);
          assignees.add(allAssignees[i]);
          meetings.add(allMeetings[i]);
          if (allAssignees[i] != null && allAssignees[i]['id'] == userID) {
            myActions.add(actions[i]);
            myAssignees.add(assignees[i]);
            myMeetings.add(meetings[i]);
          }
        }
      });
    } else if (choice == Filters.OpenActions) {
      this.setState(() {
        for (var i = 0; i < openAllActions.length; i++) {
          actions.add(openAllActions[i]);
          assignees.add(openAssignees[i]);
          meetings.add(openMeetings[i]);
          if (assignees[i] != null && assignees[i]['id'] == userID) {
            myActions.add(actions[i]);
            myAssignees.add(assignees[i]);
            myMeetings.add(meetings[i]);
          }
        }
      });
    } else if (choice == Filters.RecentlyUpdated) {
      this.setState(() {
        for (var i = 0; i < updatedAllActions.length; i++) {
          actions.add(updatedAllActions[i]);
          assignees.add(updatedAssignees[i]);
          meetings.add(updatedMeetings[i]);
          if (assignees[i] != null && assignees[i]['id'] == userID) {
            myActions.add(actions[i]);
            myAssignees.add(assignees[i]);
            myMeetings.add(meetings[i]);
          }
        }
      });
    } else if (choice == Filters.RecentlyClosed) {
      this.setState(() {
        for (var i = 0; i < closedAllActions.length; i++) {
          actions.add(closedAllActions[i]);
          assignees.add(closedAssignees[i]);
          meetings.add(closedMeetings[i]);
          if (assignees[i] != null && assignees[i]['id'] == userID) {
            myActions.add(actions[i]);
            myAssignees.add(assignees[i]);
            myMeetings.add(meetings[i]);
          }
        }
      });
    }
  }
}

class Filters {
  static const String Everything = 'Everything';
  static const String OpenActions = 'All Open Actions';
  static const String RecentlyUpdated = 'Recently Updated';
  static const String RecentlyClosed = 'Recently Closed';

  static const List<String> choices = <String>[
    Everything,
    OpenActions,
    RecentlyUpdated,
    RecentlyClosed
  ];
}
