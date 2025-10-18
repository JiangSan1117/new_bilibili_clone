// lib/services/network_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// 網絡狀態枚舉
enum NetworkStatus {
  connected,
  disconnected,
  unknown,
}

class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  
  // 當前網絡狀態
  static NetworkStatus _currentStatus = NetworkStatus.unknown;
  static NetworkStatus get currentStatus => _currentStatus;

  // 監聽網絡狀態變化
  static Stream<NetworkStatus> get networkStatusStream async* {
    await for (final connectivityResults in _connectivity.onConnectivityChanged) {
      final connectivityResult = connectivityResults.first;
      _currentStatus = _mapConnectivityResult(connectivityResult);
      yield _currentStatus;
    }
  }

  // 檢查網絡連接
  static Future<bool> isConnected() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final connectivityResult = connectivityResults.first;
      _currentStatus = _mapConnectivityResult(connectivityResult);
      return _currentStatus == NetworkStatus.connected;
    } catch (e) {
      debugPrint('檢查網絡連接失敗: $e');
      return false;
    }
  }

  // 測試實際網絡連接
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('測試網絡連接失敗: $e');
      return false;
    }
  }

  // 映射連接狀態
  static NetworkStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return NetworkStatus.connected;
      case ConnectivityResult.none:
        return NetworkStatus.disconnected;
      default:
        return NetworkStatus.unknown;
    }
  }

  // 獲取網絡類型
  static Future<String> getNetworkType() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final connectivityResult = connectivityResults.first;
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.none:
          return 'None';
        default:
          return 'Unknown';
      }
    } catch (e) {
      debugPrint('獲取網絡類型失敗: $e');
      return 'Unknown';
    }
  }

  // 初始化網絡監聽
  static Future<void> initialize() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final connectivityResult = connectivityResults.first;
      _currentStatus = _mapConnectivityResult(connectivityResult);
    } catch (e) {
      debugPrint('初始化網絡服務失敗: $e');
    }
  }
}
