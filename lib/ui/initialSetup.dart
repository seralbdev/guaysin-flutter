import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/ui/siteList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialSetupPage extends StatefulWidget {
  @override
  _InitialSetupPageState createState() => new _InitialSetupPageState();
}

class _InitialSetupPageState extends State<InitialSetupPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  bool firstTime;
  String _token;
  String _password;

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();

      // Token & password matched our validation rules
      // and are saved to _toke and _password fields.
      _performSetup().then((v){
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new SiteListPage()),
        );    
      });
    }
  }

  Future<void> _performSetup() async {
    return new Future<void>((){
      SharedPreferences.getInstance().then((sp) async {
        sp.setString('TOKEN', _token);
        final cs = getCryptoServiceInstance();
        await cs.createSecret(_password);
        return;      
      });    
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text('Initial setup'),
        automaticallyImplyLeading: false
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Form(
          key: formKey,
          child: new Column(
            children: [
              new TextFormField(
                decoration: new InputDecoration(labelText: 'Introduce TOKEN here...'),
                validator: (val) =>
                    val.isEmpty ? 'Must have a value' : null,
                onSaved: (val) => _token = val,
              ),
              new TextFormField(
                decoration: new InputDecoration(labelText: 'Introduce PASSWORD here...'),
                validator: (val) =>
                    val.length < 6 ? 'Password too short.' : null,
                onSaved: (val) => _password = val,
                obscureText: true,
              ),
              new Container(
                margin: const EdgeInsets.all(30.0),
                child: new RaisedButton(
                  onPressed: _submit,
                  child: new Text('Next')
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
