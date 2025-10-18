// lib/pages/subpages/sponsor_zone_page.dart

import 'package:flutter/material.dart';

class SponsorZonePage extends StatelessWidget {
  const SponsorZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('贊助專區'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題區域
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade300,
                          Colors.pink.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '贊助專區',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '支持想享，讓我們變得更好',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 贊助說明
            _buildSection(
              title: '為什麼需要您的支持？',
              content: '想享致力於為用戶提供優質的社交體驗，您的支持將幫助我們持續改進服務、增加新功能，並為所有用戶創造更好的分享環境。',
            ),
            
            const SizedBox(height: 24),
            
            // 贊助等級
            _buildSection(
              title: '贊助等級',
              children: [
                _buildSponsorLevel(
                  '🌟 小額支持',
                  'NT\$ 50',
                  '一杯咖啡的價格，支持想享持續運營',
                  ['感謝您的支持', '獲得專屬徽章'],
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildSponsorLevel(
                  '💎 熱心支持',
                  'NT\$ 200',
                  '幫助我們開發更多精彩功能',
                  ['感謝您的支持', '獲得專屬徽章', '優先客服支持'],
                  Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildSponsorLevel(
                  '👑 超級支持',
                  'NT\$ 500',
                  '成為想享的重要夥伴',
                  ['感謝您的支持', '獲得專屬徽章', '優先客服支持', '獨家內容預覽'],
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildSponsorLevel(
                  '🚀 夢想支持',
                  'NT\$ 1,000',
                  '與我們一起打造更好的想享',
                  ['感謝您的支持', '獲得專屬徽章', '優先客服支持', '獨家內容預覽', '參與功能設計'],
                  Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 贊助方式
            _buildSection(
              title: '贊助方式',
              children: [
                _buildPaymentMethod(
                  '💳 信用卡',
                  'Visa, MasterCard, JCB',
                  Icons.credit_card,
                ),
                _buildPaymentMethod(
                  '🏦 銀行轉帳',
                  'ATM轉帳、網路銀行',
                  Icons.account_balance,
                ),
                _buildPaymentMethod(
                  '📱 行動支付',
                  'Line Pay, Apple Pay, Google Pay',
                  Icons.payment,
                ),
                _buildPaymentMethod(
                  '🏪 超商付款',
                  '7-11, 全家, 萊爾富, OK',
                  Icons.store,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 贊助用途
            _buildSection(
              title: '您的贊助將用於',
              children: [
                _buildUsageItem('🔧 技術開發', '持續改進應用性能和穩定性'),
                _buildUsageItem('🎨 設計優化', '提升用戶界面和體驗'),
                _buildUsageItem('🛡️ 安全保障', '加強數據保護和隱私安全'),
                _buildUsageItem('📈 功能擴展', '開發更多實用的新功能'),
                _buildUsageItem('🎯 內容品質', '維護平台內容品質和環境'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 贊助按鈕
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showSponsorDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        '立即贊助',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '感謝每一位支持想享的朋友！',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 贊助者感謝
            _buildSection(
              title: '特別感謝',
              children: [
                const Text(
                  '感謝所有贊助者的支持，是你們讓想享變得更好！',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '贊助者名單',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '匿名贊助者 × 15\n小額支持者 × 8\n熱心支持者 × 3\n超級支持者 × 1',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (content != null)
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        if (children != null) ...children,
      ],
    );
  }

  Widget _buildSponsorLevel(String title, String price, String description, List<String> benefits, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                price,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  benefit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSponsorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇贊助金額'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('請選擇您想要贊助的金額：'),
            const SizedBox(height: 16),
            _buildSponsorOption(context, 'NT\$ 50', '小額支持'),
            _buildSponsorOption(context, 'NT\$ 200', '熱心支持'),
            _buildSponsorOption(context, 'NT\$ 500', '超級支持'),
            _buildSponsorOption(context, 'NT\$ 1,000', '夢想支持'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorOption(BuildContext context, String amount, String level) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('感謝您的贊助！選擇了 $amount - $level'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              level,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
