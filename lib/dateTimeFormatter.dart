var finalDateTime;
var days = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"];
var months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

bool isUpcomingMeeting(var dateTimeString) {
  var meetingDay = DateTime.parse(dateTimeString).toLocal();
  var today = new DateTime.now();
  return meetingDay.isAfter(today);
}

String getDateTimeFormat(var dateTimeString) {
  var dateTime = DateTime.parse(dateTimeString).toLocal();

  var day = days[dateTime.weekday - 1];
  var month = months[dateTime.month - 1];
  var date = dateTime.day;
  var minute = dateTime.minute < 10
      ? ('0' + dateTime.minute.toString())
      : dateTime.minute.toString();

  var time;
  if (dateTime.hour < 12) {
    time = dateTime.hour.toString() + ':' + minute + ' a.m';
  } else if (dateTime.hour == 12) {
    time = (dateTime.hour).toString() + ':' + minute + ' p.m';
  } else {
    time = (dateTime.hour % 12).toString() + ':' + minute + ' p.m';
  }

  finalDateTime = day + ' - ' + date.toString() + ' ' + month + ' at ' + time;

  return finalDateTime.toString();
}

String getTime(var dateTimeString) {
  var dateTime = DateTime.parse(dateTimeString).toLocal();
  var time;

  var minute = dateTime.minute < 10
      ? ('0' + dateTime.minute.toString())
      : dateTime.minute.toString();

  if (dateTime.hour < 12) {
    time = dateTime.hour.toString() + ':' + minute + ' a.m';
  } else if (dateTime.hour == 12) {
    time = (dateTime.hour).toString() + ':' + minute + ' p.m';
  } else {
    time = (dateTime.hour % 12).toString() + ':' + minute + ' p.m';
  }

  return time.toString();
}

String getDate(var dateTimeString) {
  var dateTime = DateTime.parse(dateTimeString).toLocal();
  var time;

  var month = months[dateTime.month - 1];
  var date = dateTime.day;

  time = date.toString() + ' ' + month;

  return time.toString();
}
