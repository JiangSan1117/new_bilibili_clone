// lib/pages/subpages/about_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('關於想享'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo 和基本資訊
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '想享',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '版本 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App 介紹
            _buildSection(
              title: '關於想享',
              content: '想享是一個專注於分享與交流的社交平台，讓用戶能夠輕鬆分享生活點滴、發現有趣內容，並與志同道合的朋友建立聯繫。',
            ),
            
            const SizedBox(height: 24),
            
            // 主要功能
            _buildSection(
              title: '主要功能',
              children: [
                _buildFeatureItem('📝 內容分享', '發布文章、圖片、視頻等豐富內容'),
                _buildFeatureItem('👥 社交互動', '關注、點讚、評論，建立社交網絡'),
                _buildFeatureItem('🔍 智能搜索', '快速找到感興趣的內容和用戶'),
                _buildFeatureItem('💬 即時通訊', '與朋友進行私密對話'),
                _buildFeatureItem('🎯 個性推薦', '根據興趣推薦優質內容'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 聯絡方式
            _buildSection(
              title: '聯絡我們',
              children: [
                _buildContactItem(context, '📧 客服信箱', 'support@xiangxiang.com', () {
                  _copyToClipboard(context, 'support@xiangxiang.com');
                }),
                _buildContactItem(context, '📱 官方網站', 'www.xiangxiang.com', () {
                  _copyToClipboard(context, 'www.xiangxiang.com');
                }),
                _buildContactItem(context, '📞 客服專線', '0800-123-456', () {
                  _copyToClipboard(context, '0800-123-456');
                }),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 法律資訊
            _buildSection(
              title: '法律資訊',
              children: [
                _buildLegalItem('服務條款', () {
                  _showLegalDialog(context, '服務條款', _getTermsOfService());
                }),
                _buildLegalItem('隱私政策', () {
                  _showLegalDialog(context, '隱私政策', _getPrivacyPolicy());
                }),
                _buildLegalItem('使用規範', () {
                  _showLegalDialog(context, '使用規範', _getUsageGuidelines());
                }),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // 版權資訊
            Center(
              child: Column(
                children: [
                  const Text(
                    '© 2024 想享團隊',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Made with ❤️ in Taiwan',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.copy,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已複製: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  String _getTermsOfService() {
    return '''
歡迎使用想享服務！

1. 服務說明
想享提供內容分享、社交互動等服務。

2. 用戶責任
- 遵守相關法律法規
- 不得發布違法、有害內容
- 保護個人隱私

3. 服務變更
我們保留隨時修改服務條款的權利。

4. 免責聲明
用戶對使用本服務的風險自負。

詳細條款請參考完整版本。
    ''';
  }

  String _getPrivacyPolicy() {
    return '''
想享隱私政策

1. 資訊收集
我們會收集您提供的基本資訊和服務使用數據。

2. 資訊使用
- 提供和改進服務
- 個性化推薦
- 客戶服務

3. 資訊保護
我們採用業界標準的安全措施保護您的資訊。

4. 資訊分享
除法律要求外，我們不會與第三方分享您的個人資訊。

5. 您的權利
您有權查詢、修改或刪除您的個人資訊。

詳細政策請參考完整版本。
    ''';
  }

  String _getUsageGuidelines() {
    return '''
想享使用規範

1. 基本原則
- 尊重他人
- 友善交流
- 誠實分享

2. 禁止行為
- 發布違法內容
- 騷擾他人
- 虛假資訊
- 垃圾訊息

3. 內容規範
- 原創優先
- 品質保證
- 適當分類

4. 違規處理
違反規範的用戶將面臨警告、限制或封號等處罰。

5. 申訴機制
如對處罰有異議，可通過客服申訴。

詳細規範請參考完整版本。
    ''';
  }
}
