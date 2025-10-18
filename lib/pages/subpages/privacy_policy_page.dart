// lib/pages/subpages/privacy_policy_page.dart

import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隱私政策'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '我們承諾保護您的隱私，本政策詳細說明我們如何收集、使用和保護您的個人信息。',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              '1. 信息收集',
              '我們可能收集以下類型的信息：\n\n'
              '個人識別信息：\n'
              '• 姓名、暱稱、電子郵件地址\n'
              '• 電話號碼（可選）\n'
              '• 個人資料圖片\n'
              '• 地理位置信息（可選）\n\n'
              '使用信息：\n'
              '• 應用使用統計數據\n'
              '• 設備信息（設備型號、操作系統版本）\n'
              '• 瀏覽和互動記錄\n'
              '• 發布的內容和評論',
            ),
            
            _buildSection(
              '2. 信息使用',
              '我們收集的信息用於以下目的：\n\n'
              '• 提供和改進我們的服務\n'
              '• 個性化用戶體驗\n'
              '• 與用戶溝通（通知、客服支持）\n'
              '• 確保平台安全和防止濫用\n'
              '• 分析和統計（匿名化處理）\n'
              '• 法律合規和爭議解決',
            ),
            
            _buildSection(
              '3. 信息共享',
              '我們不會出售、交易或轉讓您的個人信息給第三方，除非：\n\n'
              '• 獲得您的明確同意\n'
              '• 法律要求或政府部門要求\n'
              '• 保護我們的權利、財產或安全\n'
              '• 與可信賴的服務提供商合作（如雲端存儲、分析工具）\n'
              '• 業務轉讓或合併時',
            ),
            
            _buildSection(
              '4. 數據安全',
              '我們採取多種安全措施保護您的信息：\n\n'
              '• 數據加密傳輸和存儲\n'
              '• 定期安全審計和更新\n'
              '• 限制員工訪問權限\n'
              '• 安全監控和入侵檢測\n'
              '• 定期備份和災難恢復計劃',
            ),
            
            _buildSection(
              '5. 數據保留',
              '我們保留您的個人信息的時間：\n\n'
              '• 帳號活躍期間：持續保留\n'
              '• 帳號刪除後：最多保留30天用於安全目的\n'
              '• 法律要求：按相關法律規定保留\n'
              '• 匿名化數據：可長期保留用於統計分析',
            ),
            
            _buildSection(
              '6. 您的權利',
              '您對自己的個人信息享有以下權利：\n\n'
              '• 訪問權：查看我們持有的您的信息\n'
              '• 更正權：要求更正不準確的信息\n'
              '• 刪除權：要求刪除您的個人信息\n'
              '• 限制處理權：限制我們處理您的信息\n'
              '• 數據可攜權：要求以結構化格式提供您的數據\n'
              '• 反對權：反對某些類型的數據處理',
            ),
            
            _buildSection(
              '7. Cookie和追蹤技術',
              '我們使用以下技術收集信息：\n\n'
              '• Cookie：用於記住用戶偏好和登入狀態\n'
              '• 本地存儲：在設備上存儲應用設置\n'
              '• 分析工具：了解應用使用情況\n'
              '• 推送通知：向您發送重要更新\n\n'
              '您可以通過設備設置控制這些功能。',
            ),
            
            _buildSection(
              '8. 第三方服務',
              '我們可能使用以下第三方服務：\n\n'
              '• 雲端存儲服務（圖片、視頻存儲）\n'
              '• 分析服務（使用統計）\n'
              '• 支付服務（如適用）\n'
              '• 社交媒體集成\n\n'
              '這些服務有各自的隱私政策，請查看相關條款。',
            ),
            
            _buildSection(
              '9. 兒童隱私',
              '• 我們的服務主要面向13歲以上的用戶\n'
              '• 我們不會故意收集13歲以下兒童的個人信息\n'
              '• 如果發現收集了兒童信息，我們會立即刪除\n'
              '• 家長如發現孩子提供了個人信息，請聯繫我們',
            ),
            
            _buildSection(
              '10. 國際數據傳輸',
              '• 您的數據可能被傳輸到其他國家/地區進行處理\n'
              '• 我們確保傳輸過程符合適用的數據保護法律\n'
              '• 我們使用標準合同條款保護您的數據\n'
              '• 傳輸的數據將受到與本地相同的保護',
            ),
            
            _buildSection(
              '11. 政策更新',
              '• 我們可能會不時更新本隱私政策\n'
              '• 重大變更會通過應用內通知告知用戶\n'
              '• 繼續使用服務即表示同意更新後的政策\n'
              '• 建議定期查看本政策的最新版本',
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '聯繫我們',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '如果您對本隱私政策有任何疑問或需要行使您的權利，請聯繫我們：\n\n'
                    '隱私保護專員：privacy@xiangshare.com\n'
                    '客服郵箱：support@xiangshare.com\n'
                    '客服電話：0800-123-456\n'
                    '地址：台北市信義區信義路五段7號',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '生效日期',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '本隱私政策最後更新於：2024年12月15日',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
