// lib/services/local_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  // 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 用户相关
  static Future<void> saveUserToken(String token) async {
    await _prefs?.setString('user_token', token);
  }

  static String? getUserToken() {
    return _prefs?.getString('user_token');
  }

  static Future<void> saveUserId(String userId) async {
    await _prefs?.setString('user_id', userId);
  }

  static String? getUserId() {
    return _prefs?.getString('user_id');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString('user_data', json.encode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final data = _prefs?.getString('user_data');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  // 搜索历史
  static Future<void> saveSearchHistory(List<String> history) async {
    await _prefs?.setStringList('search_history', history);
  }

  static List<String> getSearchHistory() {
    return _prefs?.getStringList('search_history') ?? [];
  }

  // 应用设置
  static Future<void> saveThemeMode(bool isDark) async {
    await _prefs?.setBool('is_dark_mode', isDark);
  }

  static bool getThemeMode() {
    return _prefs?.getBool('is_dark_mode') ?? false;
  }

  static Future<void> saveNotificationEnabled(bool enabled) async {
    await _prefs?.setBool('notifications_enabled', enabled);
  }

  static bool getNotificationEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  // 清除所有数据
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // 清除用户相关数据（登出时使用）
  static Future<void> clearUserData() async {
    await _prefs?.remove('user_token');
    await _prefs?.remove('user_id');
    await _prefs?.remove('user_data');
  }
}
