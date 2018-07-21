import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'preferences.dart';
import 'localStorage.dart';
import 'cryptoServices.dart';

String _CLOUD_BACKEND_PUSH_URL = "https://guaysinbackend1.azurewebsites.net/api/PushSites?code=8wgbzg4wovpMM9iLNgH96ApcK2YRi8nKwxj6OQag5EoHW6CwUkkVoQ==";

Future<bool> exportToCloud() async {

  try{

    //Query all local sites in DB
    var allSites = await LocalStorage.get().getAllSites();
    //Create a JSON list
    var siteMapList = new List<Map<String,dynamic>>();
    allSites.forEach((sd){
      var jsonSite = sd.toJSON();
      siteMapList.add(jsonSite);
    });

    //Get secret bundle
    var crypto = getCryptoServiceInstance();
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