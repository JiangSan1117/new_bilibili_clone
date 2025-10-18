import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/real_api_service.dart';
import 'user_posts_page.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  final String? nickname; // 可選的暱稱，用於顯示

  const OtherUserProfilePage({
    Key? key,
    required this.userId,
    this.nickname,
  }) : super(key: key);

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _following = [];
  List<Map<String, dynamic>> _followers = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    print('👤 OtherUserProfilePage: 初始化 - userId: ${widget.userId}, nickname: ${widget.nickname}');
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      print('👤 OtherUserProfilePage: 開始加載用戶資料 - userId: ${widget.userId}');
      
      // 獲取用戶基本資料
      final profileResult = await RealApiService.getUserProfile(userId: widget.userId);
      if (profileResult['success'] == true) {
        setState(() {
          _userProfile = profileResult['user'];
        });
        print('👤 OtherUserProfilePage: 用戶資料加載成功: $_userProfile');
      }

      // 獲取關注列表
      final followingResult = await RealApiService.getUserFollowing(userId: widget.userId);
      if (followingResult['success'] == true) {
        setState(() {
          _following = List<Map<String, dynamic>>.from(followingResult['users'] ?? []);
        });
        print('👤 OtherUserProfilePage: 關注列表加載成功: ${_following.length}個');
      }

      // 獲取粉絲列表
      final followersResult = await RealApiService.getUserFollowers(userId: widget.userId);
      if (followersResult['success'] == true) {
        setState(() {
          _followers = List<Map<String, dynamic>>.from(followersResult['users'] ?? []);
        });
        print('👤 OtherUserProfilePage: 粉絲列表加載成功: ${_followers.length}個');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ OtherUserProfilePage: 加載用戶資料失敗: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.nickname ?? '用戶資料'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.nickname ?? '用戶資料'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('載入失敗: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('重新載入'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.nickname ?? '用戶資料'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: Text('用戶不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile!['nickname'] ?? '用戶資料'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 可以添加更多選項
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 用戶資料頭部
          _buildProfileHeader(),
          
          const SizedBox(height: 20),
          
          // 標籤頁
          TabBar(
            controller: _tabController,
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: '關注'),
              Tab(text: '粉絲'),
            ],
          ),
          
          // 標籤內容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_following, '關注'),
                _buildUserList(_followers, '粉絲'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // 頭像和基本信息
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  _userProfile!['avatar'] ?? 'https://via.placeholder.com/150',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile!['nickname'] ?? '未知用戶',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv.${_userProfile!['levelNum'] ?? 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 統計資料
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('文章', _userProfile!['posts']?.toString() ?? '0', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPostsPage(
                      userId: widget.userId,
                      nickname: _userProfile!['nickname'],
                    ),
                  ),
                );
              }),
              _buildStatItem('關注', _userProfile!['following']?.toString() ?? '0', () {
                _tabController.animateTo(0);
              }),
              _buildStatItem('粉絲', _userProfile!['followers']?.toString() ?? '0', () {
                _tabController.animateTo(1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_tabController.index == 0) {
      // 關注列表
      return _buildUserList(_following, '關注');
    } else {
      // 粉絲列表
      return _buildUserList(_followers, '粉絲');
    }
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, String type) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == '關注' ? Icons.person_add : Icons.people,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              type == '關注' ? '還沒有關注任何人' : '還沒有粉絲',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                user['avatar'] ?? 'https://via.placeholder.com/150',
              ),
            ),
            title: Text(
              user['nickname'] ?? '未知用戶',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Lv.${user['levelNum'] ?? 1}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserProfilePage(
                    userId: user['id'] ?? '',
                    nickname: user['nickname'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
