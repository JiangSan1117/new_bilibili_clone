import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/mock_data.dart';
import '../../utils/app_widgets.dart';
import '../../services/data_service.dart';
import '../../services/real_api_service.dart';
import '../../models/user_model.dart';
import '../../widgets/sponsor_ad_widget.dart';
import '../../providers/auth_provider.dart';
import '../user_profile_page.dart';
import '../user_posts_page.dart';
import '../user_collections_page.dart';
import '../user_friends_page.dart';
import '../../login_page.dart';
import '../subpages/personal_settings_page.dart';
import '../subpages/about_page.dart';
import '../subpages/sponsor_zone_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  User? _currentUser;
  bool _isLoading = false;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    // 不自動加載，等待AuthProvider狀態變化
  }

  // 提供外部調用的刷新方法
  void refresh() {
    _loadUserData();
  }

  // 處理認證狀態變化
  void _handleAuthStateChange(AuthProvider authProvider) {
    if (!mounted) return;
    
    print('🏠 MyPage: 檢查狀態 - isLoggedIn: ${authProvider.isLoggedIn}, _currentUser: ${_currentUser?.nickname ?? "null"}, _isLoading: $_isLoading');
    
    if (authProvider.isLoggedIn && _currentUser == null && !_isLoading) {
      print('🏠 MyPage: 需要加載用戶資料');
      _hasLoadedOnce = true;
      _loadUserData();
    } else if (!authProvider.isLoggedIn && _currentUser != null) {
      print('🏠 MyPage: 需要清除用戶資料');
      setState(() {
        _currentUser = null;
        _isLoading = false;
        _hasLoadedOnce = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted || _isLoading) return;
    
    try {
      setState(() {
        _isLoading = true;
      });

      // 首先檢查是否有登入令牌
      final hasToken = await RealApiService.hasToken();
      
      if (hasToken) {
        // 如果有令牌，獲取用戶資料
        final result = await RealApiService.getCurrentUser();
        
        if (result['success'] == true && result['user'] != null) {
          print('🏠 MyPage: API返回用戶資料成功');
          final userData = result['user'];
          final user = User(
            id: userData['id'] ?? '',
            nickname: userData['nickname'] ?? '用戶',
            avatarUrl: userData['avatar'] ?? 'https://via.placeholder.com/150',
            levelNum: userData['levelNum'] ?? 1,
            collections: userData['collections'] is List ? (userData['collections'] as List).length : (userData['collections'] ?? 0),
            follows: userData['follows'] is List ? (userData['follows'] as List).length : (userData['follows'] ?? 0),
            friends: userData['friends'] is List ? (userData['friends'] as List).length : (userData['friends'] ?? 0),
            posts: userData['posts'] ?? 0,
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            location: userData['location'] ?? '',
            realName: userData['realName'] ?? '',
            idCardNumber: userData['idCardNumber'] ?? '',
            verificationStatus: userData['verificationStatus'] == 'verified' 
                ? VerificationStatus.verified 
                : VerificationStatus.unverified,
            membershipType: userData['membershipType'] == 'verified' 
                ? MembershipType.verified 
                : MembershipType.free,
            verificationDate: userData['verificationDate'] != null 
                ? DateTime.parse(userData['verificationDate']) 
                : null,
            verificationNotes: userData['verificationNotes'] ?? '',
          );
          
          if (mounted) {
            setState(() {
              _currentUser = user;
              _isLoading = false;
            });
            print('🏠 MyPage: 用戶資料設置完成: ${user.nickname}');
          }
        } else {
          // 令牌無效，清除用戶資料
          print('🏠 MyPage: API返回失敗或無用戶資料: ${result}');
          if (mounted) {
            setState(() {
              _currentUser = null;
              _isLoading = false;
            });
          }
        }
      } else {
        // 沒有令牌，清除用戶資料
        print('🏠 MyPage: 無登入令牌');
        if (mounted) {
          setState(() {
            _currentUser = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('🏠 MyPage: 加載用戶資料錯誤: $e');
      if (mounted) {
        setState(() {
          _currentUser = null;
          _isLoading = false;
        });
      }
    }
  }

  Color _getLevelColor(int levelNum) {
    if (levelNum <= 2) return Colors.grey.shade600;
    if (levelNum == 3) return const Color(0xFFF87171);
    if (levelNum == 4) return const Color(0xFFFBBF24);
    if (levelNum == 5) return const Color(0xFFFDE047);
    if (levelNum == 6) return const Color(0xFF4ADE80);
    if (levelNum == 7) return const Color(0xFF60A5FA);
    if (levelNum == 8) return const Color(0xFF818CF8);
    if (levelNum >= 9) return const Color(0xFFA78BFA);
    return Colors.grey.shade600;
  }

  Widget _buildTopSection(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.20,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.20,
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              '請先登入',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              '登入後即可查看個人資料',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final user = _currentUser!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(user.avatarUrl ?? 'https://via.placeholder.com/150'),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lv.${user.levelNum}',
                          style: TextStyle(
                            color: _getLevelColor(user.levelNum),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ID: ${user.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('發布', user.posts, onTap: () {
                // 跳轉到用戶發布的文章列表
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPostsPage(
                      userId: user.id,
                      nickname: user.nickname,
                    ),
                  ),
                ).then((_) {
                  // 返回時回到我的標籤頁面
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }),
              _buildStatItem('收藏', user.collections, onTap: () {
                // 跳轉到收藏列表
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserCollectionsPage(
                      userId: user.id,
                      nickname: user.nickname,
                    ),
                  ),
                ).then((_) {
                  // 返回時回到我的標籤頁面
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }),
              _buildStatItem('好友', user.friends, onTap: () {
                // 跳轉到好友列表
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserFriendsPage(
                      userId: user.id,
                      nickname: user.nickname,
                    ),
                  ),
                ).then((_) {
                  // 返回時回到我的標籤頁面
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap != null ? Colors.grey.shade50 : null,
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onTap != null ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, Widget page) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return InkWell(
          onTap: () {
            if (authProvider.isLoggedIn) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => page));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const LoginPage()));
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: EdgeInsets.zero,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildMenuItem(context, '個人設定', const PersonalSettingsPage()),
            _buildMenuItem(context, '關於想享', const AboutPage()),
            _buildMenuItem(context, '贊助專區', const SponsorZonePage()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 在Consumer中處理狀態變化
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleAuthStateChange(authProvider);
        });

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2A2A2A) 
                : Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text('我的',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          body: authProvider.isLoggedIn ? Column(
            children: [
              _buildTopSection(context),
              
              // 我的頁面頂部贊助區 - 在收藏跟基本資料中間
              SponsorAdWidget(location: '我的頁面頂部贊助區'),
              
              _buildBottomSection(context),
              
              // 我的頁面底部贊助區
              SponsorAdWidget(location: '我的頁面底部贊助區'),
            ],
          ) : _buildNotLoggedInState(context),
        );
      },
    );
  }

  Widget _buildNotLoggedInState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
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
            '登入後才能查看個人資料',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
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
    );
  }
}