import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:memob/memberCard.dart';

import './api_service.dart';

class InviteMembers extends StatefulWidget {
  final String userToken;

  InviteMembers([this.userToken]);

  @override
  State<StatefulWidget> createState() {
    return _InviteMembers();
  }
}

class _InviteMembers extends State<InviteMembers> {
  String _userToken;
  List<dynamic> teamMembers = new List();

  @override
  void initState() {
    _userToken = widget.userToken;
    getTeamMembers();
    super.initState();
  }

  Future<Null> getTeamMembers() async {
    final response = await api.getTeamMembersDetails();
    if (response.statusCode == 200) {
      this.setState(() {
        teamMembers.clear();
        Map<String, dynamic> mData = json.decode(response.body);

        List<dynamic> list = mData['members'];

        for (int i = 0; i < list.length; i++) {
          teamMembers.add(list[i]);
        }
      });
      return null;
    } else {
      // If that response was not OK, throw an error.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MemberCard(teamMembers),
    );
  }
}
