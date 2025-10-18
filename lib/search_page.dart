// search_page.dart

import 'package:flutter/material.dart';
import '../services/real_api_service.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';
import '../widgets/sponsor_ad_widget.dart';

// 模擬數據
const List<String> _mockHotSearches = [
  '交換鏡頭',
  '臺北美食地圖',
  '最新AI繪圖技術',
  '三天兩夜環島',
  '手工皮夾製作',
  '米其林甜點食譜',
  '健身菜單推薦',
  '二手電子產品',
  '新竹租屋心得',
  '環島旅遊路線',
];

// 移除舊的贊助區樣式，使用統一的 SponsorAdWidget

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  // 模擬搜索歷史 (最多 10 個，新舊輪替)
  List<String> _searchHistory = [
    '環島機車路線',
    '臺中美食',
    '二手相機',
    '皮夾製作',
    '健身菜單',
    'AI 教學',
    '古董相機',
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Post> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  List<String> _trendingKeywords = [];
  
  // 搜尋標籤控制器
  late TabController _searchTabController;
  final List<String> _searchTabs = ['共享', '共同', '熱門', '分享', '交換'];

  @override
  void initState() {
    super.initState();
    _searchTabController = TabController(length: _searchTabs.length, vsync: this);
    _loadTrendingKeywords();
  }

  Future<void> _loadTrendingKeywords() async {
    try {
      final result = await RealApiService.getTrendingKeywords();
      if (result['success'] == true) {
        setState(() {
          _trendingKeywords = List<String>.from(result['keywords'] ?? []);
        });
      }
    } catch (e) {
      print('加載熱門關鍵字失敗: $e');
      // 使用默認的熱門搜索
      setState(() {
        _trendingKeywords = _mockHotSearches;
      });
    }
  }

  @override
  void dispose() {
    _searchTabController.dispose();
    super.dispose();
  }

  // 1. 處理搜索並更新歷史紀錄
  Future<void> _addSearchToHistory(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    if (_searchHistory.isNotEmpty && _searchHistory.first == trimmedQuery) {
      debugPrint('執行搜索: $trimmedQuery (歷史紀錄未更新)');
      FocusScope.of(context).unfocus();
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      // 移除重複項
      _searchHistory.remove(trimmedQuery);
      // 插入到最前面
      _searchHistory.insert(0, trimmedQuery);
      // 保持最多 10 個
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    _searchController.text = trimmedQuery;
    
    // 執行實際搜索
    try {
      final result = await RealApiService.searchPosts(query: trimmedQuery);
      if (result['success'] == true) {
        final postsData = result['posts'] as List<dynamic>;
        final posts = postsData.map((postData) => Post(
          id: postData['id'] ?? '',
          title: postData['title'] ?? '',
          content: postData['content'] ?? '',
          author: postData['author'] ?? '',
          authorId: postData['authorId'] ?? '',
          username: postData['author'] ?? '',
          category: postData['category'] ?? '',
          mainTab: postData['mainTab'] ?? '',
          type: postData['type'] ?? '',
          images: List<String>.from(postData['images'] ?? []),
          videos: List<String>.from(postData['videos'] ?? []),
          likes: postData['likes'] ?? 0,
          comments: postData['comments'] ?? 0,
          views: postData['views'] ?? 0,
          city: postData['city'] ?? '',
          createdAt: postData['createdAt'] ?? '',
        )).toList();
        
        setState(() {
          _searchResults = posts;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失敗: ${result['error']}')),
        );
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失敗: ${e.toString()}')),
      );
    }
    
    debugPrint('執行搜索: $trimmedQuery');
    // 收起鍵盤
    FocusScope.of(context).unfocus();
  }

  // 2. 清除搜索歷史
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('搜索歷史已清除')),
    );
  }

  // 3. 構造頂部搜索框 (放大鏡在最左邊)
  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return AppBar(
      // 確保返回箭頭顯示
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      titleSpacing: 0,
      // 自定義返回箭頭行為，跳轉到熱門頁面
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // 返回主頁並通知切換到熱門標籤
          debugPrint('搜索頁面返回按鈕被點擊');
          Navigator.of(context).pop({'switchToHotTab': true});
        },
      ),

      title: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '搜索你感興趣的內容...',
                  // 【修正 1】: 放大鏡移到框裡面的最左邊
                  prefixIcon:
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                  // 移除 suffixIcon (原來的放大鏡)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
                onSubmitted: (query) {
                  _addSearchToHistory(query);
                },
              ),
            ),
          ),
          // 右邊的搜索按鈕 (文字)
          TextButton(
            onPressed: () {
              _addSearchToHistory(_searchController.text);
            },
            child: Text(
              '搜尋',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // 4. 構造搜索歷史列表 (新樣式：框呈現，橫向 Wrap，框縮小)
  Widget _buildSearchHistory(BuildContext context) {
    if (_searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 【修正 2】: 標題改為「搜尋歷史」
              Text(
                '搜尋歷史',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: _clearSearchHistory,
                child: const Icon(Icons.delete_outline,
                    size: 22, color: Colors.grey),
              ),
            ],
          ),
        ),
        // 歷史紀錄列表 - 使用 Wrap 呈現 (橫向框)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0, // 水平間距 (縮小)
            runSpacing: 8.0, // 垂直間距 (縮小)
            children: _searchHistory.map((query) {
              return InkWell(
                onTap: () {
                  _searchController.text = query;
                  _addSearchToHistory(query);
                },
                child: Container(
                  // 【修正 3】: 框的 Padding 縮小
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15), // 框變小，圓角也微調
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        query,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 15), // 文字維持適中
                      ),
                      const SizedBox(width: 6), // 縮小
                      // 刪除按鈕
                      InkWell(
                        onTap: () {
                          setState(() {
                            _searchHistory.remove(query);
                          });
                        },
                        child: const Icon(Icons.close,
                            color: Colors.grey, size: 16), // 縮小
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // 5. 構造搜索結果
  Widget _buildSearchResults(BuildContext context) {
    if (_isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              const Text('搜索中...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 50, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('沒有找到相關結果', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
            child: Text(
              '搜索結果 (${_searchResults.length} 個)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final post = _searchResults[index];
              return PostCard(
                postId: post.id,
                title: post.title,
                username: post.username,
                category: post.category,
                postImageUrl: 'https://picsum.photos/seed/${post.title.hashCode}/400/250',
                likes: post.likes,
                views: post.views,
                city: post.city,
                userId: 'current_user_id', // 這裡應該從認證服務獲取當前用戶ID
              );
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // 6. 構造想享熱搜列表 (兩列直立，無框，無編號)
  Widget _buildHotSearches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 15, 16, 0),
          child: Text(
            '想享熱搜',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // 使用 GridView.builder 實現兩列直立
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trendingKeywords.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 5,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 0.0,
            ),
            itemBuilder: (context, index) {
              final query = _trendingKeywords[index];
              return InkWell(
                onTap: () {
                  _searchController.text = query;
                  _addSearchToHistory(query);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 確保鍵盤彈出時，贊助區下保持底部不動
    return Scaffold(
      resizeToAvoidBottomInset: false,

      // 1. 搜索框 (頂部)
      appBar: _buildSearchAppBar(context),

      body: Column(
        children: [
          // 2. 搜索頁面頂部贊助區
          SponsorAdWidget(location: '搜索頁面頂部贊助區'),

          // 3. 搜尋標籤
          Container(
            height: 40,
            color: Colors.white,
            child: TabBar(
              controller: _searchTabController,
              isScrollable: false,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              labelPadding: EdgeInsets.zero,
              tabs: _searchTabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          const Divider(height: 0, thickness: 0.5, color: Color(0xFFE0E0E0)),

          // 4. 標籤內容
          Expanded(
            child: TabBarView(
              controller: _searchTabController,
              children: _searchTabs.map((tab) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // 搜索結果
                    _buildSearchResults(context),
                    
                    // 如果沒有搜索結果，顯示搜索歷史和熱搜
                    if (!_hasSearched) ...[
                      // 搜索歷史 (橫向框)
                      _buildSearchHistory(context),

                      // 想享熱搜 (兩列直立)
                      _buildHotSearches(context),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
          
          // 搜索頁面底部贊助區
          SponsorAdWidget(location: '搜索頁面底部贊助區'),
        ],
      ),
    );
  }
}
