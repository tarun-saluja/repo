import 'package:flutter/material.dart';
import 'package:memob/NotesClass.dart';

import './constants.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$SEARCH_APP'),
      ),
      drawer: Drawer(),
    );
  }
}

class DataSearch extends SearchDelegate<NotesClass> {
  List<NotesClass> _notes;

  DataSearch([this._notes]);

  List<String> names = new List();

  final recentNames = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentNames
        : _notes
            .where((p) => p.meetingTitle.toLowerCase().contains(query))
            .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.title),
            title: Text(suggestionList[index].meetingTitle),
            onTap: () {
              close(context, suggestionList[index]);
            },
          ),
      itemCount: suggestionList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentNames
        : _notes
            .where((p) => p.meetingTitle.toLowerCase().contains(query))
            .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.title),
            title: Text(suggestionList[index].meetingTitle),
            onTap: () {
              close(context, suggestionList[index]);
            },
          ),
      itemCount: suggestionList.length,
    );
  }
}
