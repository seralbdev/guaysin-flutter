import 'package:flutter/material.dart';
import 'package:guaysin/ui/initPage.dart';
import 'package:guaysin/ui/loginPage.dart';
import 'package:guaysin/services/preferences.dart';

void main() async {

  final appInitFlag = await getPreferences().getInitDoneFlag();

  runApp(new MyApp(!appInitFlag));
}

class MyApp extends StatelessWidget {
  bool firstTimeFlag;

  // This widget is the root of your application.

  MyApp(bool this.firstTimeFlag){
  }

  Widget _getHomePage(){
    if(firstTimeFlag)
      return new InitPage();
    return new LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Guaysin',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home:_getHomePage(),
    );
  }
}