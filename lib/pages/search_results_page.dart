import 'package:flutter/material.dart';
import '../services/real_api_service.dart';
import '../widgets/post_card.dart';
import '../widgets/sponsor_ad_widget.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  final String? category;

  const SearchResultsPage({
    super.key,
    required this.query,
    this.category,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  String? _error;
  int _totalResults = 0;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.query;
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 SearchResultsPage: 開始搜索 - 查詢: ${widget.query}, 分類: ${widget.category}');
      
      final result = await RealApiService.searchPosts(
        query: widget.query,
        category: widget.category,
        page: 1,
        limit: 50,
      );

      print('🔍 SearchResultsPage: 搜索結果: $result');

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(result['posts'] ?? []);
            _totalResults = result['total'] ?? 0;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['error'] ?? '搜索失敗';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('🔍 SearchResultsPage: 搜索錯誤: $e');
      if (mounted) {
        setState(() {
          _error = '搜索時發生錯誤: $e';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '搜索結果',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '關鍵字: "${widget.query}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          if (widget.category != null) ...[
            const SizedBox(height: 4),
            Text(
              '分類: ${widget.category}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '找到 $_totalResults 個結果',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '搜索中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '搜索失敗',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '未知錯誤',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('重新搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '沒有找到相關內容',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '請嘗試其他關鍵字或分類',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return PostCard(
          postId: post['id'] ?? '',
          title: post['title'] ?? '',
          username: post['author'] ?? '',
          category: post['category'] ?? '',
          postImageUrl: post['imageUrl'] ?? '',
          likes: post['likes'] ?? 0,
          views: post['views'] ?? 0,
          city: post['city'] ?? '',
          userId: 'current_user', // 當前用戶ID
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索結果'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          SponsorAdWidget(location: '搜索結果頁面贊助區'),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _searchResults.isEmpty
                        ? _buildEmptyState()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}
