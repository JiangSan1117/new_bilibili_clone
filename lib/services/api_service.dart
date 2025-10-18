// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const Duration timeout = Duration(seconds: 30);

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // 获取文章列表
  Future<List<Post>> getPosts({
    String? mainTab,
    String? category,
    bool isHot = false,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (mainTab != null) queryParams['mainTab'] = mainTab;
      if (category != null && category != '全部')
        queryParams['category'] = category;
      if (isHot) queryParams['sort'] = 'views';

      final uri =
          Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams);
      final response = await client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Post.fromMap(item)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 获取用户信息
  Future<User> getUserInfo(String userId) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/users/$userId'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromMap(data);
      } else {
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 创建新文章
  Future<Post> createPost(Post post, String token) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/posts'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(post.toMap()),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Post.fromMap(data);
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 搜索文章
  Future<List<Post>> searchPosts(String query,
      {int page = 1, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/posts/search').replace(queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Post.fromMap(item)).toList();
      } else {
        throw Exception('Failed to search posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 更新用户信息
  Future<User> updateUserInfo(User user, String token) async {
    try {
      final response = await client
          .put(
            Uri.parse('$baseUrl/users/${user.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(user.toMap()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromMap(data);
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void dispose() {
    client.close();
  }
}
