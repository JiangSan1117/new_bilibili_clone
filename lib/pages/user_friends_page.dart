import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/real_api_service.dart';
import '../pages/user_profile_page.dart';

class UserFriendsPage extends StatefulWidget {
  final String userId;
  final String? nickname;

  const UserFriendsPage({
    super.key,
    required this.userId,
    this.nickname,
  });

  @override
  State<UserFriendsPage> createState() => _UserFriendsPageState();
}

class _UserFriendsPageState extends State<UserFriendsPage> {
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserFriends();
  }

  Future<void> _loadUserFriends() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 獲取用戶的關注列表作為好友列表
      final result = await RealApiService.getUserFollowing(userId: widget.userId);
      
      if (result['success'] == true) {
        final following = List<Map<String, dynamic>>.from(result['users'] ?? []);
        setState(() {
          _friends = following;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? '獲取好友列表失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '網絡連接失敗: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildFriendsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
              onPressed: _loadUserFriends,
              child: const Text('重新加載'),
            ),
          ],
        ),
      );
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '還沒有任何好友',
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
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                friend['avatar'] ?? 'https://via.placeholder.com/150',
              ),
            ),
            title: Text(
              friend['nickname'] ?? '未知用戶',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Lv.${friend['levelNum'] ?? 1}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userId: friend['id'] ?? '',
                    nickname: friend['nickname'],
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nickname ?? '用戶'}的好友'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.grey.shade300,
      ),
      body: _buildFriendsList(),
    );
  }
}
