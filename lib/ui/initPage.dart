import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/services/preferences.dart';
import 'package:guaysin/ui/loginPage.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => new _InitPageState();
}

class _InitPageState extends State<InitPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  String _password;
  String _token;

  @override
  void initState() {
    super.initState();
  }

  void _showErrorMessage(String msg) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(msg)));
  }

  void _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      try {
        await _initializeApp();
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(builder: (context) => new LoginPage()),
        );
      } catch (ex) {
        _showErrorMessage(ex);
      }
    }
  }

  Future _initializeApp() async {
    final cs = getCryptoService();
    await cs.createSecret(_password);
    final pref = getPreferences();
    await pref.setUserToken(_token);
    await pref.setInitDoneFlag();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
            title: new Text('First time setup'), automaticallyImplyLeading: false),
        body: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Form(
                key: formKey,
                child: new Column(children: [
                  new TextFormField(
                    decoration: new InputDecoration(
                        labelText: 'Introduce PASSWORD here...'),
                    validator: (val) =>
                        val.length < 6 ? 'Password too short.' : null,
                    onSaved: (val) => _password = val,
                    obscureText: true,
                  ),
                  new TextFormField(
                      decoration: new InputDecoration(
                          labelText: 'Introduce PASSWORD again...'),
                      validator: (val) =>
                          val.length < 6 ? 'Password too short.' : null,
                      onSaved: (val) => _password = val,
                      obscureText: true),
                  new TextFormField(
                    decoration: new InputDecoration(
                        labelText: 'Introduce TOKEN here...'),
                    validator: (val) =>
                        val.isEmpty ? 'Must have a value' : null,
                    onSaved: (val) => _token = val,
                  ),
                  new Container(
                      margin: const EdgeInsets.all(30.0),
                      child: new RaisedButton(
                          onPressed: _submit, child: new Text('Start')))
                ]))));
  }
}
