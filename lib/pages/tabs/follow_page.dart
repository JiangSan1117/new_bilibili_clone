// lib/pages/tabs/follow_page.dart - 真實關注頁面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_data.dart';
import '../post_feed_list.dart';
import '../../widgets/sponsor_ad_widget.dart';
import '../user_profile_page.dart';
import '../../providers/auth_provider.dart';
import '../../login_page.dart';
import '../../services/real_api_service.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  List<Map<String, dynamic>> _suggestedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestedUsers();
  }

  Future<void> _loadSuggestedUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 從內存數據庫獲取建議關注的用戶
      // 這裡我們使用模擬數據，但可以改為真實API
      _suggestedUsers = [
        {
          'id': 'test_user_2',
          'nickname': '美食達人',
          'avatar': 'https://picsum.photos/seed/chef/100',
          'levelNum': 8,
          'isVerified': true,
          'posts': 156,
          'followers': 2341
        },
        {
          'id': 'test_user_3',
          'nickname': '旅遊愛好者',
          'avatar': 'https://picsum.photos/seed/travel/100',
          'levelNum': 6,
          'isVerified': false,
          'posts': 89,
          'followers': 1234
        },
        {
          'id': 'test_user_4',
          'nickname': '科技達人',
          'avatar': 'https://picsum.photos/seed/tech/100',
          'levelNum': 9,
          'isVerified': true,
          'posts': 234,
          'followers': 4567
        },
        {
          'id': 'test_user_5',
          'nickname': '手作達人',
          'avatar': 'https://picsum.photos/seed/craft/100',
          'levelNum': 7,
          'isVerified': false,
          'posts': 67,
          'followers': 890
        },
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '載入建議用戶失敗: $e';
        _isLoading = false;
      });
    }
  }

  // 將模擬用戶名稱映射到真實的測試用戶ID
  String _getRealUserId(String mockName) {
    switch (mockName) {
      case '攝影大叔':
        return 'test_user_6'; // 攝影師
      case '貓咪日常':
        return 'test_user_7'; // 健身教練
      case '旅行日記':
        return 'test_user_3'; // 旅遊愛好者
      case '美食家':
        return 'test_user_2'; // 美食達人
      case '戶外狂人':
        return 'test_user_5'; // 手作達人
      case '工程師日常':
        return 'test_user_4'; // 科技達人
      case '設計師小李':
        return 'test_user_9'; // 設計師
      default:
        return 'test_user_1'; // 默認用戶
    }
  }

  // 構造橫向關注列表
  Widget _buildHorizontalFollows(BuildContext context) {
    return Container(
      height: 100,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // 修正：kMockFollowers 數量為 11 個，ListView 需要多一個 SizedBox
        itemCount: _suggestedUsers.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(width: 16);
          }
          final user = _suggestedUsers[index - 1];
          return Padding(
            padding: EdgeInsets.only(
                right: index == _suggestedUsers.length ? 16 : 20),
            child: GestureDetector(
              onTap: () {
                print('👆 FollowPage: 點擊用戶 ${user['nickname']}');
                
                // 跳轉到該用戶的資料頁面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      userId: user['id'],
                      nickname: user['nickname'],
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(user['avatar']),
                  ),
                  const SizedBox(height: 4),
                  Text(user['nickname'], style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
              title: const Text('關注',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF2A2A2A) 
                  : Colors.white,
              elevation: 0),
          body: authProvider.isLoggedIn ? Column(
            children: [
              _buildHorizontalFollows(context),
              
              // 關注頁面頂部贊助區
              SponsorAdWidget(location: '關注頁面頂部贊助區'),
              
              // 空白區域，讓底部贊助區固定在最下面
              const Expanded(child: SizedBox()),
              
              // 關注頁面底部贊助區
              SponsorAdWidget(location: '關注頁面底部贊助區'),
            ],
          ) : Column(
            children: [
              // 未登入時的提示
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_disabled,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '請先登入',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '登入後才能查看關注列表',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // 導航到登入頁面
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('前往登入'),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 關注頁面底部贊助區
              SponsorAdWidget(location: '關注頁面底部贊助區'),
            ],
          ),
        );
      },
    );
  }
}
