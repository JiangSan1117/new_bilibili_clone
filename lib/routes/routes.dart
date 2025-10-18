// lib/routes/routes.dart

import 'package:flutter/material.dart';
import '../pages/main_page.dart';
import '../search_page.dart';
import '../pages/create_post_page_enhanced.dart';
import '../login_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String createPost = '/create-post';
  static const String login = '/login';
  static const String myPage = '/my';
  static const String basicInfo = '/basic-info';
  static const String about = '/about';
  static const String sponsor = '/sponsor';
  static const String settings = '/settings';
  static const String myPosts = '/my-posts';
  static const String myCollections = '/my-collections';
  static const String myFollows = '/my-follows';
  static const String myFriends = '/my-friends';
  static const String myTransactions = '/my-transactions';
  static const String message = '/message';
  static const String followPage = '/follow';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const MainPage(),
      search: (context) => const SearchPage(),
      createPost: (context) => const CreatePostPageEnhanced(),
      login: (context) => const LoginPage(),
      // 其他路由可以在需要时添加
    };
  }
}
