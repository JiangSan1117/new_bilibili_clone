# Firebase Console 設定檢查清單

## 🔥 必須在 Firebase Console 中完成的設定

### 1. 啟用 Authentication
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 選擇您的項目：`family-location-chat`
3. 在左側選單中點擊「Authentication」
4. 點擊「開始使用」或「Get started」
5. 點擊「登入方法」標籤
6. 找到「電子郵件/密碼」選項
7. 點擊「電子郵件/密碼」
8. **重要**：切換「啟用」開關為**開啟**
9. 點擊「儲存」

### 2. 添加 Android 應用
1. 在項目概覽頁面，點擊 Android 圖標（📱）
2. 輸入 Android 套件名稱：`com.example.new_bilibili_clone`
3. 輸入應用程式暱稱：`Bilibili Clone`
4. 點擊「註冊應用程式」
5. 下載 `google-services.json` 文件
6. 將文件放到 `android/app/` 目錄下

### 3. 添加 iOS 應用
1. 在項目概覽頁面，點擊 iOS 圖標（🍎）
2. 輸入 iOS 套件 ID：`com.example.new_bilibili_clone`
3. 輸入應用程式暱稱：`Bilibili Clone`
4. 點擊「註冊應用程式」
5. 下載 `GoogleService-Info.plist` 文件
6. 將文件放到 `ios/Runner/` 目錄下

## 🚨 常見問題解決

### 問題 1：Authentication 未啟用
**症狀**：註冊或登入時出現 "Firebase Auth is not enabled" 錯誤
**解決方案**：
1. 前往 Firebase Console > Authentication
2. 確認「電子郵件/密碼」已啟用
3. 如果未啟用，請啟用它

### 問題 2：應用未註冊
**症狀**：出現 "App not found" 錯誤
**解決方案**：
1. 確認 Android 和 iOS 應用已在 Firebase Console 中註冊
2. 確認套件名稱/Bundle ID 正確
3. 重新下載配置文件

### 問題 3：網路連接問題
**症狀**：出現網路錯誤
**解決方案**：
1. 檢查網路連接
2. 確認 Firebase 項目設定正確
3. 檢查防火牆設定

## 📱 測試步驟

### 1. 檢查診斷信息
運行應用後，在登入頁面會顯示 Firebase 診斷信息：
- ✅ Firebase 初始化：正常
- ✅ Auth 可用：正常
- ✅ 項目 ID：family-location-chat
- ✅ Auth 域名：family-location-chat.firebaseapp.com

### 2. 測試註冊功能
1. 點擊「發布」按鈕
2. 選擇「註冊」
3. 輸入測試電子郵件：`test@example.com`
4. 輸入密碼：`123456`
5. 點擊「註冊」
6. 應該看到「註冊成功！」訊息

### 3. 測試登入功能
1. 使用剛才註冊的帳號登入
2. 輸入電子郵件和密碼
3. 點擊「登入」
4. 應該看到「登入成功！」訊息

## 🔧 如果仍然無法註冊/登入

### 檢查清單
- [ ] Firebase Console 中 Authentication 已啟用
- [ ] Android 應用已註冊
- [ ] iOS 應用已註冊
- [ ] 配置文件已下載並放置正確
- [ ] 網路連接正常
- [ ] 應用已重新編譯

### 重新編譯應用
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 檢查終端機錯誤訊息
運行應用時，注意終端機中的錯誤訊息，這會幫助診斷問題。
