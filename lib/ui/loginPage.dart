import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/ui/siteList.dart';
import 'package:guaysin/services/localStorage.dart';
import 'package:guaysin/services/preferences.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  String _password;
  String _token;

  @override
  void initState() {
    super.initState();

    /*getCryptoService().secretReady().then((flag) {
      setState(() {
        _secretReady = flag;
      });
    });*/
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
        Navigator.pushReplacement(
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
      cs = getCryptoService();
      if (!await cs.unblockSecret(_password)) return false;
    } catch (e) {
      _showErrorMessage("Problem handling password");
      return false;
    }

    try {
      //Prepare local storage
      await initLocalStorage(cs);
    } catch (e) {
      _showErrorMessage("Problem handling local storage");
      return false;
    }

    return true;
  }

  void _fingerPrintLogin() async {
    try {
      var localAuth = new LocalAuthentication();
      bool didAuthenticate = await localAuth.authenticateWithBiometrics(
          localizedReason: 'Please authenticate');

      if (!didAuthenticate) {
        return;
      }

      //Handle secret
      final cs = getCryptoService();
      if (await cs.unblockKey()) {
        var localStorage = getLocalStorage();
        await initLocalStorage(cs);
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => new SiteListPage()));
      } else {
        _showErrorMessage("Problem unblocking key");
      }
    } catch (e) {
      _showErrorMessage("Generic error");
    }
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
                  new Column(children: <Widget>[
                    new Container(
                        margin: const EdgeInsets.all(30.0),
                        child: new RaisedButton(
                            onPressed: _submit, child: new Text('Login'))),
                    new Container(
                        margin: const EdgeInsets.all(60.0),
                        child: new RaisedButton(
                            onPressed: _fingerPrintLogin,
                            child: new Icon(Icons.fingerprint)))
                  ])
                ]))));
  }
}
