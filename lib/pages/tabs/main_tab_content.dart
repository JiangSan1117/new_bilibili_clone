// lib/pages/tabs/main_tab_content.dart

import 'package:flutter/material.dart';
import '../../constants/app_data.dart';
import '../post_feed_list.dart'; // 確保 post_feed_list.dart 被正確引入
import '../../widgets/sponsor_ad_widget.dart';

class MainTabContent extends StatefulWidget {
  final String mainTabTitle;
  const MainTabContent({super.key, required this.mainTabTitle});

  @override
  State<MainTabContent> createState() => MainTabContentState();
}

class MainTabContentState extends State<MainTabContent>
    with SingleTickerProviderStateMixin {
  late TabController _categoryTabController;
  final GlobalKey<PostFeedListState> _postFeedListKey = GlobalKey<PostFeedListState>();

  @override
  void initState() {
    super.initState();
    // 只有在非「熱門」頁籤時，才初始化分類 Tab 的控制器
    _categoryTabController = TabController(
        length: kCategoryTabs.length, vsync: this, initialIndex: 0);
  }

  void resetToAllCategory() {
    if (_categoryTabController.index != 0) {
      _categoryTabController.animateTo(0);
    }
  }

  // 刷新文章列表
  void refreshPosts() {
    _postFeedListKey.currentState?.refresh();
  }

  @override
  void dispose() {
    // 只有在非「熱門」頁籤時，才需要 dispose
    if (widget.mainTabTitle != '熱門') {
      _categoryTabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 【FIXED 1】: 熱門標籤不需要第二層 Tab，但有贊助區
    if (widget.mainTabTitle == '熱門') {
      return Column(
        children: [
          // 熱門頂部贊助區
          SponsorAdWidget(location: '${widget.mainTabTitle}頂部贊助區'),
          
          Expanded(
            child: PostFeedList(
              key: _postFeedListKey,
              isHotPage: true, // 傳遞 isHotPage 參數，讓列表知道要按點閱率排序
              mainTabTitle: widget.mainTabTitle,
              categoryTitle: null, // 無需分類
            ),
          ),
          
          // 熱門底部贊助區
          SponsorAdWidget(location: '${widget.mainTabTitle}底部贊助區'),
        ],
      );
    }

    // 其他標籤 (共享, 共同, 分享, 交換) 則保留第二層 Tab
    return Column(
      children: [
        // 次級分類 TabBar 區域 (第二層標籤)
        SizedBox(
          height: 40,
          child: TabBar(
            controller: _categoryTabController,
            // 固定分佈
            isScrollable: false,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            labelPadding: EdgeInsets.zero,
            tabs: kCategoryTabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        // 分隔線
        const Divider(height: 0, thickness: 0.5, color: Color(0xFFE0E0E0)),
        
        // 頂部贊助區 - 固定全版面
        SponsorAdWidget(location: '${widget.mainTabTitle}頂部贊助區'),
        
        Expanded(
          child: TabBarView(
            controller: _categoryTabController,
            children: kCategoryTabs.map<Widget>((category) {
              return PostFeedList(
                isHotPage: false, // 非熱門頁面
                mainTabTitle: widget.mainTabTitle,
                categoryTitle: category,
              );
            }).toList(),
          ),
        ),
        
        // 底部贊助區 - 固定全版面
        SponsorAdWidget(location: '${widget.mainTabTitle}底部贊助區'),
      ],
    );
  }
}
