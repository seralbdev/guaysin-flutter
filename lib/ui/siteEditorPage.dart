import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/siteData.dart';

class SiteEditorPage extends StatefulWidget {
  final SiteData site;

  SiteEditorPage(this.site);

  @override
  _SiteEditorPageState createState() {
    return new _SiteEditorPageState(site);
  }
}

class _SiteEditorPageState extends State<SiteEditorPage> {
  final SiteData site;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _siteNameController = new TextEditingController();

  _SiteEditorPageState(this.site);

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      //_autovalidate = true; // Start validating on every change.
      //showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      //showInSnackBar('snackchat');
      //User.instance.first_name = firstName;
      //User.instance.last_name = lastName;

      //User.instance.save().then((result) {
      //  print("Saving done: ${result}.");
      //});
    }
  }

  @override
  void initState() {
    _siteNameController.text = site.siteName;
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final DateTime today = new DateTime.now();

    return new Scaffold(
        appBar: new AppBar(title: const Text('Edit Site'), actions: <Widget>[
          new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 10.0),
              child: new MaterialButton(
                color: themeData.primaryColor,
                textColor: themeData.secondaryHeaderColor,
                child: new Text('Save'),
                onPressed: () {
                  _handleSubmitted();
                  //Navigator.pop(context);
                },
              ))
        ]),
        body: new Form(
            key: _formKey,
            autovalidate: false,
            //onWillPop: _warnUserAboutInvalidData,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Site Name", hintText: "Site name?"),
                    autocorrect: false,
                    controller: _siteNameController,
                    onChanged: (String value) {
                      _siteNameController.text = value;
                    },
                  ),
                ),
              ],
            )));
  }

}