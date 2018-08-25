import 'dart:async';

import 'package:guaysin/services/siteData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'preferences.dart';
import 'localStorage.dart';
import 'cryptoServices.dart';

final String _CLOUD_BACKEND_PUSH_URL = "https://guaysinbackend1.azurewebsites.net/api/PushSites?code=8wgbzg4wovpMM9iLNgH96ApcK2YRi8nKwxj6OQag5EoHW6CwUkkVoQ==";
final String _CLOUD_BACKEND_PULL_URL = "https://guaysinbackend1.azurewebsites.net/api/GetSites?code=mCb9xgHzd6f8x83awc8aqbWlOi74y7Djyt2iIB/tyxReYkCaBoiy8w==";

abstract class CloudStorage{
  Future exportToCloud();
  Future importFromCloud();
}

class _CloudStorage implements CloudStorage {

  final CryptoServiceConfiguration crypto;
  final LocalStorage localStorage;
  final Preferences preferences;

  _CloudStorage(this.crypto,this.localStorage,this.preferences){
  }

  Future exportToCloud() async {
    //Query all local sites in DB
    final allSites = await localStorage.getAllSites();

    //Create a JSON list
    var siteMapList = new List<Map<String,dynamic>>();
    for(final sd in allSites) {
      final jsonSite = await sd.toEncryptedJSON(crypto as CryptoServiceOperation);
      siteMapList.add(jsonSite);
    };

    //Get secret bundle from crypto module
    final secret = crypto.getSecretBundle();

    //Get user token from prefs
    final utoken = await preferences.getUserToken();

    //HTTP transaction with backend
    var response = await http.post(_CLOUD_BACKEND_PUSH_URL,
        headers: {'Token':utoken,'MasterS':secret,'Content-Type':'application/json'},
        body:json.encode(siteMapList)
    );

    if(response.statusCode == 200)
      return true;
    else
      return false;
  }

  Future importFromCloud() async {
      //Get user token from prefs
      var utoken = await preferences.getUserToken();

      //HTTP transaction with backend
      var response = await http.get(_CLOUD_BACKEND_PULL_URL,
          headers: {'Token':utoken,'Content-Type':'application/json'});

      if(response.statusCode != 200)
        return false;

      //Get secret bundle from response
      var secretbundle = response.headers["masters"];
      //Update local secret bundle
      await crypto.setSecretBundle(secretbundle);

      //Parse response body to get sites
      List jsonSiteList = json.decode(response.body);

      await localStorage.cleanSites();

      for(var jsonSite in jsonSiteList){
        //Save encrypted as is
        var site = await SiteData.fromMap(jsonSite);
        await localStorage.saveSite(site,false);
      };
  }
}

CloudStorage _cloudStorageInstace;

CloudStorage initCloudStorage(CryptoServiceConfiguration crypto, LocalStorage localStorage,Preferences prefs){
  _cloudStorageInstace = new _CloudStorage(crypto,localStorage,prefs);
  return _cloudStorageInstace;
}

CloudStorage getCloudStorage(){
  return _cloudStorageInstace;
}