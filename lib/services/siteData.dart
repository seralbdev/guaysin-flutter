import 'dart:async';

import 'package:guaysin/services/cryptoServices.dart';

class SiteData{
  int siteId;
  String siteName;
  String siteUrl;
  String siteUser;
  String sitePassword;

  static const String SITEID='SiteId';
  static const String SITENAMEID='SiteName';
  static const String SITEURLID='SiteUrl';
  static const String SITEUSERID='SiteUser';
  static const String SITEPASSWORDID='SitePassword';

  SiteData(this.siteName,this.siteUrl,this.siteUser,this.sitePassword,[this.siteId]);

  static Future<SiteData> fromEncryptedMap(Map data,CryptoServiceOperation crypto) async {
    final name = await crypto.decryptData(data[SITENAMEID]);
    final url = await crypto.decryptData(data[SITEURLID]);
    final user = await crypto.decryptData(data[SITEUSERID]);
    final pwd = await crypto.decryptData(data[SITEPASSWORDID]);
    var id;
    if(data.containsKey(SITEID))
      id = data[SITEID];

    return new SiteData(name,url,user,pwd,id);  
  }

  Future<SiteData> encrypt(CryptoServiceOperation crypto) async {
    final name = await crypto.encryptData(siteName);
    final url = await crypto.encryptData(siteUrl);
    final user = await crypto.encryptData(siteUser);
    final pwd = await crypto.encryptData(sitePassword);
    return new SiteData(name,url,user,pwd,siteId);
  }

  Map<String,dynamic> toJSON() => {
    'SiteName': siteName,
    'SiteUrl':siteUrl,
    'SiteUser':siteUser,
    'SitePassword':sitePassword
  };

}