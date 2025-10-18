// lib/pages/subpages/analytics_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedUserId = 'current_user_id'; // 這裡應該從認證服務獲取
  UserAnalytics? _userAnalytics;
  Map<String, int> _eventStats = {};
  List<MapEntry<String, int>> _topCategories = [];
  Map<String, dynamic> _userActivity = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await AnalyticsService.getUserAnalytics(_selectedUserId);
      final eventStats = await AnalyticsService.getEventStats(_selectedUserId, days: 7);
      final topCategories = await AnalyticsService.getTopCategories(_selectedUserId);
      final userActivity = await AnalyticsService.getUserActivity(_selectedUserId, days: 30);

      setState(() {
        _userAnalytics = analytics;
        _eventStats = eventStats;
        _topCategories = topCategories;
        _userActivity = userActivity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('載入分析數據失敗: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('數據分析'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 總覽統計卡片
                  _buildOverviewCards(),
                  
                  const SizedBox(height: 24),
                  
                  // 事件統計圖表
                  _buildEventStatsChart(),
                  
                  const SizedBox(height: 24),
                  
                  // 熱門分類
                  _buildTopCategories(),
                  
                  const SizedBox(height: 24),
                  
                  // 用戶活躍度
                  _buildUserActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    if (_userAnalytics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '總覽統計',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              '發布文章',
              _userAnalytics!.totalPosts.toString(),
              Icons.article,
              Colors.blue,
            ),
            _buildStatCard(
              '獲得讚數',
              _userAnalytics!.totalLikes.toString(),
              Icons.thumb_up,
              Colors.red,
            ),
            _buildStatCard(
              '評論數量',
              _userAnalytics!.totalComments.toString(),
              Icons.comment,
              Colors.green,
            ),
            _buildStatCard(
              '分享次數',
              _userAnalytics!.totalShares.toString(),
              Icons.share,
              Colors.orange,
            ),
            _buildStatCard(
              '總瀏覽量',
              _userAnalytics!.totalViews.toString(),
              Icons.visibility,
              Colors.purple,
            ),
            _buildStatCard(
              '關注者',
              _userAnalytics!.totalFollowers.toString(),
              Icons.people,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventStatsChart() {
    if (_eventStats.isEmpty) return const SizedBox.shrink();

    final chartData = _eventStats.entries.map((entry) {
      return PieChartSectionData(
        color: _getEventColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近7天活動統計',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: chartData,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _eventStats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getEventColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getEventDisplayName(entry.key),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategories() {
    if (_topCategories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '熱門分類',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = _userAnalytics?.totalPosts != null && _userAnalytics!.totalPosts > 0
                  ? (category.value / _userAnalytics!.totalPosts * 100).toStringAsFixed(1)
                  : '0.0';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${category.value} 篇文章 ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserActivity() {
    if (_userActivity.isEmpty) return const SizedBox.shrink();

    final dailyActivity = _userActivity['dailyActivity'] as Map<String, int>? ?? {};
    final avgDailyActivity = _userActivity['avgDailyActivity'] as double? ?? 0.0;
    final totalEvents = _userActivity['totalEvents'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '用戶活躍度',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActivityStat(
                    '總活動數',
                    totalEvents.toString(),
                    Icons.trending_up,
                  ),
                  _buildActivityStat(
                    '日均活躍度',
                    avgDailyActivity.toStringAsFixed(1),
                    Icons.calendar_today,
                  ),
                ],
              ),
              if (dailyActivity.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  '最近7天活躍度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dailyActivity.values.isNotEmpty 
                          ? dailyActivity.values.reduce((a, b) => a > b ? a : b).toDouble() + 2
                          : 10,
                      barGroups: dailyActivity.entries.take(7).map((entry) {
                        return BarChartGroupData(
                          x: dailyActivity.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Theme.of(context).primaryColor,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case AnalyticsService.eventPostView:
        return Colors.blue;
      case AnalyticsService.eventPostLike:
        return Colors.red;
      case AnalyticsService.eventPostComment:
        return Colors.green;
      case AnalyticsService.eventPostShare:
        return Colors.orange;
      case AnalyticsService.eventPostCreate:
        return Colors.purple;
      case AnalyticsService.eventUserFollow:
        return Colors.teal;
      case AnalyticsService.eventSearch:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getEventDisplayName(String eventType) {
    switch (eventType) {
      case AnalyticsService.eventPostView:
        return '瀏覽文章';
      case AnalyticsService.eventPostLike:
        return '點讚';
      case AnalyticsService.eventPostComment:
        return '評論';
      case AnalyticsService.eventPostShare:
        return '分享';
      case AnalyticsService.eventPostCreate:
        return '發布文章';
      case AnalyticsService.eventUserFollow:
        return '關注';
      case AnalyticsService.eventSearch:
        return '搜索';
      default:
        return eventType;
    }
  }
}
