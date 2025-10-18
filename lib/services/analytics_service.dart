// lib/services/analytics_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 分析事件模型
class AnalyticsEvent {
    final String id;
    final String eventType;
    final String userId;
    final Map<String, dynamic> parameters;
    final DateTime timestamp;

    AnalyticsEvent({
      required this.id,
      required this.eventType,
      required this.userId,
      this.parameters = const {},
      DateTime? timestamp,
    }) : timestamp = timestamp ?? DateTime.now();

    factory AnalyticsEvent.fromMap(Map<String, dynamic> map) {
      return AnalyticsEvent(
        id: map['id'] ?? '',
        eventType: map['eventType'] ?? '',
        userId: map['userId'] ?? '',
        parameters: Map<String, dynamic>.from(map['parameters'] ?? {}),
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'])
            : DateTime.now(),
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'eventType': eventType,
        'userId': userId,
        'parameters': parameters,
        'timestamp': timestamp.toIso8601String(),
      };
    }
  }

// 用戶統計數據模型
class UserAnalytics {
    final String userId;
    final int totalPosts;
    final int totalLikes;
    final int totalComments;
    final int totalShares;
    final int totalFollowers;
    final int totalFollowing;
    final int totalViews;
    final Map<String, int> categoryStats;
    final DateTime lastUpdated;

    UserAnalytics({
      required this.userId,
      this.totalPosts = 0,
      this.totalLikes = 0,
      this.totalComments = 0,
      this.totalShares = 0,
      this.totalFollowers = 0,
      this.totalFollowing = 0,
      this.totalViews = 0,
      this.categoryStats = const {},
      DateTime? lastUpdated,
    }) : lastUpdated = lastUpdated ?? DateTime.now();

    factory UserAnalytics.fromMap(Map<String, dynamic> map) {
      return UserAnalytics(
        userId: map['userId'] ?? '',
        totalPosts: map['totalPosts'] ?? 0,
        totalLikes: map['totalLikes'] ?? 0,
        totalComments: map['totalComments'] ?? 0,
        totalShares: map['totalShares'] ?? 0,
        totalFollowers: map['totalFollowers'] ?? 0,
        totalFollowing: map['totalFollowing'] ?? 0,
        totalViews: map['totalViews'] ?? 0,
        categoryStats: Map<String, int>.from(map['categoryStats'] ?? {}),
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'])
            : DateTime.now(),
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'userId': userId,
        'totalPosts': totalPosts,
        'totalLikes': totalLikes,
        'totalComments': totalComments,
        'totalShares': totalShares,
        'totalFollowers': totalFollowers,
        'totalFollowing': totalFollowing,
        'totalViews': totalViews,
        'categoryStats': categoryStats,
        'lastUpdated': lastUpdated.toIso8601String(),
      };
    }

    UserAnalytics copyWith({
      String? userId,
      int? totalPosts,
      int? totalLikes,
      int? totalComments,
      int? totalShares,
      int? totalFollowers,
      int? totalFollowing,
      int? totalViews,
      Map<String, int>? categoryStats,
      DateTime? lastUpdated,
    }) {
      return UserAnalytics(
        userId: userId ?? this.userId,
        totalPosts: totalPosts ?? this.totalPosts,
        totalLikes: totalLikes ?? this.totalLikes,
        totalComments: totalComments ?? this.totalComments,
        totalShares: totalShares ?? this.totalShares,
        totalFollowers: totalFollowers ?? this.totalFollowers,
        totalFollowing: totalFollowing ?? this.totalFollowing,
        totalViews: totalViews ?? this.totalViews,
        categoryStats: categoryStats ?? this.categoryStats,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
    }
  }

class AnalyticsService {
  static const String _analyticsKey = 'user_analytics';
  static const String _eventsKey = 'analytics_events';

  // 事件類型
  static const String eventPageView = 'page_view';
  static const String eventPostView = 'post_view';
  static const String eventPostLike = 'post_like';
  static const String eventPostComment = 'post_comment';
  static const String eventPostShare = 'post_share';
  static const String eventPostCreate = 'post_create';
  static const String eventUserFollow = 'user_follow';
  static const String eventSearch = 'search';
  static const String eventLogin = 'login';
  static const String eventLogout = 'logout';

  // 記錄事件
  static Future<void> logEvent({
    required String eventType,
    required String userId,
    Map<String, dynamic> parameters = const {},
  }) async {
    try {
      final event = AnalyticsEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventType: eventType,
        userId: userId,
        parameters: parameters,
      );

      await _saveEvent(event);
      await _updateUserAnalytics(event);
      
      if (kDebugMode) {
        debugPrint('Analytics Event: $eventType - $parameters');
      }
    } catch (e) {
      debugPrint('記錄分析事件失敗: $e');
    }
  }

  // 獲取用戶統計數據
  static Future<UserAnalytics> getUserAnalytics(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = prefs.getString('${_analyticsKey}_$userId');
      
      if (analyticsJson != null) {
        final Map<String, dynamic> analyticsMap = jsonDecode(analyticsJson);
        return UserAnalytics.fromMap(analyticsMap);
      }
      
      return UserAnalytics(userId: userId);
    } catch (e) {
      debugPrint('獲取用戶統計數據失敗: $e');
      return UserAnalytics(userId: userId);
    }
  }

  // 獲取事件統計
  static Future<Map<String, int>> getEventStats(String userId, {int days = 7}) async {
    try {
      final events = await getAllEvents(userId);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final filteredEvents = events.where((event) => event.timestamp.isAfter(cutoffDate)).toList();
      
      final stats = <String, int>{};
      for (final event in filteredEvents) {
        stats[event.eventType] = (stats[event.eventType] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      debugPrint('獲取事件統計失敗: $e');
      return {};
    }
  }

  // 獲取熱門分類
  static Future<List<MapEntry<String, int>>> getTopCategories(String userId) async {
    try {
      final analytics = await getUserAnalytics(userId);
      final sortedCategories = analytics.categoryStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedCategories.take(5).toList();
    } catch (e) {
      debugPrint('獲取熱門分類失敗: $e');
      return [];
    }
  }

  // 獲取用戶活躍度
  static Future<Map<String, dynamic>> getUserActivity(String userId, {int days = 30}) async {
    try {
      final events = await getAllEvents(userId);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final recentEvents = events.where((event) => event.timestamp.isAfter(cutoffDate)).toList();
      
      // 按日期分組
      final dailyActivity = <String, int>{};
      for (final event in recentEvents) {
        final dateKey = '${event.timestamp.year}-${event.timestamp.month.toString().padLeft(2, '0')}-${event.timestamp.day.toString().padLeft(2, '0')}';
        dailyActivity[dateKey] = (dailyActivity[dateKey] ?? 0) + 1;
      }
      
      // 計算平均每日活躍度
      final totalDays = DateTime.now().difference(cutoffDate).inDays;
      final avgDailyActivity = recentEvents.length / totalDays;
      
      return {
        'totalEvents': recentEvents.length,
        'avgDailyActivity': avgDailyActivity,
        'dailyActivity': dailyActivity,
        'mostActiveDay': dailyActivity.entries.isEmpty 
            ? null 
            : dailyActivity.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      };
    } catch (e) {
      debugPrint('獲取用戶活躍度失敗: $e');
      return {};
    }
  }

  // 清空分析數據
  static Future<void> clearAnalytics(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_analyticsKey}_$userId');
      await prefs.remove('${_eventsKey}_$userId');
    } catch (e) {
      debugPrint('清空分析數據失敗: $e');
    }
  }

  // 私有方法：保存事件
  static Future<void> _saveEvent(AnalyticsEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('${_eventsKey}_${event.userId}');
      
      List<Map<String, dynamic>> events = [];
      if (eventsJson != null) {
        final List<dynamic> eventsList = jsonDecode(eventsJson);
        events = eventsList.map((eventData) => Map<String, dynamic>.from(eventData)).toList();
      }
      
      events.insert(0, event.toMap());
      
      // 限制事件數量（最多保留1000條）
      if (events.length > 1000) {
        events.removeRange(1000, events.length);
      }
      
      await prefs.setString('${_eventsKey}_${event.userId}', jsonEncode(events));
    } catch (e) {
      debugPrint('保存分析事件失敗: $e');
    }
  }

  // 私有方法：更新用戶統計數據
  static Future<void> _updateUserAnalytics(AnalyticsEvent event) async {
    try {
      final currentAnalytics = await getUserAnalytics(event.userId);
      UserAnalytics updatedAnalytics = currentAnalytics;

      switch (event.eventType) {
        case eventPostCreate:
          updatedAnalytics = currentAnalytics.copyWith(
            totalPosts: currentAnalytics.totalPosts + 1,
          );
          
          // 更新分類統計
          final category = event.parameters['category'] as String?;
          if (category != null) {
            final categoryStats = Map<String, int>.from(currentAnalytics.categoryStats);
            categoryStats[category] = (categoryStats[category] ?? 0) + 1;
            updatedAnalytics = updatedAnalytics.copyWith(categoryStats: categoryStats);
          }
          break;
          
        case eventPostLike:
          updatedAnalytics = currentAnalytics.copyWith(
            totalLikes: currentAnalytics.totalLikes + 1,
          );
          break;
          
        case eventPostComment:
          updatedAnalytics = currentAnalytics.copyWith(
            totalComments: currentAnalytics.totalComments + 1,
          );
          break;
          
        case eventPostShare:
          updatedAnalytics = currentAnalytics.copyWith(
            totalShares: currentAnalytics.totalShares + 1,
          );
          break;
          
        case eventPostView:
          updatedAnalytics = currentAnalytics.copyWith(
            totalViews: currentAnalytics.totalViews + 1,
          );
          break;
          
        case eventUserFollow:
          final isFollowing = event.parameters['isFollowing'] as bool? ?? false;
          if (isFollowing) {
            updatedAnalytics = currentAnalytics.copyWith(
              totalFollowing: currentAnalytics.totalFollowing + 1,
            );
          } else {
            updatedAnalytics = currentAnalytics.copyWith(
              totalFollowers: currentAnalytics.totalFollowers + 1,
            );
          }
          break;
      }

      await _saveUserAnalytics(updatedAnalytics);
    } catch (e) {
      debugPrint('更新用戶統計數據失敗: $e');
    }
  }

  // 私有方法：保存用戶統計數據
  static Future<void> _saveUserAnalytics(UserAnalytics analytics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_analyticsKey}_${analytics.userId}', jsonEncode(analytics.toMap()));
    } catch (e) {
      debugPrint('保存用戶統計數據失敗: $e');
    }
  }

  // 私有方法：獲取所有事件
  static Future<List<AnalyticsEvent>> getAllEvents(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('${_eventsKey}_$userId');
      
      if (eventsJson != null) {
        final List<dynamic> eventsList = jsonDecode(eventsJson);
        return eventsList.map((eventData) => AnalyticsEvent.fromMap(eventData)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('獲取分析事件失敗: $e');
      return [];
    }
  }

  // 便捷方法
  static Future<void> logPageView(String pageName, String userId) async {
    await logEvent(
      eventType: eventPageView,
      userId: userId,
      parameters: {'page': pageName},
    );
  }

  static Future<void> logPostView(String postId, String userId, String category) async {
    await logEvent(
      eventType: eventPostView,
      userId: userId,
      parameters: {'postId': postId, 'category': category},
    );
  }

  static Future<void> logPostLike(String postId, String userId, bool isLiked) async {
    await logEvent(
      eventType: eventPostLike,
      userId: userId,
      parameters: {'postId': postId, 'isLiked': isLiked},
    );
  }

  static Future<void> logPostComment(String postId, String userId) async {
    await logEvent(
      eventType: eventPostComment,
      userId: userId,
      parameters: {'postId': postId},
    );
  }

  static Future<void> logPostShare(String postId, String userId, String shareMethod) async {
    await logEvent(
      eventType: eventPostShare,
      userId: userId,
      parameters: {'postId': postId, 'shareMethod': shareMethod},
    );
  }

  static Future<void> logPostCreate(String userId, String category, String type) async {
    await logEvent(
      eventType: eventPostCreate,
      userId: userId,
      parameters: {'category': category, 'type': type},
    );
  }

  static Future<void> logUserFollow(String targetUserId, String userId, bool isFollowing) async {
    await logEvent(
      eventType: eventUserFollow,
      userId: userId,
      parameters: {'targetUserId': targetUserId, 'isFollowing': isFollowing},
    );
  }

  static Future<void> logSearch(String query, String userId, int resultCount) async {
    await logEvent(
      eventType: eventSearch,
      userId: userId,
      parameters: {'query': query, 'resultCount': resultCount},
    );
  }
}
