import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'auth_token';

  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(
    this.prefs, {
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  bool get _isTest => const bool.fromEnvironment('FLUTTER_TEST');
  bool get _usePrefs => _isTest || kIsWeb;

  @override
  Future<void> cacheToken(String token) async {
    if (_usePrefs) {
      await prefs.setString(_tokenKey, token);
      return;
    }
    await secureStorage.write(key: _tokenKey, value: token);
    await prefs.remove(_tokenKey);
  }

  @override
  Future<String?> getToken() async {
    if (_usePrefs) {
      return prefs.getString(_tokenKey);
    }
    final secure = await secureStorage.read(key: _tokenKey);
    if (secure != null && secure.isNotEmpty) {
      return secure;
    }
    final legacy = prefs.getString(_tokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await secureStorage.write(key: _tokenKey, value: legacy);
      await prefs.remove(_tokenKey);
      return legacy;
    }
    return null;
  }

  @override
  Future<void> clearToken() async {
    if (_usePrefs) {
      await prefs.remove(_tokenKey);
      return;
    }
    await secureStorage.delete(key: _tokenKey);
    await prefs.remove(_tokenKey);
  }
}
