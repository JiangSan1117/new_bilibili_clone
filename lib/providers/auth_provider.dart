// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../services/real_api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;

  // 初始化時檢查登入狀態
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await RealApiService.hasToken();
      if (hasToken) {
        // 如果有token，驗證token是否有效
        final result = await RealApiService.getCurrentUser();
        _isLoggedIn = result['success'] == true;
        if (_isLoggedIn) {
          _currentUser = result['user'];
        }
        print('🔑 AuthProvider: 檢查登入狀態 - hasToken: $hasToken, isLoggedIn: $_isLoggedIn');
      } else {
        _isLoggedIn = false;
        _currentUser = null;
        print('🔑 AuthProvider: 檢查登入狀態 - 無token, isLoggedIn: $_isLoggedIn');
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
      print('🔑 AuthProvider: 檢查登入狀態失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登入成功
  void loginSuccess() async {
    print('🔑 AuthProvider: 登入成功，設置 _isLoggedIn = true');
    _isLoggedIn = true;
    
    // 確保token已保存，並獲取用戶資料
    final hasToken = await RealApiService.hasToken();
    if (hasToken) {
      final result = await RealApiService.getCurrentUser();
      if (result['success'] == true) {
        _currentUser = result['user'];
      }
    }
    print('🔑 AuthProvider: 檢查token狀態: $hasToken');
    
    notifyListeners();
    print('🔑 AuthProvider: 已通知所有監聽者');
  }

  // 登出
  Future<void> logout() async {
    try {
      print('🔑 AuthProvider: 開始登出');
      await RealApiService.logout();
      _isLoggedIn = false;
      notifyListeners();
      print('🔑 AuthProvider: 登出成功，已通知所有監聽者');
    } catch (e) {
      // 即使API調用失敗，也要清除本地狀態
      print('🔑 AuthProvider: 登出API失敗，但清除本地狀態: $e');
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  // 強制刷新狀態
  void refresh() {
    checkAuthStatus();
  }
}
