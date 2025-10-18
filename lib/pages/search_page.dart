// lib/pages/search_page.dart
import 'package:flutter/material.dart';
import 'search_results_page.dart';

// 輔助函式：構造【固定】贊助區 (全版面)
Widget _buildFixedSponsorAd(String location, BuildContext context) {
  return Container(
    height: 60,
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.symmetric(vertical: 0.0),
    decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        border: Border.all(color: Colors.orange.shade300)),
    alignment: Alignment.center,
    child: Text(
      '贊助區廣告 ($location)',
      style:
          TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 模擬搜尋歷史 (最多 10 個，新舊輪替)
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

  // 1. 處理搜尋並更新歷史紀錄
  void _addSearchToHistory(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    if (_searchHistory.isNotEmpty && _searchHistory.first == trimmedQuery) {
      debugPrint('執行搜尋: $trimmedQuery (歷史紀錄未更新)');
      _navigateToSearchResults(trimmedQuery);
      return;
    }

    setState(() {
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
    debugPrint('執行搜尋: $trimmedQuery');
    
    // 導航到搜索結果頁面
    _navigateToSearchResults(trimmedQuery);
  }

  // 導航到搜索結果頁面
  void _navigateToSearchResults(String query) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          query: query,
          category: null, // 可以根據需要添加分類篩選
        ),
      ),
    );
  }

  // 2. 清除搜尋歷史
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('搜尋歷史已清除')),
    );
  }

  // 3. 構造頂部搜尋框 (放大鏡在最左邊)
  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return AppBar(
      // 確保返回箭頭顯示
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      titleSpacing: 0,

      title: Row(
        children: [
          // 搜尋框
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '搜尋你感興趣的內容...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  // 調整 contentPadding 使文字垂直居中
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.0,
                ),
                onSubmitted: (query) {
                  _addSearchToHistory(query);
                },
              ),
            ),
          ),
          // 右邊的搜尋按鈕 (文字)
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

  // 4. 構造搜尋歷史列表 (新樣式：框呈現，橫向 Wrap，框縮小)
  Widget _buildSearchHistory(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35, // 固定高度，各佔一半
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '搜尋歷史',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold), // 稍微減小字體
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _searchHistory.isEmpty
                  ? const Center(
                      child: Text(
                        '暫無搜尋歷史',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _searchHistory.map((query) {
                        return InkWell(
                          onTap: () {
                            _searchController.text = query;
                            _addSearchToHistory(query);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6), // 減小內邊距
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  query,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14), // 減小字體
                                ),
                                const SizedBox(width: 6),
                                // 刪除按鈕
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _searchHistory.remove(query);
                                    });
                                  },
                                  child: const Icon(Icons.close,
                                      color: Colors.grey, size: 16), // 減小圖標
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. 構造想享熱搜列表 (兩列直立，無框，無編號)
  Widget _buildHotSearches(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35, // 固定高度，各佔一半
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 15, 16, 10),
            child: Text(
              '想享熱搜',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // 保持大字體
            ),
          ),
          // 使用 Expanded 確保 GridView 佔據剩餘空間
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // 禁止滾動
                itemCount: _mockHotSearches.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 5,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (context, index) {
                  final query = _mockHotSearches[index];
                  return InkWell(
                    onTap: () {
                      _searchController.text = query;
                      _addSearchToHistory(query);
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 確保鍵盤彈出時，贊助區下保持底部不動
    return Scaffold(
      resizeToAvoidBottomInset: false,

      // 1. 搜尋框 (頂部)
      appBar: _buildSearchAppBar(context),

      body: Column(
        children: [
          // 2. 贊助區上 (固定)
          _buildFixedSponsorAd('搜尋頁面上方贊助區', context),

          // 3. 內容區域 - 固定高度，禁止滾動
          Expanded(
            child: Column(
              children: [
                // 搜尋歷史 (固定高度)
                _buildSearchHistory(context),

                // 想享熱搜 (固定高度) - 移除分隔線
                _buildHotSearches(context),
              ],
            ),
          ),

          // 4. 贊助區下 (固定)
          _buildFixedSponsorAd('搜尋頁面下方贊助區', context),
        ],
      ),
    );
  }
}

// 模擬數據 (熱搜和歷史紀錄)
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
  '攝影技巧分享',
  '程式設計學習資源',
];
