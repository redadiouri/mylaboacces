import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'token';
  static const _roleKey = 'role';

  static const _secureStorage = FlutterSecureStorage();

  /// SAVE token & role
  static Future<void> save({
    required String token,
    String? role,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (role != null) await prefs.setString(_roleKey, role);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
      if (role != null) {
        await _secureStorage.write(key: _roleKey, value: role);
      }
    }
  }

  /// READ token
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
    return _secureStorage.read(key: _tokenKey);
  }

  /// READ role
  static Future<String?> getRole() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    }
    return _secureStorage.read(key: _roleKey);
  }

  /// CLEAR everything (logout)
  static Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_roleKey);
    } else {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _roleKey);
    }
  }
}
