String getUpdatedAt(String dateTimeString) {
  var updateTime = DateTime.parse(dateTimeString).toLocal();
  var currentTime = new DateTime.now().toLocal();

  if (currentTime.year - updateTime.year > 0) {
    if (currentTime.year - updateTime.year == 1)
      return 'Last updated a year ago';
    else
      return 'Last updated ' +
          (currentTime.year - updateTime.year).toString() +
          ' years ago';
  } else if (currentTime.month - updateTime.month > 0) {
    if (currentTime.month - updateTime.month == 1)
      return 'Last updated a month ago';
    else
      return 'Last updated ' +
          (currentTime.month - updateTime.month).toString() +
          ' months ago';
  } else if (currentTime.day - updateTime.day > 0) {
    if (currentTime.day - updateTime.day == 1)
      return 'Last updated a day ago';
    else
      return 'Last updated ' +
          (currentTime.day - updateTime.day).toString() +
          ' days ago';
  } else if (currentTime.hour - updateTime.hour > 0) {
    if (currentTime.hour - updateTime.hour == 1) {
      if (currentTime.minute - updateTime.minute > 0) {
        return 'Last updated an hour ago';
      } else {
        int currentMinute = currentTime.minute + 60;
        int updatedAtMinute = updateTime.minute;

        return 'Last updated ' +
            (currentMinute - updatedAtMinute).toString() +
            ' minute ago';
      }
    } else
      return 'Last updated ' +
          (currentTime.hour - updateTime.hour).toString() +
          ' hours ago';
  } else if (currentTime.minute - updateTime.minute > 0) {
    if (currentTime.minute - updateTime.minute == 1)
      return 'Last updated a minute ago';
    else
      return 'Last updated ' +
          (currentTime.minute - updateTime.minute).toString() +
          ' minutes ago';
  } else {
    return 'updated Now';
  }
}
