// lib/components/post_feed_list.dart

import 'package:flutter/material.dart';
import '../constants/mock_data.dart'; // 引入 mock 數據

class PostFeedList extends StatelessWidget {
  final bool isHotPage;
  final String? messageInteractionType;

  const PostFeedList({
    super.key,
    this.isHotPage = false,
    this.messageInteractionType,
  });

  // 構造最小間隙的文章列表項目
  Widget _buildPostItem(BuildContext context, Map<String, dynamic> post) {
    // 垂直邊距縮到最小
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Card(
        elevation: 0.5, // 輕微陰影區分文章
        margin: EdgeInsets.zero, // Card 本身無邊距
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)), // 移除圓角
        child: InkWell(
          onTap: () {
            // 模擬文章點擊跳轉
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('點擊了文章: ${post['title']}')));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題與資訊
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  post['title']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              // 額外資訊 (用戶名、分類、數據)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(post['username']!,
                        style: TextStyle(
                            color: Colors.blue.shade700, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('${post['city']} · ${post['category']}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.favorite_border,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(post['likes'].toString(),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              // 使用零間隙分隔線
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 根據 isHotPage 或 messageInteractionType 篩選文章
    final List<Map<String, dynamic>> posts = kMockPosts;

    return ListView.builder(
      padding: EdgeInsets.zero, // 【關鍵】列表容器本身無內邊距
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostItem(context, post); // 使用最小間隙文章項目
      },
    );
  }
}
