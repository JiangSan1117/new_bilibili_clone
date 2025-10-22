// lib/services/real_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class RealApiService {
  static const String baseUrl = 'https://bilibili-backend.onrender.com/api';
  static const String tokenKey = 'auth_token';
  
  // 獲取請求頭
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  // 保存令牌
  static Future<void> _saveToken(String token) async {
    print('💾 開始保存 Token: ${token.substring(0, min(20, token.length))}...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    
    // 驗證保存成功
    final savedToken = prefs.getString(tokenKey);
    if (savedToken == token) {
      print('✅ Token 保存成功！');
    } else {
      print('❌ Token 保存失敗！');
    }
  }
  
  // 清除令牌
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
  
  // 檢查令牌是否存在
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }

  // 獲取當前用戶信息
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'user': data['user'], // 後端返回 {success: true, user: {...}}
        };
      } else {
        return {
          'success': false,
          'error': '獲取用戶信息失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 用戶註冊
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nickname,
    required String realName,
    required String idCardNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
          'nickname': nickname,
          'realName': realName,
          'idCardNumber': idCardNumber,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // 保存令牌
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? '註冊成功',
        };
      } else {
        print('❌ 註冊失敗: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error': data['error'] ?? '註冊失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      print('❌ 註冊API錯誤: $e');
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 用戶登入
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔍 嘗試登入: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      print('📡 登入響應狀態: ${response.statusCode}');
      print('📡 登入響應內容: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // 保存令牌
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? '登入成功',
        };
      } else {
        print('❌ 登入失敗: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error': data['error'] ?? '登入失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      print('❌ 登入API錯誤: $e');
      print('❌ 錯誤類型: ${e.runtimeType}');
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 用戶登出
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
      
      // 清除本地令牌
      await _clearToken();
      
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? '登出成功',
      };
    } catch (e) {
      // 即使請求失敗，也清除本地令牌
      await _clearToken();
      return {
        'success': false,
        'error': '登出失敗: $e',
      };
    }
  }
  
  // 獲取用戶資料
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取用戶資料失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 獲取文章列表
  static Future<Map<String, dynamic>> getPosts({
    String? mainTab,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '$baseUrl/posts?page=$page&limit=$limit';
      if (mainTab != null) url += '&mainTab=$mainTab';
      if (category != null) url += '&category=$category';
      
      print('📡 RealApiService: 請求文章列表 URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('📡 RealApiService: 響應狀態碼: ${response.statusCode}');
      print('📡 RealApiService: 響應內容: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'posts': data['posts'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取文章列表失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  
  // 發布文章
  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    required String category,
    required String mainTab,
    required String type,
    required String city,
    List<String>? tags,
    List<String>? images,
    List<String>? videos,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: await _getHeaders(),
        body: json.encode({
          'title': title,
          'content': content,
          'category': category,
          'mainTab': mainTab,
          'type': type,
          'city': city,
          'tags': tags ?? [],
          'images': images ?? [],
          'videos': videos ?? [],
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? '發布成功',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '發布失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 點讚文章
  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/posts/$postId/like'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '操作失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 關注用戶
  static Future<Map<String, dynamic>> toggleFollow(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/users/$userId/follow'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '操作失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 評論文章
  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/posts/$postId/comment'),
        headers: await _getHeaders(),
        body: json.encode({
          'content': content,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? '評論成功',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '評論失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 獲取文章評論
  static Future<Map<String, dynamic>> getComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/interactions/posts/$postId/comments'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取評論失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 獲取訊息列表
  static Future<Map<String, dynamic>> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取訊息失敗',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }
  
  // 健康檢查
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/health'),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': '服務器健康檢查失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '無法連接到後端服務器: $e',
      };
    }
  }

  // 互動功能API
  
  // 點讚/取消點讚文章
  static Future<Map<String, dynamic>> toggleLikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/posts/$postId/like'),
        headers: await _getHeaders(),
        body: json.encode({
          'postId': postId,
          'userId': userId,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'isLiked': data['isLiked'] ?? false,
          'likes': data['likeCount'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '操作失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 評論文章
  static Future<Map<String, dynamic>> commentPost({
    required String postId,
    required String userId,
    required String username,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/posts/$postId/comment'),
        headers: await _getHeaders(),
        body: json.encode({
          'postId': postId,
          'userId': userId,
          'username': username,
          'content': content,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'comment': data['comment'],
          'commentCount': data['commentCount'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '評論失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 獲取文章評論
  static Future<Map<String, dynamic>> getPostComments({
    required String postId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/interactions/posts/$postId/comments'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'comments': data['comments'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取評論失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }


  // 訊息系統API
  




  // 獲取用戶通知
  static Future<Map<String, dynamic>> getNotifications({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?userId=$userId'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'notifications': data['notifications'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取通知失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 標記通知為已讀
  static Future<Map<String, dynamic>> markNotificationAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _getHeaders(),
        body: json.encode({
          'userId': userId,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '標記通知失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 用戶關注和好友API
  
  // 關注/取消關注用戶
  static Future<Map<String, dynamic>> followUser({
    required String targetUserId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$targetUserId/follow'),
        headers: await _getHeaders(),
        body: json.encode({
          'targetUserId': targetUserId,
          'userId': userId,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'isFollowing': data['isFollowing'] ?? false,
          'followingCount': data['followingCount'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '操作失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 獲取用戶關注列表
  static Future<Map<String, dynamic>> getUserFollowing({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/following'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'users': data['users'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取關注列表失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 獲取用戶粉絲列表
  static Future<Map<String, dynamic>> getUserFollowers({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/followers'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'users': data['users'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取粉絲列表失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 獲取用戶公開資料
  static Future<Map<String, dynamic>> getUserProfile({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: await _getHeaders(),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? '獲取用戶資料失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '網絡連接失敗: $e',
      };
    }
  }

  // 分享文章
  static Future<Map<String, dynamic>> sharePost({
    required String postId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/posts/$postId/share'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 關注/取消關注用戶
  static Future<Map<String, dynamic>> toggleFollowUser({
    required String targetUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interactions/users/$targetUserId/follow'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 檢查關注狀態
  static Future<Map<String, dynamic>> checkFollowStatus({
    required String targetUserId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$targetUserId/follow-status'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== 訊息系統 API =====

  // 獲取對話列表
  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 創建新對話
  static Future<Map<String, dynamic>> createConversation({
    required String participantId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: await _getHeaders(),
        body: json.encode({
          'participantId': participantId,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 獲取對話訊息
  static Future<Map<String, dynamic>> getConversationMessages({
    required String conversationId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations/$conversationId/messages'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 發送訊息
  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/conversations/$conversationId/messages'),
        headers: await _getHeaders(),
        body: json.encode({
          'content': content,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== 搜索系統 API =====

  // 搜索文章
  static Future<Map<String, dynamic>> searchPosts({
    required String query,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/search/posts').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
          if (category != null && category != 'all') 'category': category,
        },
      );

      final response = await http.get(uri, headers: await _getHeaders());

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 搜索用戶
  static Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/search/users').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: await _getHeaders());

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 獲取熱門搜索關鍵字
  static Future<Map<String, dynamic>> getTrendingKeywords() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/trending'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 獲取搜索建議
  static Future<Map<String, dynamic>> getSearchSuggestions({
    required String query,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/search/suggestions').replace(
        queryParameters: {'q': query},
      );

      final response = await http.get(uri, headers: await _getHeaders());

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        ...data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
