import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guaysin/services/cryptoServices.dart';
import 'package:guaysin/services/localStorage.dart';
import 'package:guaysin/services/siteData.dart';

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

  Future<Widget> _buildSiteList() async {
    var allSites = await LocalStorage.get().getAllSites(crypto);
    var items = new List<Widget>();

    allSites.forEach((sd){
      var lt = new ListTile(title: new Text(sd.siteName));
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
      body:fb
      );
  }

}