// lib/pages/subpages/terms_of_service_page.dart

import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用協議'),
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '請仔細閱讀以下使用協議，使用本應用即表示您同意遵守這些條款。',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              '1. 服務說明',
              '想享（XiangShare）是一個社交分享平台，允許用戶發布、分享和瀏覽各種內容，包括文章、圖片、視頻等。我們致力於為用戶提供安全、友好的交流環境。',
            ),
            
            _buildSection(
              '2. 用戶註冊與帳號安全',
              '• 用戶需要提供真實、準確的個人信息進行註冊\n'
              '• 用戶有責任保護自己的帳號密碼安全\n'
              '• 禁止將帳號借給他人使用\n'
              '• 如發現帳號被盜用，應立即聯繫客服',
            ),
            
            _buildSection(
              '3. 用戶行為規範',
              '用戶在使用本服務時，不得：\n'
              '• 發布違法、有害、威脅、濫用、騷擾、誹謗、粗俗、淫穢或其他不當內容\n'
              '• 侵犯他人的知識產權或其他合法權益\n'
              '• 進行任何可能損害、癱瘓、過度負載或損害本服務的活動\n'
              '• 使用自動化工具或機器人進行任何活動\n'
              '• 冒充他人或實體',
            ),
            
            _buildSection(
              '4. 內容政策',
              '• 用戶對其發布的內容承擔全部責任\n'
              '• 禁止發布涉及暴力、色情、仇恨言論等不當內容\n'
              '• 尊重他人隱私，不得未經同意發布他人私人信息\n'
              '• 我們有權刪除違反本協議的內容',
            ),
            
            _buildSection(
              '5. 知識產權',
              '• 本服務的軟件、技術、程序、代碼、用戶界面等均受知識產權法保護\n'
              '• 用戶保留對其原創內容的知識產權\n'
              '• 用戶授權我們在提供服務的必要範圍內使用其內容',
            ),
            
            _buildSection(
              '6. 隱私保護',
              '• 我們重視用戶隱私，詳細政策請參見《隱私政策》\n'
              '• 我們會採取適當措施保護用戶個人信息\n'
              '• 用戶可以隨時查看、修改或刪除自己的個人信息',
            ),
            
            _buildSection(
              '7. 服務變更與終止',
              '• 我們保留隨時修改、暫停或終止服務的權利\n'
              '• 重要變更會提前通知用戶\n'
              '• 用戶可以隨時停止使用我們的服務',
            ),
            
            _buildSection(
              '8. 免責聲明',
              '• 本服務按「現狀」提供，我們不保證服務的連續性、準確性或完整性\n'
              '• 用戶使用本服務的風險由用戶自行承擔\n'
              '• 我們不對因使用本服務而產生的任何直接或間接損失承擔責任',
            ),
            
            _buildSection(
              '9. 爭議解決',
              '• 本協議適用於中華民國法律\n'
              '• 因本協議產生的爭議，雙方應友好協商解決\n'
              '• 協商不成的，可向有管轄權的法院提起訴訟',
            ),
            
            _buildSection(
              '10. 協議修改',
              '• 我們有權隨時修改本協議\n'
              '• 修改後的協議將在應用內公布\n'
              '• 繼續使用服務即表示同意修改後的協議',
            ),
            
            const SizedBox(height: 24),
            
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
                    '最後更新：2024年12月15日',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '如有任何疑問，請聯繫客服：\n'
                    '電子郵件：support@xiangshare.com\n'
                    '客服電話：0800-123-456',
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
