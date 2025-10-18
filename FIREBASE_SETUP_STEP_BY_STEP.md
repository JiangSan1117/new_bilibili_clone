# Firebase 設定詳細步驟

## 🚀 第一步：創建 Firebase 項目

### 1.1 前往 Firebase Console
1. 打開瀏覽器，前往：https://console.firebase.google.com/
2. 使用您的 Google 帳號登入

### 1.2 創建新項目
1. 點擊「創建項目」或「Add project」
2. 輸入項目名稱：`bilibili-clone-app`
3. 點擊「繼續」
4. 選擇是否啟用 Google Analytics（建議選擇「是」）
5. 選擇 Analytics 帳戶（或創建新帳戶）
6. 點擊「創建項目」

## 🔐 第二步：啟用 Authentication

### 2.1 進入 Authentication
1. 在 Firebase Console 左側選單中，點擊「Authentication」
2. 點擊「開始使用」或「Get started」

### 2.2 啟用電子郵件/密碼登入
1. 點擊「登入方法」標籤
2. 找到「電子郵件/密碼」選項
3. 點擊「電子郵件/密碼」
4. 切換「啟用」開關為開啟
5. 點擊「儲存」

## 📱 第三步：添加 Android 應用

### 3.1 添加 Android 應用
1. 在項目概覽頁面，點擊 Android 圖標（📱）
2. 輸入 Android 套件名稱：`com.example.bilibiliClone`
3. 輸入應用程式暱稱：`Bilibili Clone`
4. 輸入 SHA-1 憑證指紋（可選，用於 Google 登入）
5. 點擊「註冊應用程式」

### 3.2 下載配置文件
1. 下載 `google-services.json` 文件
2. 將文件放到 `android/app/` 目錄下
3. 點擊「下一步」

### 3.3 配置 build.gradle
1. 在 `android/build.gradle` 中添加：
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. 在 `android/app/build.gradle` 底部添加：
```gradle
apply plugin: 'com.google.gms.google-services'
```

## 🍎 第四步：添加 iOS 應用

### 4.1 添加 iOS 應用
1. 在項目概覽頁面，點擊 iOS 圖標（🍎）
2. 輸入 iOS 套件 ID：`com.example.bilibiliClone`
3. 輸入應用程式暱稱：`Bilibili Clone`
4. 點擊「註冊應用程式」

### 4.2 下載配置文件
1. 下載 `GoogleService-Info.plist` 文件
2. 將文件放到 `ios/Runner/` 目錄下
3. 點擊「下一步」

## 🔧 第五步：更新 Firebase 配置

### 5.1 獲取配置信息
在 Firebase Console 中，您會看到類似這樣的配置：

**Android 配置：**
```
apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
appId: "1:123456789:android:abcdef123456"
messagingSenderId: "123456789"
projectId: "your-project-id"
storageBucket: "your-project-id.appspot.com"
```

**iOS 配置：**
```
apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
appId: "1:123456789:ios:abcdef123456"
messagingSenderId: "123456789"
projectId: "your-project-id"
storageBucket: "your-project-id.appspot.com"
iosBundleId: "com.example.bilibiliClone"
```

### 5.2 更新 firebase_options.dart
將您的實際配置替換到 `lib/firebase_options.dart` 中

## 🎯 第六步：啟用 Google 登入（可選）

### 6.1 在 Firebase Console 中啟用
1. 在 Authentication > 登入方法中
2. 找到「Google」選項
3. 點擊「Google」
4. 切換「啟用」開關
5. 輸入專案支援電子郵件
6. 點擊「儲存」

### 6.2 獲取 SHA-1 憑證指紋（Android）
在終端機中執行：
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 📱 第七步：真實設備測試

### 7.1 連接 Android 設備
1. 啟用開發者選項
2. 啟用 USB 偵錯
3. 連接設備到電腦
4. 執行 `flutter devices` 確認設備連接

### 7.2 連接 iOS 設備
1. 使用 Xcode 打開 `ios/Runner.xcworkspace`
2. 選擇您的設備
3. 配置開發者帳號
4. 執行應用

### 7.3 測試功能
1. 測試註冊功能
2. 測試登入功能
3. 測試頭像上傳
4. 測試權限請求

## 🚨 常見問題解決

### 問題 1：權限被拒
**解決方案：**
1. 檢查設備設定 > 應用程式 > 權限
2. 手動授予相機和照片權限
3. 重新安裝應用

### 問題 2：Firebase 配置錯誤
**解決方案：**
1. 確認 `google-services.json` 和 `GoogleService-Info.plist` 文件正確放置
2. 檢查套件名稱是否一致
3. 重新執行 `flutter clean` 和 `flutter pub get`

### 問題 3：Google 登入失敗
**解決方案：**
1. 確認 SHA-1 憑證指紋正確
2. 檢查 Google 登入是否在 Firebase Console 中啟用
3. 確認 OAuth 客戶端配置正確

## 📋 檢查清單

- [ ] Firebase 項目已創建
- [ ] Authentication 已啟用
- [ ] Android 應用已添加
- [ ] iOS 應用已添加
- [ ] 配置文件已下載並放置
- [ ] build.gradle 已配置
- [ ] firebase_options.dart 已更新
- [ ] 真實設備已連接
- [ ] 應用已成功編譯
- [ ] 註冊功能已測試
- [ ] 登入功能已測試
- [ ] 頭像上傳已測試
- [ ] 權限請求已測試
