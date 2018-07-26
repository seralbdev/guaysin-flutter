import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:guaysin/services/cryptoServices.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:guaysin/services/siteData.dart';

class LocalStorage {
  static final LocalStorage _localStorageInstance = new LocalStorage._internal();

  Database db;
  CryptoServiceOperation _crypto;

  static LocalStorage get() {
    return _localStorageInstance;
  }

  LocalStorage._internal();


  Future init(CryptoServiceOperation crypto) async {
    this._crypto = crypto;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "guaysin.db");
    db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            "CREATE TABLE Sites ("
                "SiteId INTEGER PRIMARY KEY,"
                "SiteName TEXT,"
                "SiteUrl TEXT,"
                "SiteUser TEXT,"
                "SitePassword TEXT,"
                "TimeStamp INTEGER"
                ")");
      });
  }

  Future<SiteData> saveSite(SiteData site,bool encrypt) async {
    SiteData esite;
    int ts = new DateTime.now().millisecondsSinceEpoch;
    String sentence;
    if(site.siteId==null){
      sentence = 'INSERT INTO Sites (SiteName, SiteUrl, SiteUser, SitePassword, TimeStamp) VALUES (?,?,?,?,?);';
      if(encrypt)
        esite = await site.encrypt(_crypto);
      else
        esite = site;
      esite.siteId = await db.rawInsert(sentence,[esite.siteName,esite.siteUrl,esite.siteUser,esite.sitePassword,ts]);
    }else{
      sentence = 'UPDATE Sites SET SiteName=?,SiteUrl=?,SiteUser=?,SitePassword=?,TimeStamp=? WHERE SiteId=?;';
      if(encrypt)
        esite = await site.encrypt(_crypto);
      else
        esite = site;
      esite.siteId = await db.rawUpdate(sentence,[esite.siteName,esite.siteUrl,esite.siteUser,esite.sitePassword,ts,esite.siteId]);
    }
    return esite;
  }

  Future deleteSite(SiteData site) async {
    String sentence = 'DELETE FROM Sites WHERE SiteId=?;';
    await db.rawDelete(sentence,[site.siteId]);
  }

  Future cleanSites() async {
    String sentence = 'DELETE FROM Sites';
    await db.rawDelete(sentence);
  }

  Future<List<SiteData>> getAllSites() async {
    List<Map> eml = await db.rawQuery('SELECT * FROM Sites');
    var sites = new List<SiteData>();
    for(var m in eml) {
      final site = await SiteData.fromEncryptedMap(m,_crypto);
      sites.add(site);
    }
    return sites;
  }

  Future exportDataToFile() async {

    //get plain site list
    final allSites = await getAllSites();

    var siteMapList = new List<Map<String,dynamic>>();
    for(final sd in allSites) {
      final jsonSite = await sd.toJSON();
      siteMapList.add(jsonSite);
    }

    //convert to JSON
    final jdata = json.encode(siteMapList);

    //get file handler to write
    final dir = await getExternalStorageDirectory();
    final path = dir.path;
    final fileh = await File('$path/guaysindata.txt');

    //write file
    fileh.writeAsStringSync(jdata);
  }

  Future importDataFromFile() async {

    //get file handler to read
    final dir = await getExternalStorageDirectory();
    final path = dir.path;
    final fileh = await File('$path/guaysindata.txt');

    //read file
    var jsondata = await fileh.readAsString();

    //Parse response body to get sites
    List jsonSiteList = json.decode(jsondata);

    await cleanSites();

    for(var jsonSite in jsonSiteList){
      //Save while encrypts
      var site = await SiteData.fromMap(jsonSite);
      await saveSite(site,true);
    };

  }

}