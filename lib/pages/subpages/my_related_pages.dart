// lib/pages/subpages/my_related_pages.dart

import 'package:flutter/material.dart';

// 通用 AppBar
PreferredSizeWidget _subpageAppBar(String title) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
  );
}

// --- 我的頁面導航子頁面 ---

class FollowedArticlesPage extends StatelessWidget {
  const FollowedArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('關注的文章'),
      body: const Center(
        child: Text('此處顯示您關注的用戶發布的文章內容。'),
      ),
    );
  }
}

class MyFollowsPage extends StatelessWidget {
  const MyFollowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('我的關注者'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8, // 模擬關注用戶數量
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      'U${index + 1}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '關注用戶 ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lv.${3 + index} • ${(index + 1) * 156} 篇文章',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '最後活動：${index + 1}小時前',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('已關注', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(index + 1) * 23} 粉絲',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyFriendsPage extends StatelessWidget {
  const MyFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('我的好友'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6, // 模擬好友數量
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      'F${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '好友 ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lv.${4 + index} • 在線',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '共同好友：${(index + 1) * 3}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.message, color: Colors.blue.shade400),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(index + 1) * 45} 天',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyCollectionsPage extends StatefulWidget {
  const MyCollectionsPage({super.key});

  @override
  State<MyCollectionsPage> createState() => _MyCollectionsPageState();
}

class _MyCollectionsPageState extends State<MyCollectionsPage> {
  List<dynamic> _favoritePosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await RealApiService.getFavoritePosts();

      if (result['success'] == true) {
        setState(() {
          _favoritePosts = result['posts'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? '載入失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '載入失敗: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('我的收藏'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFavorites,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _favoritePosts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('還沒有收藏任何文章', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _favoritePosts.length,
                      itemBuilder: (context, index) {
                        final post = _favoritePosts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              // TODO: 導航到文章詳情頁
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['title'] ?? '無標題',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post['content'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.favorite, color: Colors.red.shade400, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${post['likes'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      const SizedBox(width: 16),
                                      Icon(Icons.comment, color: Colors.grey.shade400, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${post['comments'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      const SizedBox(width: 16),
                                      Icon(Icons.remove_red_eye, color: Colors.grey.shade400, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${post['views'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class MyTransactionsPage extends StatelessWidget {
  const MyTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('我的交易'),
      body: const Center(
        child: Text('此處顯示您的交易紀錄 (購買/交換)。'),
      ),
    );
  }
}

// 新增 MyPostsPage 和 MyDraftsPage 供 my_page.dart 導航使用
class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('我的發佈'),
      body: const Center(
        child: Text('此處顯示您所有已發布的文章內容。'),
      ),
    );
  }
}

class MyDraftsPage extends StatelessWidget {
  const MyDraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _subpageAppBar('我的草稿'),
      body: const Center(
        child: Text('此處顯示您所有草稿中的文章內容。'),
      ),
    );
  }
}
