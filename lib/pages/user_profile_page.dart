import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/real_api_service.dart';
import 'user_posts_page.dart';
import 'other_user_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String? nickname; // 可選的暱稱，用於顯示

  const UserProfilePage({
    super.key,
    required this.userId,
    this.nickname,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _following = [];
  List<Map<String, dynamic>> _followers = [];
  bool _isLoading = true;
  String? _error;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('👤 UserProfilePage: 開始加載用戶資料 - userId: ${widget.userId}');
      
      // 獲取用戶基本資料
      final profileResult = await RealApiService.getUserProfile(userId: widget.userId);
      if (profileResult['success'] == true) {
        _userProfile = profileResult['user'];
        print('👤 UserProfilePage: 用戶資料加載成功: $_userProfile');
        
        // 檢查當前用戶是否已關注此用戶
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isLoggedIn && authProvider.currentUser?['id'] != widget.userId) {
          final followStatusResult = await RealApiService.checkFollowStatus(targetUserId: widget.userId);
          if (followStatusResult['success'] == true) {
            _isFollowing = followStatusResult['isFollowing'] ?? false;
          }
        }
      } else {
        setState(() {
          _error = profileResult['error'] ?? '獲取用戶資料失敗';
          _isLoading = false;
        });
        return;
      }

      // 獲取關注列表
      final followingResult = await RealApiService.getUserFollowing(userId: widget.userId);
      if (followingResult['success'] == true) {
        _following = List<Map<String, dynamic>>.from(followingResult['users'] ?? []);
        print('👤 UserProfilePage: 關注列表加載成功: ${_following.length}個');
      }

      // 獲取粉絲列表
      final followersResult = await RealApiService.getUserFollowers(userId: widget.userId);
      if (followersResult['success'] == true) {
        _followers = List<Map<String, dynamic>>.from(followersResult['users'] ?? []);
        print('👤 UserProfilePage: 粉絲列表加載成功: ${_followers.length}個');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '網絡連接失敗: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登入才能關注用戶')),
      );
      return;
    }

    try {
      final result = await RealApiService.toggleFollowUser(
        targetUserId: widget.userId,
      );

      if (result['success'] == true) {
        setState(() {
          _isFollowing = result['isFollowing'] ?? false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing ? '關注成功！' : '已取消關注'),
          ),
        );
        
        // 重新加載關注和粉絲數據
        _loadUserProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失敗: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('網絡錯誤: $e')),
      );
    }
  }

  Widget _buildProfileHeader() {
    if (_userProfile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
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
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userProfile!['nickname'] ?? '未知用戶',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_userProfile!['isVerified'] == true)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv.${_userProfile!['levelNum'] ?? 1}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 關注按鈕
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (!authProvider.isLoggedIn || 
                      authProvider.currentUser?['id'] == widget.userId) {
                    return const SizedBox.shrink();
                  }
                  
                  return ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing ? Colors.grey.shade200 : Theme.of(context).primaryColor,
                      foregroundColor: _isFollowing ? Colors.grey.shade600 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(_isFollowing ? '已關注' : '關注'),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 統計信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('文章', '${_userProfile!['posts'] ?? 0}', onTap: () {
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
              _buildStatItem('關注', '${_userProfile!['follows'] ?? 0}'),
              _buildStatItem('粉絲', '${_userProfile!['friends'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {VoidCallback? onTap}) {
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
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: onTap != null ? Theme.of(context).primaryColor : Colors.grey.shade600,
                fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFollowingPosts() {
    if (_following.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '關注者的文章',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '關注一些用戶後，這裡會顯示他們的文章',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // 顯示關注者的文章
    return FutureBuilder(
      future: _loadFollowingPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('載入失敗', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        final posts = snapshot.data as List<Map<String, dynamic>>;
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('暫無文章', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(post['authorAvatar'] ?? 'https://picsum.photos/seed/user/50'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post['author'] ?? '未知用戶',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          post['createdAt'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['content'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${post['likes'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 16),
                        Icon(Icons.comment_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${post['comments'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const Spacer(),
                        Text(
                          post['category'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadFollowingPosts() async {
    try {
      // 獲取所有關注者的文章
      List<Map<String, dynamic>> allPosts = [];
      
      for (final user in _following) {
        // 這裡可以調用API獲取特定用戶的文章
        // 暫時使用模擬數據
        allPosts.add({
          'id': 'post_${user['id']}_1',
          'title': '${user['nickname']}的文章',
          'content': '這是${user['nickname']}分享的內容...',
          'author': user['nickname'],
          'authorAvatar': user['avatar'],
          'category': '分享',
          'likes': 5,
          'comments': 2,
          'createdAt': '2025-10-17',
        });
      }
      
      return allPosts;
    } catch (e) {
      print('載入關注者文章失敗: $e');
      return [];
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
              print('👆 UserProfilePage: 點擊關注者 ${user['nickname']} (${user['id']})');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.nickname ?? '用戶資料'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.nickname ?? '用戶資料'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                '錯誤: $_error',
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('重新加載'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile?['nickname'] ?? '用戶資料'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.grey.shade300,
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: _buildFollowingPosts(),
          ),
        ],
      ),
    );
  }
}
