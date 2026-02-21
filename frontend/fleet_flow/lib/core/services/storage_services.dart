import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  static String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  static String? getRole() {
    return _prefs.getString(_roleKey);
  }

  static Future<void> saveRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  static Future<void> removeRole() async {
    await _prefs.remove(_roleKey);
  }
}
