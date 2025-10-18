// lib/services/offline_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'network_service.dart';

// 離線數據模型
class OfflineData {
  final String type;
  final String id;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isDirty; // 是否有未同步的更改

  OfflineData({
    required this.type,
    required this.id,
    required this.data,
    DateTime? timestamp,
    this.isDirty = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory OfflineData.fromMap(Map<String, dynamic> map) {
    return OfflineData(
      type: map['type'] ?? '',
      id: map['id'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isDirty: map['isDirty'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'id': id,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isDirty': isDirty,
    };
  }
}

// 同步操作模型
class SyncOperation {
  final String id;
  final String type;
  final String operation; // create, update, delete
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int attempts;

  SyncOperation({
    required this.id,
    required this.type,
    required this.operation,
    required this.data,
    DateTime? timestamp,
    this.attempts = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      operation: map['operation'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      attempts: map['attempts'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'attempts': attempts,
    };
  }
}

class OfflineService {
  static const String _offlineDataKey = 'offline_data';
  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncKey = 'last_sync';
  
  // 離線數據類型
  static const String typePosts = 'posts';
  static const String typeComments = 'comments';
  static const String typeInteractions = 'interactions';
  static const String typeUserData = 'user_data';
  static const String typeNotifications = 'notifications';

  // 同步操作類型
  static const String syncCreate = 'create';
  static const String syncUpdate = 'update';
  static const String syncDelete = 'delete';

  // 檢查是否處於離線模式
  static Future<bool> isOfflineMode() async {
    final isConnected = await NetworkService.isConnected();
    return !isConnected;
  }

  // 保存離線數據
  static Future<void> saveOfflineData({
    required String type,
    required String id,
    required Map<String, dynamic> data,
    bool isDirty = false,
  }) async {
    try {
      final offlineData = OfflineData(
        type: type,
        id: id,
        data: data,
        isDirty: isDirty,
      );

      final prefs = await SharedPreferences.getInstance();
      final offlineDataJson = prefs.getString(_offlineDataKey);
      
      Map<String, dynamic> offlineDataMap = {};
      if (offlineDataJson != null) {
        offlineDataMap = jsonDecode(offlineDataJson);
      }

      if (!offlineDataMap.containsKey(type)) {
        offlineDataMap[type] = {};
      }

      offlineDataMap[type][id] = offlineData.toMap();
      
      await prefs.setString(_offlineDataKey, jsonEncode(offlineDataMap));
      
      if (kDebugMode) {
        debugPrint('保存離線數據: $type/$id');
      }
    } catch (e) {
      debugPrint('保存離線數據失敗: $e');
    }
  }

  // 獲取離線數據
  static Future<Map<String, dynamic>?> getOfflineData({
    required String type,
    required String id,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineDataJson = prefs.getString(_offlineDataKey);
      
      if (offlineDataJson != null) {
        final Map<String, dynamic> offlineDataMap = jsonDecode(offlineDataJson);
        
        if (offlineDataMap.containsKey(type) && 
            offlineDataMap[type].containsKey(id)) {
          final offlineData = OfflineData.fromMap(offlineDataMap[type][id]);
          return offlineData.data;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('獲取離線數據失敗: $e');
      return null;
    }
  }

  // 獲取所有離線數據
  static Future<List<OfflineData>> getAllOfflineData([String? type]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineDataJson = prefs.getString(_offlineDataKey);
      
      if (offlineDataJson != null) {
        final Map<String, dynamic> offlineDataMap = jsonDecode(offlineDataJson);
        final List<OfflineData> result = [];
        
        for (final typeEntry in offlineDataMap.entries) {
          if (type == null || typeEntry.key == type) {
            for (final idEntry in typeEntry.value.entries) {
              result.add(OfflineData.fromMap(idEntry.value));
            }
          }
        }
        
        return result;
      }
      
      return [];
    } catch (e) {
      debugPrint('獲取所有離線數據失敗: $e');
      return [];
    }
  }

  // 刪除離線數據
  static Future<void> deleteOfflineData({
    required String type,
    required String id,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineDataJson = prefs.getString(_offlineDataKey);
      
      if (offlineDataJson != null) {
        final Map<String, dynamic> offlineDataMap = jsonDecode(offlineDataJson);
        
        if (offlineDataMap.containsKey(type)) {
          offlineDataMap[type].remove(id);
          
          // 如果該類型沒有數據了，刪除整個類型
          if (offlineDataMap[type].isEmpty) {
            offlineDataMap.remove(type);
          }
          
          await prefs.setString(_offlineDataKey, jsonEncode(offlineDataMap));
        }
      }
    } catch (e) {
      debugPrint('刪除離線數據失敗: $e');
    }
  }

  // 添加同步操作到隊列
  static Future<void> addSyncOperation({
    required String type,
    required String id,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      final syncOp = SyncOperation(
        id: '${type}_${id}_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        operation: operation,
        data: data,
      );

      final prefs = await SharedPreferences.getInstance();
      final syncQueueJson = prefs.getString(_syncQueueKey);
      
      List<Map<String, dynamic>> syncQueue = [];
      if (syncQueueJson != null) {
        final List<dynamic> syncQueueList = jsonDecode(syncQueueJson);
        syncQueue = syncQueueList.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      syncQueue.add(syncOp.toMap());
      
      await prefs.setString(_syncQueueKey, jsonEncode(syncQueue));
      
      if (kDebugMode) {
        debugPrint('添加同步操作: $operation $type/$id');
      }
    } catch (e) {
      debugPrint('添加同步操作失敗: $e');
    }
  }

  // 獲取同步隊列
  static Future<List<SyncOperation>> getSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncQueueJson = prefs.getString(_syncQueueKey);
      
      if (syncQueueJson != null) {
        final List<dynamic> syncQueueList = jsonDecode(syncQueueJson);
        return syncQueueList.map((item) => SyncOperation.fromMap(item)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('獲取同步隊列失敗: $e');
      return [];
    }
  }

  // 移除同步操作
  static Future<void> removeSyncOperation(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncQueueJson = prefs.getString(_syncQueueKey);
      
      if (syncQueueJson != null) {
        final List<dynamic> syncQueueList = jsonDecode(syncQueueJson);
        syncQueueList.removeWhere((item) => item['id'] == operationId);
        
        await prefs.setString(_syncQueueKey, jsonEncode(syncQueueList));
      }
    } catch (e) {
      debugPrint('移除同步操作失敗: $e');
    }
  }

  // 執行同步
  static Future<void> performSync() async {
    final isConnected = await NetworkService.isConnected();
    if (!isConnected) {
      debugPrint('網絡未連接，跳過同步');
      return;
    }

    try {
      final syncQueue = await getSyncQueue();
      
      for (final operation in syncQueue) {
        try {
          await _executeSyncOperation(operation);
          await removeSyncOperation(operation.id);
        } catch (e) {
          debugPrint('同步操作失敗: ${operation.id} - $e');
          // 增加重試次數，如果超過最大次數則移除
          if (operation.attempts >= 3) {
            await removeSyncOperation(operation.id);
          }
        }
      }
      
      // 更新最後同步時間
      await _updateLastSyncTime();
      
      if (kDebugMode) {
        debugPrint('同步完成，處理了 ${syncQueue.length} 個操作');
      }
    } catch (e) {
      debugPrint('執行同步失敗: $e');
    }
  }

  // 執行單個同步操作
  static Future<void> _executeSyncOperation(SyncOperation operation) async {
    // 這裡應該根據實際的API調用來實現同步邏輯
    // 例如：
    switch (operation.type) {
      case typePosts:
        await _syncPostOperation(operation);
        break;
      case typeComments:
        await _syncCommentOperation(operation);
        break;
      case typeInteractions:
        await _syncInteractionOperation(operation);
        break;
      default:
        debugPrint('未知的同步類型: ${operation.type}');
    }
  }

  // 同步文章操作
  static Future<void> _syncPostOperation(SyncOperation operation) async {
    // 實現文章同步邏輯
    debugPrint('同步文章操作: ${operation.operation}');
  }

  // 同步評論操作
  static Future<void> _syncCommentOperation(SyncOperation operation) async {
    // 實現評論同步邏輯
    debugPrint('同步評論操作: ${operation.operation}');
  }

  // 同步互動操作
  static Future<void> _syncInteractionOperation(SyncOperation operation) async {
    // 實現互動同步邏輯
    debugPrint('同步互動操作: ${operation.operation}');
  }

  // 更新最後同步時間
  static Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('更新最後同步時間失敗: $e');
    }
  }

  // 獲取最後同步時間
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      
      return null;
    } catch (e) {
      debugPrint('獲取最後同步時間失敗: $e');
      return null;
    }
  }

  // 清除所有離線數據
  static Future<void> clearAllOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineDataKey);
      await prefs.remove(_syncQueueKey);
      await prefs.remove(_lastSyncKey);
      
      if (kDebugMode) {
        debugPrint('清除所有離線數據');
      }
    } catch (e) {
      debugPrint('清除離線數據失敗: $e');
    }
  }

  // 獲取離線數據統計
  static Future<Map<String, int>> getOfflineDataStats() async {
    try {
      final allOfflineData = await getAllOfflineData();
      final syncQueue = await getSyncQueue();
      
      final stats = <String, int>{};
      
      // 統計離線數據
      for (final data in allOfflineData) {
        stats[data.type] = (stats[data.type] ?? 0) + 1;
      }
      
      // 統計同步隊列
      for (final operation in syncQueue) {
        final key = '${operation.type}_pending';
        stats[key] = (stats[key] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      debugPrint('獲取離線數據統計失敗: $e');
      return {};
    }
  }
}