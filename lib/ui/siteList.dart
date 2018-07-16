import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/services/localStorage.dart';
import 'package:guaysin/services/siteData.dart';
import 'package:guaysin/ui/siteEditorPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum _PageMenuOptions { EXPORT_TO_CLOUD }

class SiteListPage extends StatefulWidget{ 
  @override
  _SiteListPageState createState() {
    return new _SiteListPageState(getCryptoServiceInstance()); 
  }
}

class _SiteListPageState extends State<SiteListPage> {

  final List<SiteData> _siteList = <SiteData>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  final _filterController = new TextEditingController();
  RegExp regexp = new RegExp("");
  CryptoServiceOperation crypto; 

  _SiteListPageState(this.crypto);

  void _onAddNewSite() async {
    var localStorage = LocalStorage.get();
    var sd = new SiteData('','','','');
    //await localStorage.saveSite(sd);
    //this.setState((){});

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SiteEditorPage(sd)),
    );
  }

  void _onTapOnSite(SiteData site){
    print(site.siteName);

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SiteEditorPage(site)),
    );

  }

  Widget _buildListItem(SiteData site){
    return new ListTile(
      title: new Text(site.siteName),
      onTap: (){ _onTapOnSite(site);}
    );
  }

  Future<Widget> _buildSiteList() async {
    var allSites = await LocalStorage.get().getAllSites();
    var items = new List<Widget>();

    allSites.forEach((sd){
      if(regexp.hasMatch(sd.siteName)){
        var lt = _buildListItem(sd);
        items.add(lt);
      }

    });

    var lv = new ListView(
      padding: const EdgeInsets.all(16.0),
      children: items,
    );

    return lv;
  }

  void onFilter(){
    regexp = new RegExp(_filterController.text);
    this.setState((){});
  }

  void exportToCloud() async {

    String CLOUD_BACKEND_PUSH_URL = "https://guaysinbackend1.azurewebsites.net/api/PushSites?code=8wgbzg4wovpMM9iLNgH96ApcK2YRi8nKwxj6OQag5EoHW6CwUkkVoQ==";

    var allSites = await LocalStorage.get().getAllSites();
    var siteMapList = new List<Map<String,dynamic>>();
    allSites.forEach((sd){
      var jsonSite = sd.toJSON();
      siteMapList.add(jsonSite);
    });

    var secret = "secret";

    var response = await http.post(CLOUD_BACKEND_PUSH_URL,
      headers: {'Token':'token1','MasterS':secret,'Content-Type':'application/json'}, 
        body:json.encode(siteMapList)
    );

    print(response.statusCode);

  }

  void popupMenuSelected(_PageMenuOptions valueSelected){
    switch(valueSelected){
      case _PageMenuOptions.EXPORT_TO_CLOUD:
        exportToCloud();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    var fb = new FutureBuilder( 
      future: _buildSiteList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data != null) {

            return new Column(
                children: <Widget>[
                  new Row(
                      children: <Widget>[
                        new RaisedButton(key:null, onPressed:onFilter,
                            color: const Color(0xFFe0e0e0),
                            child:
                            new Text(
                              "Filter",
                              style: new TextStyle(fontSize:12.0,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "Roboto"),
                            )
                        ),
                        new Flexible(
                          child:new TextField(
                            controller:_filterController,
                            style: new TextStyle(fontSize:12.0,
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w200,
                            fontFamily: "Roboto"),
                          )
                        )
                      ]
                  ),
                  new Expanded(child:
                    snapshot.data
                  )
                ]);

            //snapshot.data
        }
        return new Container();
      });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Site list'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // overflow menu
          PopupMenuButton<_PageMenuOptions>(
              onSelected: popupMenuSelected,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<_PageMenuOptions>>[
                const PopupMenuItem<_PageMenuOptions>(
                  value: _PageMenuOptions.EXPORT_TO_CLOUD,
                  child: const Text('ToCloud'),
                ),
              ]
          ),
        ]),
      body:fb,
      floatingActionButton: new FloatingActionButton(
        onPressed: _onAddNewSite,
        tooltip: 'Increment',
        child: new Icon(Icons.add)
      )
      );
  }
}