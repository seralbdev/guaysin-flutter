import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String _USER_TOKEN_ID = "USER_TOKEN";
const String _GENERATE_KEY_FLAG = "USER_TOKEN";
const String _INIT_DONE_FLAG = "INIT_DONE";

abstract class Preferences{
  Future setUserToken(String value);
  Future<String> getUserToken();
  Future setInitDoneFlag();
  Future<bool> getInitDoneFlag();
}

class _Preferences implements Preferences {

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

  Future setInitDoneFlag() async {
    final sp  = await SharedPreferences.getInstance();
    await sp.setBool(_INIT_DONE_FLAG,true);
  }

  Future<bool> getInitDoneFlag() async {
    final sp  = await SharedPreferences.getInstance();
    final flag = await sp.getBool(_INIT_DONE_FLAG);
    if(flag==null)
      return false;
    return true;
  }
}

final _preferencesInstace = new _Preferences();

Preferences getPreferences(){
  return _preferencesInstace;
}

