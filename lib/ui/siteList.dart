import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/services/localStorage.dart';
import 'package:guaysin/services/siteData.dart';
import 'package:guaysin/ui/siteEditorPage.dart';

class SiteListPage extends StatefulWidget{ 
  @override
  _SiteListPageState createState() {
    return new _SiteListPageState(getCryptoServiceInstance()); 
  }
}

class _SiteListPageState extends State<SiteListPage> {

  final List<SiteData> _siteList = <SiteData>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
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
      var lt = _buildListItem(sd);
      items.add(lt);
    });

    var lv = new ListView(
      padding: const EdgeInsets.all(16.0),
      children: items,
    );

    return lv;
  }

  @override
  Widget build(BuildContext context) {
    
    var fb = new FutureBuilder( 
      future: _buildSiteList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return snapshot.data;
        }
        return new Container();
      });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Site list'),
        automaticallyImplyLeading: false
      ),
      body:fb,
      floatingActionButton: new FloatingActionButton(
        onPressed: _onAddNewSite,
        tooltip: 'Increment',
        child: new Icon(Icons.add)
      )
      );
  }
}