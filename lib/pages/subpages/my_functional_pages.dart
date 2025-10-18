// lib/pages/subpages/my_functional_pages.dart

import 'package:flutter/material.dart';
import '../../utils/app_widgets.dart'; // 引入 subpageAppBar
import 'version_info_page.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'feedback_page.dart';
import 'copyright_page.dart';

// 【FIXED】: 新增 subpageAppBar 輔助函式
AppBar subpageAppBar(String title) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0.5,
  );
}
// ----------------------------------------------------
// 基本資料頁面已移至 basic_info_page.dart
// ----------------------------------------------------

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar('我的發布'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.article, size: 50, color: Colors.blueGrey),
              const SizedBox(height: 10),
              const Text('此處顯示您所有已發布的文章內容。', style: TextStyle(fontSize: 16)),
              Text('目前共有 58 篇文章。',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 關於想享 (內容已完善)
// ----------------------------------------------------
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar('關於想享'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(Icons.share,
                    size: 60, color: Theme.of(context).primaryColor),
                const Text('想享 (XiangShare)',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('版本號：v1.2.0',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Divider(thickness: 8, height: 40, color: Color(0xFFF5F5F5)),

          // 服務協議、隱私政策、反饋與建議 (作為列表項目)
          _buildAboutItem(context, '版本資訊', Icons.info_outline,
              const VersionInfoPage()),
          _buildAboutItem(context, '使用協議', Icons.policy_outlined,
              const TermsOfServicePage()),
          _buildAboutItem(context, '隱私政策', Icons.lock_outline,
              const PrivacyPolicyPage()),
          _buildAboutItem(context, '反饋與建議', Icons.feedback_outlined,
              const FeedbackPage()),
          _buildAboutItem(context, '版權聲明', Icons.copyright_outlined,
              const CopyrightPage()),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
      BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => page));
      },
      dense: true, // 最小化間隙
    );
  }
}

class PolicyContentPage extends StatelessWidget {
  final String title;
  final String content;
  const PolicyContentPage(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar(title),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),
              Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 贊助專區
// ----------------------------------------------------

class SponsorZonePage extends StatefulWidget {
  const SponsorZonePage({super.key});

  @override
  State<SponsorZonePage> createState() => _SponsorZonePageState();
}

class _SponsorZonePageState extends State<SponsorZonePage> {
  String _selectedPackage = '';
  String _selectedDuration = '';
  String _selectedPaymentMethod = '';
  
  final List<Map<String, dynamic>> _sponsorPackages = [
    {
      'name': '基礎贊助',
      'price': 100,
      'duration': '1個月',
      'features': [
        '贊助區置頂顯示',
        '專屬贊助標識',
        '優先客服支持',
        '月度報告',
      ],
      'color': Colors.blue,
    },
    {
      'name': '標準贊助',
      'price': 280,
      'duration': '3個月',
      'features': [
        '基礎贊助所有功能',
        '更大展示面積',
        '數據分析報告',
        '專屬客服熱線',
        '季度獎勵',
      ],
      'color': Colors.green,
    },
    {
      'name': '高級贊助',
      'price': 500,
      'duration': '6個月',
      'features': [
        '標準贊助所有功能',
        '全屏展示',
        '深度數據洞察',
        '一對一專屬服務',
        '定制化內容',
        '年度獎勵',
      ],
      'color': Colors.purple,
    },
    {
      'name': 'VIP贊助',
      'price': 1000,
      'duration': '12個月',
      'features': [
        '高級贊助所有功能',
        '獨家展示位置',
        '完整數據報告',
        '專屬客戶經理',
        '線下活動邀請',
        '年度大獎',
      ],
      'color': Colors.amber,
    },
  ];

  final List<String> _paymentMethods = [
    '信用卡',
    '銀行轉帳',
    '第三方支付',
    '現金付款',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar('贊助專區'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題和說明
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // 贊助套餐選擇
            _buildPackageSelection(),
            
            const SizedBox(height: 24),
            
            // 支付方式選擇
            _buildPaymentMethodSelection(),
            
            const SizedBox(height: 24),
            
            // 贊助規定
            _buildSponsorRules(),
            
            const SizedBox(height: 24),
            
            // 提交按鈕
            _buildSubmitButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '贊助專區',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '通過贊助支持想享平台發展，享受專屬權益和優先服務。您的支持將幫助我們提供更好的服務體驗。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '選擇贊助套餐',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ..._sponsorPackages.map((package) => _buildPackageCard(package)),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final isSelected = _selectedPackage == package['name'];
    final color = package['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPackage = package['name'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    package['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'NT\$ ${package['price']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${package['duration']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...(package['features'] as List<String>).map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付方式',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _paymentMethods.map((method) => _buildPaymentMethodChip(method)).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodChip(String method) {
    final isSelected = _selectedPaymentMethod == method;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          method,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                '贊助規定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRuleItem('1. 贊助費用一經支付，不予退費'),
          _buildRuleItem('2. 贊助權益僅限本人使用，不得轉讓'),
          _buildRuleItem('3. 贊助期間如有違規行為，將取消贊助權益'),
          _buildRuleItem('4. 贊助到期前7天將發送續費提醒'),
          _buildRuleItem('5. 平台保留最終解釋權'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        rule,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final hasSelectedPackage = _selectedPackage.isNotEmpty;
    final hasSelectedPayment = _selectedPaymentMethod.isNotEmpty;
    final canSubmit = hasSelectedPackage && hasSelectedPayment;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canSubmit ? _submitSponsorApplication : null,
        icon: const Icon(Icons.payment),
        label: Text(canSubmit ? '提交贊助申請' : '請選擇套餐和支付方式'),
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? Theme.of(context).primaryColor : Colors.grey.shade300,
          foregroundColor: canSubmit ? Colors.white : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _submitSponsorApplication() async {
    if (_selectedPackage.isEmpty || _selectedPaymentMethod.isEmpty) {
      _showSnackBar('請選擇套餐和支付方式', isError: true);
      return;
    }

    // 顯示確認對話框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認贊助申請'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('套餐：$_selectedPackage'),
            Text('支付方式：$_selectedPaymentMethod'),
            const SizedBox(height: 12),
            const Text('確定要提交贊助申請嗎？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確認'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 模擬提交申請
      await Future.delayed(const Duration(seconds: 1));
      _showSnackBar('贊助申請已提交，我們將盡快與您聯繫', isError: false);
      
      // 重置選擇
      setState(() {
        _selectedPackage = '';
        _selectedPaymentMethod = '';
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

// ----------------------------------------------------
// 設定 (退出登入移至底部)
// ----------------------------------------------------

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subpageAppBar('設定'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildSettingsGroup(context, '帳號安全', [
            _buildSettingsItem(context, '變更密碼', Icons.lock_outline),
            _buildSettingsItem(context, '兩步驟驗證', Icons.security),
            _buildSettingsItem(context, '登出所有裝置', Icons.devices_other),
          ]),
          _buildSettingsGroup(context, '通知設定', [
            _buildSettingsItem(context, '訊息通知', Icons.notifications_none),
            _buildSettingsItem(context, '文章互動通知', Icons.favorite_outline),
          ]),
          _buildSettingsGroup(context, '其他', [
            _buildSettingsItem(
                context, '清除快取', Icons.cleaning_services_outlined,
                isDestructive: true),
            _buildSettingsItem(context, '語言設定', Icons.language),
          ]),

          // 【最終位置】: 退出登入 按鈕移到設定頁面底部
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
            child: Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('已退出登入')));
                },
                child: const Text(
                  '退出登入',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSettingsGroup(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4), // 最小化標題上下間隙
          child: Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
        ),
        ...children,
        const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }

  static Widget _buildSettingsItem(
      BuildContext context, String title, IconData icon,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.black87)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('點擊了 $title')));
      },
      dense: true, // 最小化間隙
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 0), // 最小化內容 padding
    );
  }
}
