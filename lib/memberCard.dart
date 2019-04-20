import 'package:flutter/material.dart';

class MemberCard extends StatefulWidget {
  final List<dynamic> teamMembers;

  MemberCard([this.teamMembers]);

  @override
  State<StatefulWidget> createState() {
    return _MemberCard();
  }
}

class _MemberCard extends State<MemberCard> {
  List<dynamic> _teamMembers = new List();

  @override
  void initState() {
    _teamMembers = widget.teamMembers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget memberCard = Center(
      child: CircularProgressIndicator(),
    );

    if (_teamMembers.length > 0) {
      memberCard = ListView.builder(
        itemBuilder: _buildMemberCard,
        itemCount: _teamMembers.length,
      );
    }

    return memberCard;
  }

  Widget _buildMemberCard(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.all(10),
      // child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(children: <Widget>[
            (_teamMembers[index]['user']['profile_picture'] != null)
                ? (CircleAvatar(
                    backgroundImage: NetworkImage(
                        _teamMembers[index]['user']['profile_picture']),
                  ))
                : (CircleAvatar(
                    backgroundImage: AssetImage('assets/blank_user.jpeg'),
                  )),
            Text('   '),
            Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_teamMembers[index]['user']['display_name']),
                    Text(
                      _teamMembers[index]['user']['email'],
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    )
                  ],
                )),
          ]),
          Text(_teamMembers[index]['role'])
        ],
        //  ),
      ),
    );
  }
}
