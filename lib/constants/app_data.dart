// lib/constants/app_data.dart

import 'package:flutter/material.dart';

// --- 全局常量 ---

// 應用程式的主要 Tab 標題
const List<String> kMainTabs = ['共享', '共同', '熱門', '分享', '交換'];

// 首頁內容的次級分類 Tab 標題
const List<String> kCategoryTabs = ['全部', '飲食', '穿著', '居住', '交通', '教育', '娛樂'];

// 訊息頁面的互動 Tab 標題
const List<String> kMessageInteractionTabs = ['回覆我的', '@我', '收到的讚', '系統通知'];

// --- 模擬數據 ---

// 模擬文章數據
final List<Map<String, dynamic>> kMockPosts = [
  {
    'title': '今天在市集找到的古董相機！',
    'username': '小貓愛分享',
    'category': '電子產品',
    'mainTab': '交換',
    'likes': 480,
    'views': 12500,
    'city': '臺北市',
    'type': '二手'
  },
  {
    'title': '試做米其林三星甜點，結果大成功！',
    'username': '美食探險家',
    'category': '飲食',
    'mainTab': '分享',
    'likes': 120,
    'views': 3000,
    'city': '高雄市',
    'type': '美食'
  },
  {
    'title': '分享我的極簡主義穿搭心得',
    'username': '風格大師',
    'category': '穿著',
    'mainTab': '共享',
    'likes': 88,
    'views': 5500,
    'city': '臺中市',
    'type': '穿搭'
  },
  {
    'title': '交換鏡頭',
    'username': '攝影新手',
    'category': '電子產品',
    'mainTab': '交換',
    'likes': 30,
    'views': 800,
    'city': '新北市',
    'type': '交換'
  },
  {
    'title': '臺北美食地圖',
    'username': '在地嚮導',
    'category': '飲食',
    'mainTab': '共同',
    'likes': 250,
    'views': 15000,
    'city': '臺北市',
    'type': '地圖'
  },
  {
    'title': '最新AI繪圖技術分享',
    'username': '科技怪咖',
    'category': '教育',
    'mainTab': '分享',
    'likes': 600,
    'views': 20000,
    'city': '新北市',
    'type': '知識'
  },
  {
    'title': '三天兩夜環島路線規劃',
    'username': '旅遊達人',
    'category': '交通',
    'mainTab': '共享',
    'likes': 350,
    'views': 18000,
    'city': '臺南市',
    'type': '路線'
  },
  {
    'title': '手工皮夾製作教學',
    'username': '手作職人',
    'category': '教育',
    'mainTab': '共同',
    'likes': 150,
    'views': 7000,
    'city': '臺中市',
    'type': '教學'
  },
  {
    'title': '新竹租屋心得與避雷指南',
    'username': '租屋小幫手',
    'category': '居住',
    'mainTab': '分享',
    'likes': 200,
    'views': 11000,
    'city': '新竹市',
    'type': '指南'
  },
];

// 模擬關注者數據 (用於關注頁面)
final List<Map<String, String>> kMockFollowers = [
  {'name': '攝影大叔', 'avatarUrl': 'https://picsum.photos/seed/100/100'},
  {'name': '貓咪日常', 'avatarUrl': 'https://picsum.photos/seed/101/100'},
  {'name': '旅行日記', 'avatarUrl': 'https://picsum.photos/seed/102/100'},
  {'name': '美食家', 'avatarUrl': 'https://picsum.photos/seed/103/100'},
  {'name': '戶外狂人', 'avatarUrl': 'https://picsum.photos/seed/104/100'},
  {'name': '工程師日常', 'avatarUrl': 'https://picsum.photos/seed/105/100'},
  {'name': '設計師小李', 'avatarUrl': 'https://picsum.photos/seed/106/100'},
];

// 模擬訊息數據 (用於訊息頁面)
final List<Map<String, dynamic>> kMockMessages = [
  {
    'sender': '小貓愛分享',
    'message': '謝謝你分享的古董相機資訊，超讚的！',
    'time': '1分鐘前',
    'isUnread': true,
    'unreadCount': 2
  },
  {
    'sender': '攝影新手',
    'message': '我想交換你的鏡頭，請問型號是？',
    'time': '5分鐘前',
    'isUnread': true,
    'unreadCount': 1
  },
  {
    'sender': '系統通知',
    'message': '您發布的文章「極簡主義穿搭」已獲得 100 讚。',
    'time': '1小時前',
    'isUnread': false,
    'unreadCount': 0
  },
  {
    'sender': '美食探險家',
    'message': '你的甜點看起來超好吃，下次一起試做！',
    'time': '昨天',
    'isUnread': false,
    'unreadCount': 0
  },
  {
    'sender': '風格大師',
    'message': '極簡主義穿搭的配色技巧可以再多分享一點嗎？',
    'time': '2天前',
    'isUnread': true,
    'unreadCount': 3
  },
];
// lib/constants/app_data.dart (文件底部新增)

// 模擬用戶數據 (用於我的頁面)
final Map<String, dynamic> kMockUserData = {
  'nickname': '想享小編',
  'id': 'ID: 12345678',
  'avatarUrl': 'https://picsum.photos/seed/user/100',
  'level_num': 5,
  'level_color': '#FF8A00', // 橙色
  'posts': 88,
  'followers': 1.2, // 1.2k
  'friends': 45,
};

// 輔助頁面：必須在 MyPage.dart 中定義（或被引入）
// 這裡僅作為佔位符，確保 MyPage.dart 中的引用不會報錯
// 如果 MyPage.dart 中有用到這些 Page，您需要在 Pages 資料夾中創建它們的骨架
class MyFavoritePage extends StatelessWidget {
  const MyFavoritePage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('我的收藏頁面'));
}

class MyFollowsPage extends StatelessWidget {
  const MyFollowsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('我的關注頁面'));
}

class MyFriendsPage extends StatelessWidget {
  const MyFriendsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('我的好友頁面'));
}

class MyTransactionPage extends StatelessWidget {
  const MyTransactionPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('我的交易頁面'));
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('關於想享頁面'));
}

class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('贊助專區頁面'));
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('設定頁面'));
}
