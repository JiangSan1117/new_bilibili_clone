// lib/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'interaction_buttons.dart';
import '../models/post_model.dart';
import '../pages/post_detail_page.dart';

// ----------------------------------------------------
// 文章卡片元件
// ----------------------------------------------------
class PostCard extends StatefulWidget {
  final String postId;
  final String title;
  final String username;
  final String category;
  final String postImageUrl;
  final String? notificationText;
  final int likes;
  final int views;
  final String city;
  final bool isDense; // 【NEW】: 最小間隙控制
  final String userId; // 當前用戶ID
  final Post? post; // 完整的Post對象，用於跳轉到詳細頁面

  const PostCard({
    super.key,
    required this.postId,
    required this.title,
    required this.username,
    required this.category,
    required this.postImageUrl,
    this.notificationText,
    required this.likes,
    required this.views,
    required this.city,
    this.isDense = false, // 預設為 false
    required this.userId,
    this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  String _getAbbreviatedCity(String fullCityName) {
    return fullCityName.replaceAll('縣', '').replaceAll('市', '');
  }

  @override
  Widget build(BuildContext context) {
    final String abbreviatedCity = _getAbbreviatedCity(widget.city);

    // 處理通知樣式 (保持與原始碼一致的通知卡片間隙)
    if (widget.notificationText != null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        elevation: 0,
        color: Theme.of(context).cardTheme.color,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.notificationText!,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('系統通知',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '查看詳情',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 正常文章樣式
    return Card(
      // 【FIXED】: 移除水平間隙，垂直間隙最小化
      margin: EdgeInsets.only(bottom: widget.isDense ? 0.0 : 4.0),
      elevation: 0, // 移除陰影
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)), // 【FIXED】: 移除圓角
      color: Theme.of(context).cardTheme.color, // 【FIXED】: 文章背景使用主題顏色
      child: InkWell(
        onTap: () {
          if (widget.post != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(post: widget.post!),
              ),
            );
          } else {
            debugPrint('點擊文章: ${widget.title} (無Post對象)');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面圖
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(0)),
              child: Image.network(
                widget.postImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Text('圖片載入失敗'),
                ),
              ),
            ),
            // 標題與內文
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // 底部資訊欄
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  // 作者
                  Row(
                    children: [
                      const CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/50')),
                      const SizedBox(width: 8),
                      Text(
                        widget.username,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 讚
                  const Icon(FontAwesomeIcons.thumbsUp,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(widget.likes.toString()),
                  const SizedBox(width: 12),
                  // 點閱
                  const Icon(FontAwesomeIcons.eye,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(widget.views.toString()),
                  const SizedBox(width: 12),
                  // 地點
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        abbreviatedCity,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 互動按鈕區域已移除 - 只保留文章詳情頁面的點讚和分享
            
            // 增加底部分隔線，讓文章視覺上更緊湊
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }
}
