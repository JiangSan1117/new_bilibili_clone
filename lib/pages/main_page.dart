// lib/pages/main_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
// 修正：假設 login_page.dart, search_page.dart, create_post_page.dart 在 lib/ 根目錄
import '../login_page.dart';
import '../search_page.dart';
import 'create_post_page_enhanced.dart';
import '../constants/app_data.dart';
import 'tabs/home_page.dart';
import 'tabs/follow_page.dart';
import 'tabs/message_tabs_page.dart';
import 'tabs/my_page.dart';
import '../services/real_api_service.dart';
import '../providers/auth_provider.dart';
// import '../widgets/sponsor_ad_widget.dart'; // 不再需要全局贊助區

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  // Key 的類型變更為獨立檔案中的 HomePageState
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();
  final GlobalKey<MyPageState> _myPageKey = GlobalKey<MyPageState>();
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(key: _homePageKey),
      const FollowPage(),
      const Center(child: Text('發佈按鈕', style: TextStyle(fontSize: 30))),
      const MessageTabsPage(),
      MyPage(key: _myPageKey),
    ];
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 2) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        // 移除 CreatePostPage 上的 const
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const CreatePostPageEnhanced()))
            .then((result) {
          // 如果發布成功，返回首頁並刷新
          print('📝 發布頁面返回結果: $result');
          if (result == true) {
            print('📝 發布成功，開始刷新首頁');
            _onItemTapped(0, context); // 返回首頁
            // 觸發首頁刷新
            _homePageKey.currentState?.resetToHotTab();
            // 刷新熱門標籤的文章列表
            _homePageKey.currentState?.refreshHotPosts();
            print('📝 首頁刷新完成');
          } else {
            // 處理從發布頁面返回後的狀態，保持在當前選中項或回到首頁
            if (_selectedIndex != 2) {
              setState(() {
                _selectedIndex = _selectedIndex;
              });
            } else {
              _onItemTapped(0, context); // 返回首頁
            }
          }
        });
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const LoginPage()))
            .then((result) async {
          // 如果登入成功，刷新認證狀態和MyPage
          if (result == true) {
            authProvider.loginSuccess();
            // 延遲刷新，確保狀態已更新
            Future.delayed(const Duration(milliseconds: 100), () {
              _myPageKey.currentState?.refresh();
            });
          }
        });
      }
      return;
    }

    // 點擊底部導航的「首頁」圖標時，滾動到熱門頁面
    if (index == 0 && _selectedIndex == 0) {
      _homePageKey.currentState?.resetToHotTab();
      return;
    }

    if (index == 4) {
      debugPrint('導航到我的頁面查看發布成果');
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // 切換到熱門標籤的方法
  void switchToHotTab() {
    setState(() {
      _selectedIndex = 0; // 切換到首頁
    });
    // 通知首頁切換到熱門標籤
    _homePageKey.currentState?.resetToHotTab();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '首頁',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: '關注',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                activeIcon: Icon(Icons.add_box),
                label: '發布',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                activeIcon: Icon(Icons.message),
                label: '訊息',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            onTap: (index) => _onItemTapped(index, context),
          ),
        );
      },
    );
  }
}
