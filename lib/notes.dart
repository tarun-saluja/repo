import 'package:flutter/material.dart';

import './Detail.dart';
import './NotesClass.dart';
import './constants.dart';
import './duration.dart';

class Notes extends StatelessWidget {
  final List<NotesClass> notes;

  Notes([this.notes = const []]);

  @override
  Widget build(BuildContext context) {
    Widget noteCard = Center(child: CircularProgressIndicator());
    if (notes.length > 0) {
      noteCard = Container(
          padding: EdgeInsets.only(top: 20),
          child:ListView.builder(
        itemBuilder: _buildNoteItem,
        itemCount: notes.length,
      ));
    }

    return noteCard;
  }

  Widget _buildNoteItem(BuildContext context, int index) {
    var updatedAt;
    Duration diff =
        DateTime.now().difference(DateTime.parse(notes[index].updatedAt));
    updatedAt = duration(diff);

    var open = notes[index].actionItems;
    return  Container(
          height: 90,
          margin: new EdgeInsets.fromLTRB(10.0,5.0,10.0,5.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Detail(notes[index].meetingUuid,
                          notes[index].meetingTitle, notes[index].eventUuid)));
            },
            child: Card(
              elevation: 100.0,
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width:250,
                      child:
                      Text(
                            notes[index].meetingTitle,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: Color(0XFF5A6278)),
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(
                            'Last Modified $updatedAt',
                            style: TextStyle(color: Color(0XFFBCC4D1), fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              (open != 0)
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Color(0XFFF0F5F8)),
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 8.0, 11.0, 8.0),
                                      child: Text(
                                        '$open Open',
                                        style: TextStyle(
                                            color: Color(0XFF1DBC6F), fontSize: 14),
                                      ),
                                    )
                                  : Text(''),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'arrow.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
    );
  }
}
