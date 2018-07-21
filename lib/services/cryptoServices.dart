import 'dart:async';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _cs = new DefaultCryptoService();

CryptoService getCryptoServiceInstance(){
  return _cs;
}

abstract class CryptoServiceConfiguration {
  Future<bool> secretReady();
  Future<bool> createSecret(String password);
  Future<bool> unblockSecret(String password);
  String getSecretBundle();
  void setSecretBundle(String bundle);
}

abstract class CryptoServiceOperation {
  Future<String> encryptData(String data);
  Future<String> decryptData(String cryptdata);
}

abstract class CryptoService implements CryptoServiceConfiguration,CryptoServiceOperation{}


class DefaultCryptoService implements CryptoService {
  final _SALT_ID = "SALT";
  final _SECRET_ID = "SECRET";
  final _cryptor = new PlatformStringCryptor();
  final _sstorage = new FlutterSecureStorage();
  String _key;
  String _salt;
  String _esecret;

  String getSecretBundle(){
    return _salt+"&"+_esecret;
  }

  void setSecretBundle(String bundle) async {
    var tokens = bundle.split("&");
    _salt = tokens[0];
    _esecret = tokens[1];
    await _sstorage.write(key:_SALT_ID,value:_salt);
    await _sstorage.write(key:_SECRET_ID,value:_esecret);
  }

  Future<bool> secretReady() async {
    try{
      var s = await _sstorage.read(key:_SALT_ID);
      if((s!=null) && s.isNotEmpty)
        return true;
      else return false;
    }catch(e){
      return false;
    }
  }

  Future<bool> createSecret(String password) async {
    try{
      _salt = await _cryptor.generateSalt();
      _key = await _cryptor.generateKeyFromPassword(password,_salt);
      _esecret = await _cryptor.encrypt(_salt,_key);
      await _sstorage.write(key:_SALT_ID,value:_salt);
      await _sstorage.write(key:_SECRET_ID,value:_esecret);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> unblockSecret(String password) async {
    try{
      _salt = await _sstorage.read(key:_SALT_ID);
      _key = await _cryptor.generateKeyFromPassword(password,_salt);
      _esecret = await _sstorage.read(key:_SECRET_ID);
      final secret = await _cryptor.decrypt(_esecret,_key);
      if(secret==_salt)
        return true;
      return false;
    }catch(e){
      return false;
    }
  }

  Future<String> encryptData(String data) async {
    if(_key != null && _key.isNotEmpty){
      return await _cryptor.encrypt(data,_key);
    }else{
      throw new Exception("Secret not ublocked");
    }
  }

  Future<String> decryptData(String cryptdata) async {
    if(_key != null && _key.isNotEmpty){
      return await _cryptor.decrypt(cryptdata,_key);
    }else{
      throw new Exception("Secret not ublocked");
    }
  }  

}