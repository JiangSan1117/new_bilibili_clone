import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/real_api_service.dart';
import '../widgets/post_card.dart';

class UserCollectionsPage extends StatefulWidget {
  final String userId;
  final String? nickname;

  const UserCollectionsPage({
    super.key,
    required this.userId,
    this.nickname,
  });

  @override
  State<UserCollectionsPage> createState() => _UserCollectionsPageState();
}

class _UserCollectionsPageState extends State<UserCollectionsPage> {
  List<Map<String, dynamic>> _collections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserCollections();
  }

  Future<void> _loadUserCollections() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 獲取所有文章，然後篩選出該用戶收藏的文章
      final result = await RealApiService.getPosts(page: 1, limit: 100);
      
      if (result['success'] == true) {
        final allPosts = List<Map<String, dynamic>>.from(result['posts'] ?? []);
        // 模擬收藏功能：隨機選擇一些文章作為收藏
        final collectedPosts = allPosts.take(3).toList();
        
        setState(() {
          _collections = collectedPosts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? '獲取收藏失敗';
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

  Widget _buildCollectionsList() {
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
              onPressed: _loadUserCollections,
              child: const Text('重新加載'),
            ),
          ],
        ),
      );
    }

    if (_collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '還沒有收藏任何文章',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUserId = authProvider.currentUser?['id'] ?? 'current_user';
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _collections.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = _collections[index];
            // 優先使用 _id，然後 id
            final postId = post['_id'] ?? post['id'] ?? '';
            return PostCard(
              postId: postId,
              title: post['title'] ?? '',
              username: post['author'] ?? '',
              category: post['category'] ?? '',
              postImageUrl: post['imageUrl'] ?? 'https://via.placeholder.com/400x200',
              likes: post['likes'] ?? 0,
              views: post['views'] ?? 0,
              city: post['city'] ?? '',
              userId: currentUserId,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nickname ?? '用戶'}的收藏'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.grey.shade300,
      ),
      body: _buildCollectionsList(),
    );
  }
}
