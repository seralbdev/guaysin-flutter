import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/ui/siteList.dart';
import 'package:guaysin/services/localStorage.dart';
import 'package:guaysin/services/preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  bool _secretReady;
  String _password;
  String _token;

  @override
  void initState() {
    super.initState();

    getCryptoServiceInstance().secretReady().then((flag) {
      setState(() {
        _secretReady = flag;
      });
    });
  }

  void _showErrorMessage(String msg) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(msg)));
  }

  void _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      var res = await _performLogin();
      if (res) {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new SiteListPage()),
        );
      } else {
        _showErrorMessage("Wrong password");
      }
    }
  }

  Future<bool> _performLogin() async {
    var cs;
    try {
      //Handle secret
      cs = getCryptoServiceInstance();
      if (_secretReady) {
        if (!await cs.unblockSecret(_password)) return false;
      } else {
        await cs.createSecret(_password);
        await setUserToken(_token);
      }
    } catch (e) {
      _showErrorMessage("Problem handling password");
      return false;
    }

    try {
      //Prepare local storage
      var localStorage = LocalStorage.get();
      await localStorage.init(cs);
    } catch (e) {
      _showErrorMessage("Problem handling local storage");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
            title: new Text('Login page'), automaticallyImplyLeading: false),
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
                  !_secretReady
                      ? new Column(children: <Widget>[
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
                          )
                        ])
                      : new Container(width: 0.0, height: 0.0),
                  Container(
                      margin: const EdgeInsets.all(30.0),
                      child: new RaisedButton(
                          onPressed: _submit, child: new Text('Login')))
                ]))));
  }
}
