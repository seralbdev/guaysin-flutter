import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String _USER_TOKEN_ID = "USER_TOKEN";

void setUserToken(String value) async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
  await sp.setString(_USER_TOKEN_ID, value);
}

Future<String> getUserToken() async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
  String ut = await sp.getString(_USER_TOKEN_ID);
  return ut;
}