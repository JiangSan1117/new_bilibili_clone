// lib/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 通知模型
class NotificationItem {
    final String id;
    final String type;
    final String title;
    final String body;
    final String? userId; // 觸發通知的用戶ID
    final String? postId; // 相關文章ID
    final DateTime createdAt;
    final bool isRead;

    NotificationItem({
      required this.id,
      required this.type,
      required this.title,
      required this.body,
      this.userId,
      this.postId,
      required this.createdAt,
      this.isRead = false,
    });

    factory NotificationItem.fromMap(Map<String, dynamic> map) {
      return NotificationItem(
        id: map['id'] ?? '',
        type: map['type'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        userId: map['userId'],
        postId: map['postId'],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
        isRead: map['isRead'] ?? false,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'userId': userId,
        'postId': postId,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };
    }

    NotificationItem copyWith({
      String? id,
      String? type,
      String? title,
      String? body,
      String? userId,
      String? postId,
      DateTime? createdAt,
      bool? isRead,
    }) {
      return NotificationItem(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        userId: userId ?? this.userId,
        postId: postId ?? this.postId,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );
    }
  }

// 通知設置
class NotificationSettings {
    final bool likesEnabled;
    final bool commentsEnabled;
    final bool followsEnabled;
    final bool sharesEnabled;
    final bool systemEnabled;
    final bool soundEnabled;
    final bool vibrationEnabled;

    NotificationSettings({
      this.likesEnabled = true,
      this.commentsEnabled = true,
      this.followsEnabled = true,
      this.sharesEnabled = true,
      this.systemEnabled = true,
      this.soundEnabled = true,
      this.vibrationEnabled = true,
    });

    factory NotificationSettings.fromMap(Map<String, dynamic> map) {
      return NotificationSettings(
        likesEnabled: map['likesEnabled'] ?? true,
        commentsEnabled: map['commentsEnabled'] ?? true,
        followsEnabled: map['followsEnabled'] ?? true,
        sharesEnabled: map['sharesEnabled'] ?? true,
        systemEnabled: map['systemEnabled'] ?? true,
        soundEnabled: map['soundEnabled'] ?? true,
        vibrationEnabled: map['vibrationEnabled'] ?? true,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'likesEnabled': likesEnabled,
        'commentsEnabled': commentsEnabled,
        'followsEnabled': followsEnabled,
        'sharesEnabled': sharesEnabled,
        'systemEnabled': systemEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
      };
    }

    NotificationSettings copyWith({
      bool? likesEnabled,
      bool? commentsEnabled,
      bool? followsEnabled,
      bool? sharesEnabled,
      bool? systemEnabled,
      bool? soundEnabled,
      bool? vibrationEnabled,
    }) {
      return NotificationSettings(
        likesEnabled: likesEnabled ?? this.likesEnabled,
        commentsEnabled: commentsEnabled ?? this.commentsEnabled,
        followsEnabled: followsEnabled ?? this.followsEnabled,
        sharesEnabled: sharesEnabled ?? this.sharesEnabled,
        systemEnabled: systemEnabled ?? this.systemEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      );
    }
  }

class NotificationService {
  static const String _notificationsKey = 'user_notifications';
  static const String _settingsKey = 'notification_settings';

  // 通知類型
  static const String typeLike = 'like';
  static const String typeComment = 'comment';
  static const String typeFollow = 'follow';
  static const String typeShare = 'share';
  static const String typeSystem = 'system';

  // 獲取所有通知
  static Future<List<NotificationItem>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        return notificationsList.map((notificationData) => 
            NotificationItem.fromMap(notificationData)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('獲取通知失敗: $e');
      return [];
    }
  }

  // 獲取未讀通知數量
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      debugPrint('獲取未讀通知數量失敗: $e');
      return 0;
    }
  }

  // 添加通知
  static Future<void> addNotification(NotificationItem notification) async {
    try {
      final notifications = await getAllNotifications();
      notifications.insert(0, notification); // 新通知插入到最前面
      
      // 限制通知數量（最多保留100條）
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }
      
      await _saveNotifications(notifications);
    } catch (e) {
      debugPrint('添加通知失敗: $e');
    }
  }

  // 標記通知為已讀
  static Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        await _saveNotifications(notifications);
      }
    } catch (e) {
      debugPrint('標記通知已讀失敗: $e');
    }
  }

  // 標記所有通知為已讀
  static Future<void> markAllAsRead() async {
    try {
      final notifications = await getAllNotifications();
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
      await _saveNotifications(notifications);
    } catch (e) {
      debugPrint('標記所有通知已讀失敗: $e');
    }
  }

  // 刪除通知
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      await _saveNotifications(notifications);
    } catch (e) {
      debugPrint('刪除通知失敗: $e');
    }
  }

  // 清空所有通知
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      debugPrint('清空通知失敗: $e');
    }
  }

  // 獲取通知設置
  static Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
        return NotificationSettings.fromMap(settingsMap);
      }
      
      return NotificationSettings(); // 返回默認設置
    } catch (e) {
      debugPrint('獲取通知設置失敗: $e');
      return NotificationSettings();
    }
  }

  // 保存通知設置
  static Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
    } catch (e) {
      debugPrint('保存通知設置失敗: $e');
    }
  }

  // 創建通知（根據類型）
  static Future<void> createNotification({
    required String type,
    required String title,
    required String body,
    String? userId,
    String? postId,
  }) async {
    try {
      // 檢查通知設置
      final settings = await getNotificationSettings();
      bool shouldCreate = false;

      switch (type) {
        case typeLike:
          shouldCreate = settings.likesEnabled;
          break;
        case typeComment:
          shouldCreate = settings.commentsEnabled;
          break;
        case typeFollow:
          shouldCreate = settings.followsEnabled;
          break;
        case typeShare:
          shouldCreate = settings.sharesEnabled;
          break;
        case typeSystem:
          shouldCreate = settings.systemEnabled;
          break;
      }

      if (shouldCreate) {
        final notification = NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          title: title,
          body: body,
          userId: userId,
          postId: postId,
          createdAt: DateTime.now(),
        );

        await addNotification(notification);
      }
    } catch (e) {
      debugPrint('創建通知失敗: $e');
    }
  }

  // 私有方法：保存通知列表
  static Future<void> _saveNotifications(List<NotificationItem> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((notification) => notification.toMap()).toList()
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('保存通知失敗: $e');
    }
  }

  // 模擬通知（用於測試）
  static Future<void> createMockNotifications() async {
    final mockNotifications = [
      NotificationItem(
        id: '1',
        type: typeLike,
        title: '收到新的讚',
        body: '小貓愛分享 讚了您的文章「今天在市集找到的古董相機！」',
        userId: 'user1',
        postId: 'post1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationItem(
        id: '2',
        type: typeComment,
        title: '新的評論',
        body: '美食探險家 評論了您的文章：太棒了！我也想去看看',
        userId: 'user2',
        postId: 'post1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: '3',
        type: typeFollow,
        title: '新的關注者',
        body: '風格大師 開始關注您',
        userId: 'user3',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '4',
        type: typeSystem,
        title: '系統通知',
        body: '歡迎使用想享！開始分享您的精彩內容吧',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    await _saveNotifications(mockNotifications);
  }
}
