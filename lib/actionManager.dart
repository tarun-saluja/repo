import 'package:flutter/material.dart';
import 'package:memob/actionClass.dart';
import 'package:memob/actions.dart';

class ActionManager extends StatefulWidget {
  List<ActionClass> allActions = [];
  List<dynamic> meetings = [];
  List<dynamic> assignees = [];

  ActionManager([this.allActions, this.meetings, this.assignees]);

  @override
  State<StatefulWidget> createState() {
    return _ActionManagerState();
  }
}

class _ActionManagerState extends State<ActionManager> {
  List<ActionClass> _allActions = [];
  List<dynamic> _meetings = [];
  List<dynamic> _assignees = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Actions(_allActions, _meetings, _assignees),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.allActions != null ||
        widget.assignees != null ||
        widget.meetings != null) {
      _allActions = widget.allActions;
      _assignees = widget.assignees;
      _meetings = widget.meetings;
    }
  }
}
