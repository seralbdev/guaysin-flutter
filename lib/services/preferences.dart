import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String _USER_TOKEN_ID = "USER_TOKEN";
const String _GENERATE_KEY_FLAG = "USER_TOKEN";

Future setUserToken(String value) async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
  await sp.setString(_USER_TOKEN_ID, value);
}

Future<String> getUserToken() async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
  String ut = await sp.getString(_USER_TOKEN_ID);
  return ut;
}

Future setGenerateKeyFlag(bool value) async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
  await sp.setBool(_GENERATE_KEY_FLAG,value);
}

Future<bool> getGenerateKeyFlag() async {
  SharedPreferences sp  = await SharedPreferences.getInstance();
  final flag = await sp.getBool(_GENERATE_KEY_FLAG);
  return flag;
}