// lib/pages/tabs/message_tabs_page.dart

import 'package:flutter/material.dart';
import '../../constants/mock_data.dart'; // 引入 kMessageInteractionTabs
import '../../utils/app_widgets.dart'; // 引入贊助區函數
import '../post_feed_list.dart'; // 引入文章列表
import '../../widgets/sponsor_ad_widget.dart';
import '../notifications_page.dart';
import '../messages_page.dart';

// ----------------------------------------------------
// 訊息列表內容元件 (MessageListContent)
// ----------------------------------------------------
class MessageListContent extends StatelessWidget {
  const MessageListContent({super.key});

  final List<Map<String, dynamic>> _mockMessages = const [
    {
      'sender': '小貓愛分享',
      'content': '你上次說的相機，我考慮交換！',
      'time': '10分鐘前',
      'isUnread': true,
      'unreadCount': 2
    },
    {
      'sender': '美食探險家',
      'content': '謝謝你的食譜，下次再試試別的。',
      'time': '1小時前',
      'isUnread': false,
      'unreadCount': 0
    },
    {
      'sender': '單車騎士',
      'content': '請問環島路線的詳細GPS數據？',
      'time': '昨天',
      'isUnread': true,
      'unreadCount': 1
    },
    {
      'sender': '系統通知',
      'content': '您的貼文已通過審核。',
      'time': '週一',
      'isUnread': false,
      'unreadCount': 0
    },
    {
      'sender': '手作達人Miya',
      'content': '皮革包教程太讚了！',
      'time': '上週',
      'isUnread': false,
      'unreadCount': 0
    },
  ];

  // 構造最小間隙的訊息項目
  Widget _buildMessageItem(BuildContext context, Map<String, dynamic> message) {
    final bool isUnread = message['isUnread'];
    final int unreadCount = message['unreadCount'];
    final String sender = message['sender'];
    return InkWell(
      onTap: () {
        debugPrint('點擊了與 $sender 的聊天');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 10.0), // 最小化垂直 padding
        color: isUnread ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardTheme.color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中對齊
          children: [
            CircleAvatar(
              radius: 20, // 略微縮小頭像
              backgroundImage: NetworkImage(
                  'https://picsum.photos/seed/${sender.hashCode}/100'),
            ),
            const SizedBox(width: 12), // 略微縮小水平間距
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sender,
                        style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16),
                      ),
                      Text(
                        message['time'],
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2), // 最小化間隙
                  Text(
                    message['content'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero, // 【關鍵】列表容器本身無內邊距
      itemCount: _mockMessages.length,
      separatorBuilder: (context, index) => const Divider(
          height: 1, thickness: 1, color: Color(0xFFF5F5F5)), // 使用極細分隔線
      itemBuilder: (context, index) {
        return _buildMessageItem(context, _mockMessages[index]);
      },
    );
  }
}

// ----------------------------------------------------
// 訊息 Tab 頁面 (MessageTabsPage)
// ----------------------------------------------------
class MessageTabsPage extends StatefulWidget {
  const MessageTabsPage({super.key});

  @override
  State<MessageTabsPage> createState() => _MessageTabsPageState();
}

class _MessageTabsPageState extends State<MessageTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: kMessageInteractionTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 全部已讀功能
  void _markAllAsRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('全部標記為已讀')),
    );
  }

  // 全部刪除功能
  void _deleteAllMessages() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('確定要刪除所有訊息嗎？此操作無法復原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有訊息已刪除')),
                );
              },
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
  }

  // 構造頂部 AppBar (包含 TabBar)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('訊息',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      centerTitle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF2A2A2A) 
          : Colors.white,
      elevation: 0,
      actions: [
        // 右上角3點按鈕
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
          onSelected: (String value) {
            if (value == 'mark_all_read') {
              _markAllAsRead();
            } else if (value == 'delete_all') {
              _deleteAllMessages();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'mark_all_read',
              child: Text('全部已讀'),
            ),
            const PopupMenuItem<String>(
              value: 'delete_all',
              child: Text('全部刪除'),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: _tabController,
            isScrollable: false, // 固定標籤，不左右移動
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8), // 減少間距
            tabs: kMessageInteractionTabs
                .map((text) => Tab(text: text))
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 贊助區
          buildFixedSponsorAd('訊息頁面', context),
          // 標籤內容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const PostFeedList(
                  messageInteractionType: '回覆我的',
                ), // 回覆我的
                const PostFeedList(
                  messageInteractionType: '@我',
                ), // @我
                const PostFeedList(
                  messageInteractionType: '收到的讚',
                ), // 收到的讚
                const NotificationsPage(), // 系統通知
              ],
            ),
          ),
          // 底部贊助區
          buildFixedSponsorAd('訊息頁面底部', context),
        ],
      ),
    );
  }
}
