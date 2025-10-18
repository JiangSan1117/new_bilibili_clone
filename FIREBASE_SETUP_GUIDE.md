# Firebase 設定指南

## 🔥 設定 Firebase 項目

### 1. 創建 Firebase 項目
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「創建項目」
3. 輸入項目名稱：`bilibili-clone`
4. 啟用 Google Analytics（可選）
5. 創建項目

### 2. 啟用 Authentication
1. 在 Firebase Console 中，點擊「Authentication」
2. 點擊「開始使用」
3. 在「登入方法」標籤中，啟用「電子郵件/密碼」
4. 點擊「電子郵件/密碼」→「啟用」→「儲存」

### 3. 添加 Android 應用
1. 在項目概覽中，點擊 Android 圖標
2. 輸入 Android 套件名稱：`com.example.bilibiliClone`
3. 輸入應用程式暱稱：`Bilibili Clone`
4. 下載 `google-services.json` 文件
5. 將文件放到 `android/app/` 目錄下

### 4. 添加 iOS 應用
1. 在項目概覽中，點擊 iOS 圖標
2. 輸入 iOS 套件 ID：`com.example.bilibiliClone`
3. 輸入應用程式暱稱：`Bilibili Clone`
4. 下載 `GoogleService-Info.plist` 文件
5. 將文件放到 `ios/Runner/` 目錄下

### 5. 更新 Firebase 配置
將 `lib/firebase_options.dart` 中的配置替換為您的實際配置：

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '您的-Android-API-Key',
  appId: '您的-Android-App-ID',
  messagingSenderId: '您的-Messaging-Sender-ID',
  projectId: '您的-Project-ID',
  storageBucket: '您的-Project-ID.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: '您的-iOS-API-Key',
  appId: '您的-iOS-App-ID',
  messagingSenderId: '您的-Messaging-Sender-ID',
  projectId: '您的-Project-ID',
  storageBucket: '您的-Project-ID.appspot.com',
  iosBundleId: 'com.example.bilibiliClone',
);
```

## 🔧 權限設定

### Android 權限
已在 `android/app/src/main/AndroidManifest.xml` 中添加：
- 相機權限
- 存儲權限
- 媒體權限（Android 13+）
- 網路權限

### iOS 權限
已在 `ios/Runner/Info.plist` 中添加：
- 相機使用說明
- 照片庫使用說明
- 照片添加使用說明

## 🚀 測試功能

### 1. 註冊功能
- 點擊「發布」按鈕
- 如果未登入，會跳轉到登入頁面
- 點擊「還沒有帳號？點此註冊」
- 輸入電子郵件和密碼
- 點擊「註冊」

### 2. 登入功能
- 在登入頁面輸入已註冊的電子郵件和密碼
- 點擊「登入」

### 3. 頭像上傳功能
- 登入後，進入「我的」頁面
- 點擊「編輯」按鈕
- 點擊頭像區域的相機圖標
- 選擇照片或拍照
- 點擊「保存變更」

## ⚠️ 注意事項

1. **Firebase 配置**：需要真實的 Firebase 項目配置才能使用認證功能
2. **權限設定**：已添加必要的權限，但需要在真實設備上測試
3. **模擬數據**：如果 Firebase 未配置，應用會使用模擬數據
4. **Google 登入**：目前暫時禁用，需要額外配置

## 🛠️ 故障排除

### 權限被拒
1. 檢查設備設定中的應用權限
2. 重新安裝應用
3. 在設定中手動授予權限

### Firebase 錯誤
1. 確認 `google-services.json` 和 `GoogleService-Info.plist` 文件正確放置
2. 檢查 Firebase 項目設定
3. 確認 Authentication 已啟用

### 編譯錯誤
1. 執行 `flutter clean`
2. 執行 `flutter pub get`
3. 重新編譯應用
