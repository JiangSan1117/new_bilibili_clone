# 想享 (XiangShare) - Bilibili 克隆應用

一個功能完整的社交分享應用，類似於 Bilibili 的社區功能，專注於內容分享、交換和共同創作。

## 🚀 主要功能

### 📱 核心功能
- **多標籤瀏覽**: 共享、共同、熱門、分享、交換
- **智能搜索**: 支持標題、用戶名、分類搜索
- **內容發布**: 支持圖片、影片上傳，多媒體內容發布
- **用戶認證**: Firebase 認證，支持電子郵件和 Google 登入
- **個人中心**: 用戶資料管理、統計數據展示

### 🎨 用戶界面
- **現代化設計**: Material Design 3 風格
- **響應式布局**: 適配不同屏幕尺寸
- **流暢動畫**: 平滑的頁面轉換和交互
- **主題支持**: 粉色主題配色方案

### 🔧 技術特性
- **狀態管理**: Provider 模式
- **數據持久化**: SharedPreferences 本地存儲
- **圖片處理**: 支持多種圖片格式
- **權限管理**: 相機、存儲權限處理
- **錯誤處理**: 完善的錯誤處理機制

## 📁 項目結構

```
lib/
├── components/          # 可重用組件
├── constants/          # 常量和配置
├── models/            # 數據模型
├── pages/             # 頁面組件
│   ├── tabs/          # 底部導航頁面
│   ├── subpages/      # 子頁面
│   └── ...
├── services/          # 業務邏輯服務
├── theme/            # 主題配置
├── utils/            # 工具函數
├── widgets/           # 自定義組件
└── main.dart         # 應用入口
```

## 🛠️ 技術棧

### 前端框架
- **Flutter**: 跨平台移動應用開發
- **Dart**: 編程語言

### 後端服務
- **Firebase**: 認證和數據存儲
- **Firebase Auth**: 用戶認證
- **Google Sign-In**: 第三方登入

### 依賴包
- `provider`: 狀態管理
- `cached_network_image`: 圖片緩存
- `image_picker`: 圖片選擇
- `video_player`: 影片播放
- `chewie`: 影片播放器
- `font_awesome_flutter`: 圖標庫
- `http`: 網絡請求
- `shared_preferences`: 本地存儲
- `intl`: 國際化
- `firebase_core`: Firebase 核心
- `firebase_auth`: Firebase 認證
- `google_sign_in`: Google 登入
- `permission_handler`: 權限管理
- `file_picker`: 文件選擇

## 🚀 快速開始

### 環境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Firebase 項目配置

### 安裝步驟

1. **克隆項目**
   ```bash
   git clone <repository-url>
   cd new_bilibili_clone
   ```

2. **安裝依賴**
   ```bash
   flutter pub get
   ```

3. **配置 Firebase**
   - 在 Firebase Console 創建項目
   - 下載 `google-services.json` (Android) 和 `GoogleService-Info.plist` (iOS)
   - 放置到對應平台目錄

4. **運行應用**
   ```bash
   flutter run
   ```

## 📱 功能詳解

### 首頁瀏覽
- **多標籤系統**: 共享、共同、熱門、分享、交換
- **分類過濾**: 飲食、穿著、居住、交通、教育、娛樂
- **熱門排序**: 按點閱數排序的熱門內容
- **內容卡片**: 圖片、標題、作者、統計數據

### 搜索功能
- **智能搜索**: 支持標題、用戶名、分類搜索
- **搜索歷史**: 自動保存搜索記錄
- **熱搜推薦**: 熱門搜索詞推薦
- **結果展示**: 搜索結果列表展示

### 內容發布
- **多媒體支持**: 圖片、影片上傳
- **分類標籤**: 交易類型和內容分類
- **地理位置**: 台灣縣市地區選擇
- **內容驗證**: 表單驗證和錯誤提示

### 用戶系統
- **多種登入**: 電子郵件、Google 登入
- **個人資料**: 頭像、暱稱、等級系統
- **統計數據**: 發布數、關注數、收藏數
- **設置管理**: 帳號安全、通知設置

## 🎯 未來規劃

### 短期目標
- [ ] 推送通知系統
- [ ] 內容分享功能
- [ ] 評論和點讚系統
- [ ] 用戶關注功能

### 長期目標
- [ ] 實時聊天功能
- [ ] 直播功能
- [ ] 支付系統
- [ ] 管理員後台

## 🤝 貢獻指南

1. Fork 項目
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 許可證

此項目採用 MIT 許可證 - 查看 [LICENSE](LICENSE) 文件了解詳情。

## 📞 聯繫方式

如有問題或建議，請通過以下方式聯繫：
- 項目 Issues
- 電子郵件: [your-email@example.com]

---

**想享** - 讓分享變得更有意義！ 🎉