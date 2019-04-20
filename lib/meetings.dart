import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memob/dateTimeFormatter.dart' as DateTimeFormatter;
import './Detail.dart';
import './constants.dart';
import './meetingClass.dart';

class holder {
  DateTime date;
  List<MeetingClass> meetinglist = new List<MeetingClass>();

  holder(DateTime date, List<MeetingClass> meetings) {
    this.date = date;
    this.meetinglist = meetings;
  }
}

List<holder> total_meeting = List<holder>();

class Meetings extends StatelessWidget {
  List<MeetingClass> meetings;
  List<MeetingClass> displaymeetings = new List<MeetingClass>();
  List<holder> total_meeting = new List<holder>();

  Meetings([this.meetings]);

  Widget build(BuildContext context) {
    @override
    Widget meetingCard = Center(
      child: CircularProgressIndicator(),
    );
    for (int i = 0; i < meetings.length; i++) {
      if ((DateTimeFormatter.isUpcomingMeeting(meetings[i].startTime)) ==
          false) {
        displaymeetings.add(meetings[i]);
      }

    }
    formatData(context);
    for(int i=0;i<total_meeting.length;i++){
      print(total_meeting[i].date);
      print(total_meeting[i].meetinglist.length);
    }

    meetingCard =
        ListView.builder(
      itemCount: total_meeting.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int parentIndex) {
        return new Container(
            padding: EdgeInsets.only(left:20, right: 20, bottom: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        dayprint(parentIndex),
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ],
                ),
                GridView.builder(
                  physics: ClampingScrollPhysics(),
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1.2),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildMeetingItem(context, parentIndex, index);
                  },
                  itemCount: total_meeting[parentIndex].meetinglist.length,
                  shrinkWrap: true,
                )
              ],
            ));
      },
    );
    return meetingCard;
  }

  String dayprint(int index){
    String formattedDate = DateFormat('EEE d MMM').format(total_meeting[index].date);
    if (index==0){
      return ('Today - '+formattedDate);
    }
    if (index==1){
      return ('Yesterday - ' + formattedDate);
    }
    return (formattedDate);
  }
  formatData(BuildContext context) {
    if(displaymeetings==null || displaymeetings.length ==0){
      return;
    }


    var date = new DateTime.now();
    for (int index = 0; index < displaymeetings.length; index = index + 1) {
      List<MeetingClass> meet = new List<MeetingClass>();
      int count=0;
      for (int index1 = 0;
      index1 < displaymeetings.length;
      index1++) {

        String x = displaymeetings[index1].startTime;
        int flag = 0;

        if (int.parse(x.substring(8, 10)) == (date.day)) {
          count=count+1;
          meet.add(displaymeetings[index1]);
//        print(count);
        }
      }

      holder h = new holder(date, meet);
      if(count>0) {
        total_meeting.add(h);
        index=index+count-1;
      }

//      print(MaterialLocalizations.of(context).firstDayOfWeekIndex);
      date = date.subtract(new Duration(days: 1));

    }
//    print(total_meeting[0]);

  }

  Widget _buildMeetingItem(BuildContext context,int parentIndex, int index) {
    var today = DateFormat.yMd().format(new DateTime.now());
    var display = total_meeting[parentIndex].meetinglist[index];
    var meetingDay = DateFormat.yMd().format(DateTime.parse(display.startTime));
    var isToday = today.compareTo(meetingDay);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var isUpcoming = DateTimeFormatter.isUpcomingMeeting(display.startTime);
    return Container(
          child:
          Container(
          margin: EdgeInsets.fromLTRB(
              height * 0.0045280235,
              height * 0.00645280235,
              height * 0.00645280235 * 0,
              height * 0.01945280235),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Detail(display.uuid, display.title, display.eventUuid),
                  ));
            },
            child: Card(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    height * 0.01845280235 * 2,
                    height * 0.02323008849,
                    height * 0.02323008849,
                    height * 0.02323008849),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                          decoration: new BoxDecoration(
                              color: (isToday == 0)
                                  ? (isUpcoming == true ? Colors.blue : Colors.blue)
                                  : Colors.grey[400],
                              border: Border.all(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(
                                  height * 0.01290560471 * 2)),
                          child: (isUpcoming == false)
                              ? ((isToday == 0)
                              ? isUpcoming == true
                              ? Text(
                            '$UPCOMING',
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.white),
                          )
                              : Text(
                            '$TODAY',
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.white),
                          )
                              : Text(
                            '${DateTimeFormatter.getDate(display.startTime)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ))
                              : null),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children:[
                      Container(
                        padding: EdgeInsets.only(bottom: 5.0),
                        alignment: Alignment.bottomLeft,
                          child:Text(
                        display.title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Color(0XFF5A6278)),
                      )),
                       Container(
                         alignment: Alignment.bottomLeft,
                           child:Text(
                          '${DateTimeFormatter.getTime(display.startTime)}',
                          style: TextStyle(fontSize: 15.0,fontFamily: 'Roboto', color: Color(0XFFBCC4D1)),
                        )),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ))
    );
  }
}
