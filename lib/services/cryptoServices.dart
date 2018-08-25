import 'dart:async';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CryptoServiceConfiguration {
  Future<bool> secretReady();
  Future createSecret(String password);
  Future<bool> unblockSecret(String password);
  Future unblockKey();
  String getSecretBundle();
  void setSecretBundle(String bundle);
  void resetKey();
}

abstract class CryptoServiceOperation {
  Future<String> encryptData(String data);
  Future<String> decryptData(String cryptdata);
}

abstract class CryptoService implements CryptoServiceConfiguration,CryptoServiceOperation{}


class _DefaultCryptoService implements CryptoService {
  final SALT_ID = "SALT";
  final ESECRET_ID = "ESECRET";
  final KEY_ID = "KEY";
  final cryptor = new PlatformStringCryptor();
  final sstorage = new FlutterSecureStorage();
  String key;
  String salt;
  String esecret;

  Future resetKey() async {
    await sstorage.write(key: KEY_ID, value: null);
  }

  String getSecretBundle(){
    return salt+"&"+esecret;
  }

  void setSecretBundle(String bundle) async {
    var tokens = bundle.split("&");
    salt = tokens[0];
    esecret = tokens[1];
    await sstorage.write(key:SALT_ID,value:salt);
    await sstorage.write(key:ESECRET_ID,value:esecret);
  }

  Future<bool> secretReady() async {
    var s = await sstorage.read(key:SALT_ID);
    if((s!=null) && s.isNotEmpty)
      return true;
    else return false;
  }

  Future createSecret(String password) async {
    salt = await cryptor.generateSalt();
    key = await cryptor.generateKeyFromPassword(password,salt);
    esecret = await cryptor.encrypt(password,key);
    await sstorage.write(key:SALT_ID,value:salt);
    await sstorage.write(key:ESECRET_ID,value:esecret);
    await sstorage.write(key:KEY_ID,value:key);
  }

  Future<bool> unblockSecret(String password) async {
    salt = await sstorage.read(key:SALT_ID);
    key = await cryptor.generateKeyFromPassword(password,salt);
    final storedKey = await sstorage.read(key:KEY_ID);
    if(storedKey == null){
      await sstorage.write(key:KEY_ID,value:key);
    }
    esecret = await sstorage.read(key:ESECRET_ID);
    final secret = await cryptor.decrypt(esecret,key);
    if(secret==password)
      return true;
    return false;
  }

  Future unblockKey() async {
    salt = await sstorage.read(key:SALT_ID);
    esecret = await sstorage.read(key:ESECRET_ID);
    key = await sstorage.read(key:KEY_ID);
  }


  Future<String> encryptData(String data) async {
    if(key != null && key.isNotEmpty){
      return await cryptor.encrypt(data,key);
    }else{
      throw new Exception("Secret not ublocked");
    }
  }

  Future<String> decryptData(String cryptdata) async {
    if(key != null && key.isNotEmpty){
      return await cryptor.decrypt(cryptdata,key);
    }else{
      throw new Exception("Secret not ublocked");
    }
  }
}

final _cryptoServiceInstace = new _DefaultCryptoService();

CryptoService getCryptoService(){
  return _cryptoServiceInstace;
}