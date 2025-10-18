// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 獲取當前用戶
  static User? get currentUser => _auth.currentUser;
  
  // 檢查是否已登入
  static bool get isLoggedIn => _auth.currentUser != null;
  
  // 獲取用戶 ID
  static String? get userId => _auth.currentUser?.uid;
  
  // 獲取用戶電子郵件
  static String? get userEmail => _auth.currentUser?.email;
  
  // 獲取用戶顯示名稱
  static String? get userDisplayName => _auth.currentUser?.displayName;
  
  // 獲取用戶頭像 URL
  static String? get userPhotoURL => _auth.currentUser?.photoURL;

  // 監聽認證狀態變化
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 電子郵件登入
  static Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserSession();
      return credential;
    } catch (e) {
      throw Exception('登入失敗: ${e.toString()}');
    }
  }

  // 電子郵件註冊
  static Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserSession();
      return credential;
    } catch (e) {
      throw Exception('註冊失敗: ${e.toString()}');
    }
  }

  // Google 登入
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 這裡需要配置 Google Sign-In
      // 暫時返回錯誤，需要真實的 Google 登入配置
      throw Exception('Google 登入功能需要配置 Google Sign-In，請使用電子郵件登入');
    } catch (e) {
      throw Exception('Google 登入失敗: ${e.toString()}');
    }
  }

  // 登出
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserSession();
    } catch (e) {
      throw Exception('登出失敗: ${e.toString()}');
    }
  }

  // 重設密碼
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('重設密碼失敗: ${e.toString()}');
    }
  }

  // 更新用戶資料
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('更新用戶資料失敗: ${e.toString()}');
    }
  }

  // 刪除帳號
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        await _clearUserSession();
      }
    } catch (e) {
      throw Exception('刪除帳號失敗: ${e.toString()}');
    }
  }

  // 保存用戶會話
  static Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', _auth.currentUser?.uid ?? '');
    await prefs.setString('userEmail', _auth.currentUser?.email ?? '');
  }

  // 清除用戶會話
  static Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
  }

  // 檢查本地會話
  static Future<bool> checkLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // 獲取本地保存的用戶 ID
  static Future<String?> getLocalUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // 獲取本地保存的用戶電子郵件
  static Future<String?> getLocalUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
}
