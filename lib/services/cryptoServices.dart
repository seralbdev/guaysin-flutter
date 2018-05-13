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
}

abstract class CryptoServiceOperation {
  Future<String> encryptData(String data);
  Future<String> decryptData(String cryptdata);
}

abstract class CryptoService implements CryptoServiceConfiguration,CryptoServiceOperation{}


class DefaultCryptoService implements CryptoService {
  final _SALT_ID = "SALT";
  final _PWD_ID = "PWD";
  final _cryptor = new PlatformStringCryptor();
  final _sstorage = new FlutterSecureStorage();
  String _salt;
  String _key;

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
      final epwd = await _cryptor.encrypt(password,_key);   
      await _sstorage.write(key:_SALT_ID,value:_salt);
      await _sstorage.write(key:_PWD_ID,value:epwd);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> unblockSecret(String password) async {
    try{
      final _salt = await _sstorage.read(key:_SALT_ID);
      _key = await _cryptor.generateKeyFromPassword(password,_salt);
      final epwd = await _sstorage.read(key:_PWD_ID);
      final pwd = await _cryptor.decrypt(epwd,_key);
      if(pwd==password)
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