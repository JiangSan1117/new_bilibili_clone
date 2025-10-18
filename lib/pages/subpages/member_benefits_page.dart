// lib/pages/subpages/member_benefits_page.dart

import 'package:flutter/material.dart';
import '../../widgets/member_level_widget.dart';
import '../../widgets/sponsor_ad_widget.dart';
import 'real_name_benefits_page.dart';

class MemberBenefitsPage extends StatefulWidget {
  const MemberBenefitsPage({super.key});

  @override
  State<MemberBenefitsPage> createState() => _MemberBenefitsPageState();
}

class _MemberBenefitsPageState extends State<MemberBenefitsPage> {
  int _currentLevel = 8; // 模擬當前等級
  int _currentExp = 750; // 模擬當前經驗值
  int _nextLevelExp = 1000; // 模擬下一級所需經驗值

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('會員權益'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RealNameBenefitsPage(),
                ),
              );
            },
            child: const Text(
              '實名制權益',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 會員權益頁面頂部贊助區
          SponsorAdWidget(location: '會員權益頁面頂部贊助區'),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 當前等級卡片
                  MemberLevelWidget(
                    levelNum: _currentLevel,
                    currentExp: _currentExp,
                    nextLevelExp: _nextLevelExp,
                    showProgress: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 等級系統說明
                  _buildLevelSystemInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // 所有等級權益對比
                  _buildAllLevelsComparison(),
                  
                  const SizedBox(height: 24),
                  
                  // VIP 專屬功能
                  _buildVIPFeatures(),
                  
                  const SizedBox(height: 24),
                  
                  // 升級指南
                  _buildUpgradeGuide(),
                ],
              ),
            ),
          ),
          
          // 會員權益頁面底部贊助區
          SponsorAdWidget(location: '會員權益頁面底部贊助區'),
        ],
      ),
    );
  }

  Widget _buildLevelSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '等級系統說明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 等級越高，享受的權益越多\n'
            '• 通過發布文章、互動、分享獲得經驗值\n'
            '• 達到一定經驗值即可升級\n'
            '• VIP 會員享有所有專屬功能',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllLevelsComparison() {
    final levels = [
      {'level': 1, 'name': '新手', 'color': Colors.grey, 'benefits': ['基礎功能']},
      {'level': 2, 'name': '新手', 'color': Colors.grey, 'benefits': ['基礎功能']},
      {'level': 3, 'name': '銅牌', 'color': Colors.red, 'benefits': ['基礎功能', '優先顯示文章']},
      {'level': 4, 'name': '銀牌', 'color': Colors.orange, 'benefits': ['基礎功能', '優先顯示文章', '專屬標識']},
      {'level': 5, 'name': '金牌', 'color': Colors.yellow, 'benefits': ['基礎功能', '優先顯示文章', '專屬標識', '無限制發布']},
      {'level': 6, 'name': '白金', 'color': Colors.green, 'benefits': ['基礎功能', '優先顯示文章', '專屬標識', '無限制發布', '高級搜索']},
      {'level': 7, 'name': '鑽石', 'color': Colors.blue, 'benefits': ['基礎功能', '優先顯示文章', '專屬標識', '無限制發布', '高級搜索', '專屬客服']},
      {'level': 8, 'name': '大師', 'color': Colors.indigo, 'benefits': ['基礎功能', '優先顯示文章', '專屬標識', '無限制發布', '高級搜索', '專屬客服', '活動優先權']},
      {'level': 9, 'name': '傳說', 'color': Colors.purple, 'benefits': ['所有功能', 'VIP 專屬權益']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '所有等級權益',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...levels.map((levelData) => _buildLevelCard(
          level: levelData['level'] as int,
          name: levelData['name'] as String,
          color: levelData['color'] as Color,
          benefits: levelData['benefits'] as List<String>,
        )),
      ],
    );
  }

  Widget _buildLevelCard({
    required int level,
    required String name,
    required Color color,
    required List<String> benefits,
  }) {
    final isCurrentLevel = level == _currentLevel;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentLevel ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentLevel ? color : Colors.grey.shade300,
          width: isCurrentLevel ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getLevelIcon(level),
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Lv.$level $name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (isCurrentLevel) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '當前等級',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  IconData _getLevelIcon(int level) {
    if (level <= 2) return Icons.star_border;
    if (level == 3) return Icons.star_half;
    if (level == 4) return Icons.star;
    if (level == 5) return Icons.auto_awesome;
    if (level == 6) return Icons.workspace_premium;
    if (level == 7) return Icons.diamond;
    if (level == 8) return Icons.emoji_events;
    if (level >= 9) return Icons.celebration;
    return Icons.star;
  }

  Widget _buildVIPFeatures() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade100,
            Colors.pink.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.celebration, color: Colors.purple.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'VIP 專屬功能',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'VIP 會員享有以下專屬權益：',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ..._getVIPBenefits().map((benefit) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.purple.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getVIPBenefits() {
    return [
      '無廣告體驗',
      '無限發布文章',
      '優先客服支援',
      '專屬 VIP 標識',
      '高級搜索功能',
      '活動優先參與權',
      '專屬內容推薦',
      '數據分析報告',
    ];
  }

  Widget _buildUpgradeGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                '升級指南',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '如何快速升級：',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ..._getUpgradeTips().map((tip) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getUpgradeTips() {
    return [
      '每天發布優質文章 (+10 經驗值)',
      '與其他用戶互動 (+5 經驗值)',
      '分享有價值的內容 (+3 經驗值)',
      '完成每日任務 (+15 經驗值)',
      '邀請朋友加入 (+20 經驗值)',
      '參與社群活動 (+25 經驗值)',
    ];
  }
}
