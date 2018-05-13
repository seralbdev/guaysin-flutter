import 'dart:async';
import 'dart:io';

import 'package:guaysin/services/cryptoServices.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:guaysin/services/siteData.dart';

class LocalStorage {
  static final LocalStorage _bookDatabase = new LocalStorage._internal();

  final String tableName = "Books";

  Database db;

  static LocalStorage get() {
    return _bookDatabase;
  }

  LocalStorage._internal();


  Future init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "guaysin.db");
    db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            "CREATE TABLE Sites ("
                "SiteId STRING PRIMARY KEY,"
                "SiteName TEXT,"
                "SiteUrl TEXT,"
                "SiteUser TEXT,"
                "SitePassword TEXT,"
                "TimeStamp INTEGER"
                ")");
      });
  }

  Future saveSite(SiteData site) async {
    int ts = new DateTime.now().millisecondsSinceEpoch;
    String sentence;
    if(site.siteId==null){
      sentence = 'INSERT INTO Sites (SiteName, SiteUrl, SiteUser, SitePassword, TimeStamp) VALUES (?,?,?,?,?);';
      site.siteId = await db.rawInsert(sentence,[site.siteName,site.siteUrl,site.siteUser,site.sitePassword,ts]);    
    }else{
      sentence = 'UPDATE Sites SET SiteName=?,SiteUrl=?,SiteUser=?,SitePassword=?,TimeStamp=? WHERE Id=?;';
       site.siteId = await db.rawUpdate(sentence,[site.siteName,site.siteUrl,site.siteUser,site.sitePassword,ts,site.siteId]); 
    }
  }

  Future deleteSite(SiteData site) async {
    String sentence = 'DELETE FROM Sites WHERE Id=?;';
    await db.rawDelete(sentence,[site.siteId]);
  }

  Future<List<SiteData>> getAllSites(CryptoServiceOperation crypto) async {
    List<Map> eml = await db.rawQuery('SELECT * FROM Sites');
    var sites = new List<SiteData>();
    for(var m in eml) {
      final site = await SiteData.fromEncryptedMap(m,crypto);
      sites.add(site);
    }
    return sites;
  }

}