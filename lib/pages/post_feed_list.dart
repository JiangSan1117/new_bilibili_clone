// lib/pages/post_feed_list.dart

import 'package:flutter/material.dart';
import '../constants/app_data.dart';
// import '../utils/app_widgets.dart'; // 移除贊助區相關導入
import '../widgets/post_card.dart'; // 引入 PostCard
import '../services/real_api_service.dart';
import '../models/post_model.dart';

// ----------------------------------------------------
// 文章列表元件 (PostFeedList) - 支援廣告插入
// ----------------------------------------------------
class PostFeedList extends StatefulWidget {
  // isHotPage: 是否為熱門頁面 (需按 views 排序)
  final bool isHotPage;
  // isFollowPage: 是否為關注頁面 (若為 true，則使用不同的文章過濾邏輯，這裡簡化為全部)
  final bool isFollowPage;
  // messageInteractionType: 是否為訊息互動頁面 (僅用於佔位符)
  final String? messageInteractionType;
  final String? mainTabTitle;
  final String? categoryTitle;

  const PostFeedList({
    super.key,
    this.isHotPage = false,
    this.isFollowPage = false,
    this.messageInteractionType,
    this.mainTabTitle,
    this.categoryTitle,
  });

  @override
  State<PostFeedList> createState() => PostFeedListState();
}

class PostFeedListState extends State<PostFeedList> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('📰 PostFeedList: 開始加載文章列表');
      final result = await RealApiService.getPosts();
      print('📰 PostFeedList: API響應: $result');
      
      if (result['success'] == true) {
        final posts = List<Map<String, dynamic>>.from(result['posts'] ?? []);
        print('📰 PostFeedList: 獲取到 ${posts.length} 篇文章');
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        print('📰 PostFeedList: API返回失敗: ${result['error']}');
        setState(() {
          _error = result['error'] ?? '載入文章失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('📰 PostFeedList: 網絡錯誤: $e');
      setState(() {
        _error = '網絡連接失敗: $e';
        _isLoading = false;
      });
    }
  }

  // 添加刷新方法供外部調用
  void refresh() {
    _loadPosts();
  }

  // 內部過濾和排序文章列表的邏輯
  List<Map<String, dynamic>> _filterPosts() {
    List<Map<String, dynamic>> filtered = List.from(_posts);

    if (widget.isHotPage) {
      // 【熱門頁面】: 按點閱率(views)降序排列
      filtered.sort((a, b) => (b['views'] ?? 0).compareTo(a['views'] ?? 0));
      return filtered;
    }

    if (widget.isFollowPage) {
      // 【關注頁面】: 這裡應實作關注者文章邏輯，為簡化，直接顯示全部
      return filtered;
    }

    // 【主標籤頁面】 (共享, 共同, 分享, 交換)
    if (widget.mainTabTitle != null) {
      filtered =
          filtered.where((post) => post['type'] == widget.mainTabTitle).toList();

      if (widget.categoryTitle != null && widget.categoryTitle != '全部') {
        filtered = filtered
            .where((post) => post['category'] == widget.categoryTitle)
            .toList();
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // 處理訊息互動頁面邏輯 (純佔位符)
    if (widget.messageInteractionType != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text('您目前沒有關於 \"${widget.messageInteractionType!}\" 的新訊息。',
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    // 顯示加載狀態
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 顯示錯誤狀態
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadPosts,
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    final filteredPosts = _filterPosts();

    if (filteredPosts.isEmpty) {
      return const Center(
        child: Text('目前沒有相關文章或符合篩選條件的文章。'),
      );
    }

    // 【FIXED】: 列表式廣告插入邏輯
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredPosts.length, // 移除贊助區，只顯示文章
      itemBuilder: (context, index) {
        final post = filteredPosts[index];

        // 創建Post對象
        final postModel = Post(
          id: post['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: post['title'] ?? '無標題',
          content: post['content'] ?? '',
          author: post['author'] ?? '匿名用戶',
          authorId: post['authorId'] ?? 'unknown',
          username: post['author'] ?? '匿名用戶',
          category: post['category'] ?? '未分類',
          mainTab: post['mainTab'] ?? '分享',
          images: List<String>.from(post['images'] ?? []),
          videos: List<String>.from(post['videos'] ?? []),
          likes: post['likes'] ?? 0,
          comments: post['comments'] ?? 0,
          views: post['views'] ?? 0,
          city: post['city'] ?? '未知地區',
          type: post['type'] ?? '分享',
          createdAt: post['createdAt'] != null 
              ? DateTime.parse(post['createdAt']) 
              : DateTime.now(),
        );

        return PostCard(
          postId: post['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: post['title'] ?? '無標題',
          username: post['author'] ?? '匿名用戶',
          category: post['category'] ?? '未分類',
          postImageUrl: (post['images'] != null && (post['images'] as List).isNotEmpty) 
              ? (post['images'] as List)[0] 
              : 'https://picsum.photos/seed/${post['title']?.hashCode ?? 0}/400/250',
          likes: post['likes'] ?? 0,
          views: post['views'] ?? 0,
          city: post['city'] ?? '未知地區',
          userId: 'current_user_id', // 這裡應該從認證服務獲取當前用戶ID
          post: postModel,
        );
      },
    );
  }
}
