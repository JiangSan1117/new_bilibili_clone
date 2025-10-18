# 🚨 緊急修復：Firebase Console 設定

## 問題診斷
錯誤訊息：`[firebase_auth/operation-not-allowed] The given sign-in provider is disabled`

**這表示 Firebase Console 中沒有啟用電子郵件/密碼登入功能！**

## 🔧 立即修復步驟

### 1. 前往 Firebase Console
1. 打開瀏覽器，前往：https://console.firebase.google.com/
2. 選擇您的項目：`family-location-chat`

### 2. 啟用 Authentication
1. 在左側選單中，點擊「Authentication」
2. 如果看到「開始使用」，點擊它
3. 點擊「登入方法」標籤
4. 找到「電子郵件/密碼」選項
5. **重要**：點擊「電子郵件/密碼」
6. 切換「啟用」開關為**開啟**
7. 點擊「儲存」

### 3. 確認設定
- ✅ 電子郵件/密碼登入：已啟用
- ✅ 項目 ID：family-location-chat
- ✅ 應用已註冊

## 📱 測試步驟
1. 完成上述設定後
2. 重新運行應用
3. 嘗試註冊：`test@gmail.com` / `123456`
4. 應該可以成功註冊和登入

## ⚠️ 如果仍然無法使用
請檢查：
1. Firebase Console 中 Authentication 是否已啟用
2. 電子郵件/密碼登入是否已啟用
3. 網路連接是否正常
4. 應用是否已重新編譯
