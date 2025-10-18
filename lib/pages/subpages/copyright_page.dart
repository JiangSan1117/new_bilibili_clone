// lib/pages/subpages/copyright_page.dart

import 'package:flutter/material.dart';

class CopyrightPage extends StatelessWidget {
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('版權聲明'),
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
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.copyright, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '本應用及其所有內容均受版權法保護，請尊重知識產權。',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              '1. 應用版權',
              '想享（XiangShare）應用軟件及其所有組件，包括但不限於：\n\n'
              '• 用戶界面設計和佈局\n'
              '• 應用程序代碼和邏輯\n'
              '• 圖標、圖片、動畫等視覺元素\n'
              '• 音頻、視頻等媒體內容\n'
              '• 數據庫結構和算法\n\n'
              '以上內容均為我們的原創作品，受中華民國著作權法保護。',
            ),
            
            _buildSection(
              '2. 第三方內容',
              '本應用可能包含以下第三方內容：\n\n'
              '• 開源軟件庫和組件\n'
              '• 授權使用的圖片和媒體素材\n'
              '• 第三方API服務\n'
              '• 用戶生成內容\n\n'
              '我們已獲得必要的授權或許可，並遵守相關使用條款。',
            ),
            
            _buildSection(
              '3. 用戶內容版權',
              '關於用戶發布的內容：\n\n'
              '• 用戶保留對其原創內容的版權\n'
              '• 用戶授權我們在提供服務的必要範圍內使用其內容\n'
              '• 用戶承擔其內容的版權責任\n'
              '• 我們有權移除涉嫌侵權的用戶內容\n'
              '• 用戶不得發布侵犯他人版權的內容',
            ),
            
            _buildSection(
              '4. 禁止行為',
              '未經我們明確書面許可，禁止以下行為：\n\n'
              '• 複製、修改、分發本應用軟件\n'
              '• 逆向工程、反編譯或反彙編應用代碼\n'
              '• 移除或修改版權聲明和標識\n'
              '• 商業性使用我們的知識產權\n'
              '• 創建衍生作品或競爭產品\n'
              '• 未授權的數據抓取或爬蟲行為',
            ),
            
            _buildSection(
              '5. 合理使用',
              '在以下情況下，您可能被允許使用我們的內容：\n\n'
              '• 個人學習和研究目的\n'
              '• 教育用途（需事先獲得許可）\n'
              '• 新聞報導和評論（需註明出處）\n'
              '• 法律規定的其他合理使用情形\n\n'
              '具體使用前請聯繫我們獲得許可。',
            ),
            
            _buildSection(
              '6. 商標權',
              '以下商標和標識為我們所有：\n\n'
              '• 「想享」文字商標\n'
              '• 「XiangShare」英文商標\n'
              '• 應用圖標和視覺標識\n'
              '• 相關的標語和口號\n\n'
              '未經許可，不得使用我們的商標進行任何商業活動。',
            ),
            
            _buildSection(
              '7. 侵權舉報',
              '如果您發現版權侵權行為，請聯繫我們：\n\n'
              '• 提供侵權內容的詳細描述\n'
              '• 提供您的版權證明文件\n'
              '• 說明侵權行為的具體情況\n'
              '• 提供您的聯繫方式\n\n'
              '我們將在收到舉報後及時處理，並保護舉報者的隱私。',
            ),
            
            _buildSection(
              '8. 責任限制',
              '關於版權責任的說明：\n\n'
              '• 我們對用戶發布的內容不承擔版權責任\n'
              '• 用戶需自行承擔其內容的版權風險\n'
              '• 我們會配合版權執法部門的工作\n'
              '• 對於第三方網站鏈接的內容不承擔責任\n'
              '• 在收到有效通知後會及時移除侵權內容',
            ),
            
            _buildSection(
              '9. 法律適用',
              '本版權聲明適用於：\n\n'
              '• 中華民國著作權法\n'
              '• 相關的國際版權公約\n'
              '• 中華民國商標法\n'
              '• 其他適用的知識產權法律\n\n'
              '如有爭議，以中華民國法律為準。',
            ),
            
            _buildSection(
              '10. 聲明更新',
              '• 我們保留隨時更新本版權聲明的權利\n'
              '• 更新後的聲明將在應用內公布\n'
              '• 重大變更會通過適當方式通知用戶\n'
              '• 建議定期查看本聲明的最新版本',
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
                    '版權聯繫方式',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '版權相關問題請聯繫：\n\n'
                    '版權事務專員：copyright@xiangshare.com\n'
                    '法律事務部：legal@xiangshare.com\n'
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
                    '本版權聲明最後更新於：2024年12月15日',
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
