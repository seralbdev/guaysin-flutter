import 'dart:async';

import 'package:guaysin/services/siteData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'preferences.dart';
import 'localStorage.dart';
import 'cryptoServices.dart';

String _CLOUD_BACKEND_PUSH_URL = "https://guaysinbackend1.azurewebsites.net/api/PushSites?code=8wgbzg4wovpMM9iLNgH96ApcK2YRi8nKwxj6OQag5EoHW6CwUkkVoQ==";
String _CLOUD_BACKEND_PULL_URL = "https://guaysinbackend1.azurewebsites.net/api/GetSites?code=mCb9xgHzd6f8x83awc8aqbWlOi74y7Djyt2iIB/tyxReYkCaBoiy8w==";

Future<bool> exportToCloud() async {

  try{

    //Query all local sites in DB
    var allSites = await LocalStorage.get().getAllSites();

    //Get crypto service
    var crypto = getCryptoServiceInstance();

    //Create a JSON list
    var siteMapList = new List<Map<String,dynamic>>();
    for(var sd in allSites) {
      var jsonSite = await sd.toEncryptedJSON(crypto);
      siteMapList.add(jsonSite);
    };

    //Get secret bundle from crypto module
    var secret = crypto.getSecretBundle();

    //Get user token from prefs
    var utoken = await getUserToken();

    //HTTP transaction with backend
    var response = await http.post(_CLOUD_BACKEND_PUSH_URL,
        headers: {'Token':utoken,'MasterS':secret,'Content-Type':'application/json'},
        body:json.encode(siteMapList)
    );

    if(response.statusCode == 200)
      return true;
    else
      return false;

  }catch(ex){
    return false;
  }
}

Future<bool> importFromCloud() async {

  try{

    //Get user token from prefs
    var utoken = await getUserToken();

    //HTTP transaction with backend
    var response = await http.get(_CLOUD_BACKEND_PULL_URL,
      headers: {'Token':utoken,'Content-Type':'application/json'});

    if(response.statusCode != 200)
      return false;

    //Get secret bundle from response
    var secretbundle = response.headers["masters"];
    //Update local secret bundle
    var crypto = getCryptoServiceInstance();
    await crypto.setSecretBundle(secretbundle);

    //Parse response body to get sites
    List jsonSiteList = json.decode(response.body);

    var lstorage = LocalStorage.get();
    await lstorage.cleanSites();

    for(var jsonSite in jsonSiteList){
      //Save encrypted as is
      var site = await SiteData.fromMap(jsonSite);
      await lstorage.saveSite(site,false);
    };

    return true;

  }catch(ex){
    return false;
  }
}