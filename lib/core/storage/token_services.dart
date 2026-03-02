

import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';

class TokenService {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(Constants.AUTH_TOKEN);
}


  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
  }

 static Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_id");
}


}
