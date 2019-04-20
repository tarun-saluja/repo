import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:memob/inviteMembers.dart';
import 'package:memob/utilities.dart' as utilities;

import './constants.dart';
import './api_service.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Settings();
  }
}

class _Settings extends State<Settings> {
  bool dailyEmail;
  bool dailySlack;
  bool meetingReminder;
  bool meetingAgenda;
  bool meetingsFeedback;
  String name;
  String email;
  String aliasemail;
  String userToken;
  String title = '$PROFILE_INFO';
  bool profileInformation = true;
  bool aliases = false;
  String aliasEmail = "";
  TextEditingController aliasController = new TextEditingController();
  TextEditingController inviteController = new TextEditingController();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$SETTINGS'),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: Icon(Icons.filter),
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return SettingFilters.choices.map((String filter) {
                  return PopupMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: (dailyEmail != null)
            ? ((profileInformation == true)
                ? ((Container(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      child: ListView(
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(fontSize: 25),
                          ),
                          Divider(),
                          Text(''),
                          Text('Name'),
                          Text(''),
                          TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                                labelText: name,
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black))),
                          ),
                          Text(''),
                          Text('$EMAIL'),
                          Text(''),
                          TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                                labelText: email,
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black))),
                          ),
                          Text(''),
                          Text('$NOTIFICATION_PREF'),
                          Text(''),
                          CheckboxListTile(
                            title: Text('$SEND_VIA_EMAIL'),
                            value: this.dailyEmail,
                            onChanged: (bool val) {
                              this.setState(() {
                                dailyEmail = !dailyEmail;
                              });
                              Map body = {
                                "settings": {"$DAILY_SUMMARY": dailyEmail}
                              };
                              settingsUpdate(body);
                            },
                          ),
                          CheckboxListTile(
                            title: Text('$SEND_VIA_SLACK'),
                            value: this.dailySlack,
                            onChanged: (bool val) {
                              this.setState(() {
                                dailySlack = !dailySlack;
                              });
                              Map body = {
                                "settings": {
                                  "DAILY_SUMMARY_SLACK_REMINDER": dailySlack
                                }
                              };
                              settingsUpdate(body);
                            },
                          ),
                          CheckboxListTile(
                            title: Text('Meeting Reminder'),
                            value: this.meetingReminder,
                            onChanged: (bool val) {
                              this.setState(() {
                                meetingReminder = !meetingReminder;
                              });
                              Map body = {
                                "settings": {
                                  "MEETING_REMINDER": meetingReminder
                                }
                              };
                              settingsUpdate(body);
                            },
                          ),
                          CheckboxListTile(
                            title: Text('Meeting Agenda Reminder'),
                            value: this.meetingAgenda,
                            onChanged: (bool val) {
                              this.setState(() {
                                meetingAgenda = !meetingAgenda;
                              });
                              Map body = {
                                "settings": {
                                  "MEETING_AGENDA_REMINDER": meetingAgenda
                                }
                              };
                              settingsUpdate(body);
                            },
                          ),
                          CheckboxListTile(
                            title: Text('Daily Meetings Feedback'),
                            value: this.meetingsFeedback,
                            onChanged: (bool val) {
                              this.setState(() {
                                meetingsFeedback = !meetingsFeedback;
                              });
                              Map body = {
                                "settings": {
                                  "DAILY_FEEDBACK_REMINDER": meetingsFeedback
                                }
                              };
                              settingsUpdate(body);
                            },
                          )
                        ],
                      ),
                    ),
                  )))
                : (aliases == true)
                    ? ((Container(
                        padding: EdgeInsets.all(20),
                        child: Form(
                            child: ListView(children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(fontSize: 25),
                          ),
                          Divider(),
                          Text(''),
                          Text('Email', style: TextStyle(fontSize: 15.0),),
                          Text(''),
                          TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                                labelText: email,
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black))),
                          ),
                          Text(''),
                          Text('Other Email Aliases', style: TextStyle(fontSize: 15.0),),
                          Text(''),
                          Text(
                            '$aliasemail'
                          ),
                          Text(''),
                          TextFormField(
                            controller: aliasController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black))),
                            onSaved: (String value) {
                              this.aliasEmail = value;
                            },
                            style: TextStyle(height: 1.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0,8.0,0.0,0.0),
                            child: RaisedButton(
                              child: Text('+Add Another Aliases'),
                              color: Colors.blue,
                              onPressed: () {
                                Map body = {"email": aliasController.text};
                                addAliases(body);
                              },
                            ),
                          )
                        ])))))
                    : (Container(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: InviteMembers(userToken),
                            ),
                            TextFormField(
                              controller: inviteController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black))),
                            ),
                            RaisedButton(
                              child: Text('Invite Members'),
                              color: Colors.blue,
                              onPressed: () {
                                String email = inviteController.text;
                                Map body = {
                                  "email": [email]
                                };
                                inviteMember(body);
                              },
                            )
                          ],
                        ),
                      )))
            : (Center(
                child: CircularProgressIndicator(),
              )));
  }

  Future<Null> fetchData() async {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        userToken = value;
        fetchUserData();
        getAliases();
      } else {
        utilities.showLongToast(value);
        return null;
      }
    });
  }

  Future<Null> fetchUserData() async {
    final response = await api.fetchUserData();

    if (response.statusCode == 200) {
      this.setState(() {
        Map<String, dynamic> mData = json.decode(response.body);
        name = mData['user']['username'];
        email = mData['user']['email'];
        dailyEmail = mData["notification_settings"]["DAILY_SUMMARY"];
        dailySlack =
            mData["notification_settings"]["DAILY_SUMMARY_SLACK_REMINDER"];
        meetingReminder = mData["notification_settings"]["MEETING_REMINDER"];
        meetingAgenda =
            mData["notification_settings"]["MEETING_AGENDA_REMINDER"];
        meetingsFeedback =
            mData["notification_settings"]["DAILY_FEEDBACK_REMINDER"];
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  Future<Null> settingsUpdate(Map body) async {
    var response =
        await api.settingsUpdate(body);
  }

  Future<Null> addAliases(Map body) async {

    var response = await api.addAliases(body);
  }

  Future<Null> getAliases() async {
//    print(userToken);
    var response = await api.getAliases();
    print(response.body);
    if (response.statusCode == 200) {
      this.setState(() {
        List<dynamic> mData = json.decode(response.body);
        aliasemail = mData[0]['email'];
        print(mData[0]["email"]);

      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  Future<Null> inviteMember(Map body) async {
    var response = await api.inviteMember(body);
  }
  void choiceAction(String choice) async {
    if (choice == SettingFilters.ProfileInformation) {
      setState(() {
        title = 'Profile Information';
        profileInformation = true;
        aliases = false;
      });
    } else if (choice == SettingFilters.Aliases) {
      setState(() {
        title = 'Aliases';
        profileInformation = false;
        aliases = true;
      });
    } else if (choice == SettingFilters.InviteMembers) {
      setState(() {
        profileInformation = false;
        aliases = false;
      });
    }
  }
}

class SettingFilters {
  static const String ProfileInformation = 'Profile Information';
  static const String Aliases = 'Aliases';
  static const String InviteMembers = 'Invite Members';

  static const List<String> choices = <String>[
    ProfileInformation,
    Aliases,
    InviteMembers
  ];
}
