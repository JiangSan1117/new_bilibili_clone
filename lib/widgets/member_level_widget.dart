// lib/widgets/member_level_widget.dart

import 'package:flutter/material.dart';

class MemberLevelWidget extends StatelessWidget {
  final int levelNum;
  final int currentExp;
  final int nextLevelExp;
  final bool showProgress;
  final bool isCompact;

  const MemberLevelWidget({
    super.key,
    required this.levelNum,
    this.currentExp = 0,
    this.nextLevelExp = 100,
    this.showProgress = false,
    this.isCompact = false,
  });

  // 根據等級返回顏色
  Color _getLevelColor(int levelNum) {
    if (levelNum <= 2) return Colors.grey.shade600; // White (用深灰色文字模擬白色等級)
    if (levelNum == 3) return const Color(0xFFF87171); // Red
    if (levelNum == 4) return const Color(0xFFFBBF24); // Orange
    if (levelNum == 5) return const Color(0xFFFDE047); // Yellow
    if (levelNum == 6) return const Color(0xFF4ADE80); // Green
    if (levelNum == 7) return const Color(0xFF60A5FA); // Blue
    if (levelNum == 8) return const Color(0xFF818CF8); // Indigo
    if (levelNum >= 9) return const Color(0xFFC084FC); // Purple (Max Level)
    return Colors.grey.shade400; // Default
  }

  // 根據等級返回等級名稱
  String _getLevelName(int levelNum) {
    if (levelNum <= 2) return '新手';
    if (levelNum == 3) return '銅牌';
    if (levelNum == 4) return '銀牌';
    if (levelNum == 5) return '金牌';
    if (levelNum == 6) return '白金';
    if (levelNum == 7) return '鑽石';
    if (levelNum == 8) return '大師';
    if (levelNum >= 9) return '傳說';
    return '未知';
  }

  // 根據等級返回等級圖標
  IconData _getLevelIcon(int levelNum) {
    if (levelNum <= 2) return Icons.star_border;
    if (levelNum == 3) return Icons.star_half;
    if (levelNum == 4) return Icons.star;
    if (levelNum == 5) return Icons.auto_awesome;
    if (levelNum == 6) return Icons.workspace_premium;
    if (levelNum == 7) return Icons.diamond;
    if (levelNum == 8) return Icons.emoji_events;
    if (levelNum >= 9) return Icons.celebration;
    return Icons.star;
  }

  // 計算經驗值進度
  double _getProgressPercentage() {
    if (nextLevelExp <= currentExp) return 1.0;
    if (currentExp <= 0) return 0.0;
    return currentExp / nextLevelExp;
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(levelNum);
    final levelName = _getLevelName(levelNum);
    final levelIcon = _getLevelIcon(levelNum);
    final progressPercentage = _getProgressPercentage();

    if (isCompact) {
      return _buildCompactLevel(levelColor, levelName, levelIcon);
    }

    return _buildFullLevel(context, levelColor, levelName, levelIcon, progressPercentage);
  }

  Widget _buildCompactLevel(Color levelColor, String levelName, IconData levelIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: levelColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(levelIcon, size: 16, color: levelColor),
          const SizedBox(width: 4),
          Text(
            'Lv.$levelNum $levelName',
            style: TextStyle(
              color: levelColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullLevel(BuildContext context, Color levelColor, String levelName, IconData levelIcon, double progressPercentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withOpacity(0.1),
            levelColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 等級標題
          Row(
            children: [
              Icon(levelIcon, size: 24, color: levelColor),
              const SizedBox(width: 8),
              Text(
                'Lv.$levelNum $levelName',
                style: TextStyle(
                  color: levelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (levelNum >= 9)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'VIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 經驗值進度條
          if (showProgress) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '經驗值: $currentExp / $nextLevelExp',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              minHeight: 6,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 等級權益
          _buildLevelBenefits(levelNum, levelColor),
        ],
      ),
    );
  }

  Widget _buildLevelBenefits(int levelNum, Color levelColor) {
    List<String> benefits = [];
    
    if (levelNum >= 3) benefits.add('優先顯示文章');
    if (levelNum >= 4) benefits.add('專屬標識');
    if (levelNum >= 5) benefits.add('無限制發布');
    if (levelNum >= 6) benefits.add('高級搜索');
    if (levelNum >= 7) benefits.add('專屬客服');
    if (levelNum >= 8) benefits.add('活動優先權');
    if (levelNum >= 9) benefits.add('所有VIP權益');

    if (benefits.isEmpty) {
      benefits.add('基礎功能');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '等級權益:',
          style: TextStyle(
            color: levelColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 14,
                color: levelColor,
              ),
              const SizedBox(width: 4),
              Text(
                benefit,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

// 等級進度條組件
class LevelProgressBar extends StatelessWidget {
  final int currentExp;
  final int nextLevelExp;
  final Color color;

  const LevelProgressBar({
    super.key,
    required this.currentExp,
    required this.nextLevelExp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nextLevelExp > 0 ? currentExp / nextLevelExp : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '經驗值: $currentExp',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              '下一級: $nextLevelExp',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
        ),
      ],
    );
  }
}
