import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getTokenData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? null;
  return token;
}

void showLongToast(String text) {
  Fluttertoast.showToast(
    msg: "$text",
    toastLength: Toast.LENGTH_LONG,
  );
}

Future<Null> setTokenData(String token) async {
  if (token != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }
}

Future<Null> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
}
