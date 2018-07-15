import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/localStorage.dart';
import 'package:guaysin/services/siteData.dart';

enum PageMenuOptions { DELETE }

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
  final _siteUrlController = new TextEditingController();
  final _siteUserController = new TextEditingController();
  final _sitePwdController = new TextEditingController();

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

  void _onSaveSite() async {
    var localStorage = LocalStorage.get();
    site.siteName = _siteNameController.text;
    site.siteUrl = _siteUrlController.text;
    site.siteUser = _siteUserController.text;
    site.sitePassword = _sitePwdController.text;
    await localStorage.saveSite(site);
    //this.setState((){});
    Navigator.pop(context);
  }

  void deleteSite(){
    if(site.siteId!=null){
      var localStorage = LocalStorage.get();
      localStorage.deleteSite(site);
      Navigator.pop(context);
    }
  }

  void popupMenuSelected(PageMenuOptions valueSelected){
    switch(valueSelected){
      case PageMenuOptions.DELETE:
        deleteSite();
    }
  }

  @override
  void initState() {
    if(site!=null) {
      _siteNameController.text = site.siteName;
      _siteUrlController.text = site.siteUrl;
      _siteUserController.text = site.siteUser;
      _sitePwdController.text = site.sitePassword;
    }
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final DateTime today = new DateTime.now();

    return new Scaffold(
        appBar: new AppBar(title: const Text('Edit Site'),
        actions: <Widget>[
          // overflow menu
          PopupMenuButton<PageMenuOptions>(
            onSelected: popupMenuSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PageMenuOptions>>[
              const PopupMenuItem<PageMenuOptions>(
                value: PageMenuOptions.DELETE,
                child: const Text('Delete'),
              ),
            ]
          ),
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
                    //onChanged: (String value) {
                    //  _siteNameController.text = value;
                    //},
                  ),
                ),
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Site URL", hintText: "Site url?"),
                    autocorrect: false,
                    controller: _siteUrlController,
                    //onChanged: (String value) {
                    //  _siteUrlController.text = value;
                    //},
                  ),
                ),
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Site User", hintText: "Site user?"),
                    autocorrect: false,
                    controller: _siteUserController,
                    //onChanged: (String value) {
                    //  _siteUserController.text = value;
                    //},
                  ),
                ),
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Site password", hintText: "Site password?"),
                    autocorrect: false,
                    controller: _sitePwdController,
                    //onChanged: (String value) {
                    //  _sitePwdController.text = value;
                    //},
                  ),
                ),
              ],
            )),
            floatingActionButton: new FloatingActionButton(
                onPressed: _onSaveSite,
                tooltip: 'Save changes',
                child: new Icon(Icons.save)
            ));
  }

}