import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:memob/actionClass.dart';
import 'package:memob/utilities.dart' as utilities;

import './constants.dart';
import './api_service.dart';

duration(Duration diff){
  var createdAt;
  if (diff.inDays > 365)
    createdAt =
    "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  else if (diff.inDays > 30)
    createdAt =
    "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  else if (diff.inDays > 7)
    createdAt =
    "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  else if (diff.inDays > 0)
    createdAt = "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  else if (diff.inHours > 0)
    createdAt = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  else if (diff.inMinutes > 0)
    createdAt =
    "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  else
    createdAt = "$JUST_NOW";

  return createdAt;

}