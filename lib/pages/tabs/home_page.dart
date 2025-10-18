// lib/pages/tabs/home_page.dart

import 'package:flutter/material.dart';
import '../../constants/app_data.dart';
import '../search_page.dart';
import 'main_tab_content.dart'; // 【重要修正】確保 MainTabContent 及其 State 被正確引入
import '../../widgets/sponsor_ad_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  // 由於第 5 行的 import，此處的 MainTabContentState 類型將被正確識別
  final List<GlobalKey<MainTabContentState>> _tabKeys = List.generate(
      kMainTabs.length, (index) => GlobalKey<MainTabContentState>());

  @override
  void initState() {
    super.initState();
    _mainTabController =
        TabController(length: kMainTabs.length, vsync: this, initialIndex: 2);
  }

  void resetToHotTab() {
    debugPrint('resetToHotTab 被調用');
    final hotTabIndex = 2;
    debugPrint('當前標籤索引: ${_mainTabController.index}, 目標索引: $hotTabIndex');
    
    // 使用 setState 確保 UI 更新
    setState(() {
      // 先切換到其他標籤，然後再切換到熱門標籤
      if (_mainTabController.index == hotTabIndex) {
        // 如果當前已經是熱門標籤，先切換到其他標籤
        _mainTabController.animateTo(0);
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _mainTabController.animateTo(hotTabIndex);
            debugPrint('切換到熱門標籤');
          });
        });
      } else {
        _mainTabController.animateTo(hotTabIndex);
        debugPrint('切換到熱門標籤');
      }
    });

    // 重置子標籤到"全部"
    final currentState = _tabKeys[hotTabIndex].currentState;
    currentState?.resetToAllCategory();
  }

  // 刷新熱門標籤的文章列表
  void refreshHotPosts() {
    final hotTabIndex = 2;
    final currentState = _tabKeys[hotTabIndex].currentState;
    currentState?.refreshPosts();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  // 構造帶有搜索框的頂部欄
  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return PreferredSize(
      // 【優化 1】: 縮小整體高度到 90.0
      preferredSize: const Size.fromHeight(90.0),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // 頂部名稱/搜索欄區域 (更緊湊)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  Text(
                    '想享',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SearchPage()));
                        
                        // 檢查是否需要切換到熱門標籤
                        debugPrint('搜索頁面返回結果: $result');
                        if (result != null && result['switchToHotTab'] == true) {
                          debugPrint('需要切換到熱門標籤');
                          // 直接調用首頁的 resetToHotTab 方法
                          resetToHotTab();
                        }
                      },
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              '搜索感興趣的內容...',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 主 TabBar 區域 (第一層標籤)
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: TabBar(
                  controller: _mainTabController,
                  // 平均分佈
                  isScrollable: false,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // 優化字體比例
                  ),
                  labelPadding: EdgeInsets.zero,
                  tabs: kMainTabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
            ),
            const Divider(height: 0, thickness: 0.5, color: Color(0xFFE0E0E0)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchAppBar(context),
      body: TabBarView(
        controller: _mainTabController,
        children: List.generate(kMainTabs.length, (index) {
          final mainTabTitle = kMainTabs[index];
          // 由於第 5 行的 import，此處的 MainTabContent 類別將被正確識別
          return MainTabContent(
              key: _tabKeys[index], mainTabTitle: mainTabTitle);
        }),
      ),
    );
  }
}
