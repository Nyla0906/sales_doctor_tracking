import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccessToken = "access_token";
  static const _kUsername = "username";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> getToken() => _storage.read(key: _kAccessToken);

  Future<void> saveUsername(String username) =>
      _storage.write(key: _kUsername, value: username);

  Future<String?> getUsername() => _storage.read(key: _kUsername);

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kUsername);
  }
}
