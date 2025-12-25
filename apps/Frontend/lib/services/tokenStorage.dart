import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

class TokenStorage{
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async{
    await _storage.write(key: "access_token", value: token);
  }

  Future<void> saveRefreshToken(String token) async{
    await _storage.write(key: "refresh_token", value: token);
  }

  Future<String?> getAccessToken() async
  {
    return await _storage.read(key: "access_token");
  }


  Future<String?> getRefreshToken() async
  {
    return await _storage.read(key: "refresh_token");
  }

  Future<void> clear() async
  {
    await _storage.deleteAll();
  }




}


final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});