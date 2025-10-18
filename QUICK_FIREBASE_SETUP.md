# 🚀 快速 Firebase 設定指南

## 問題
您遇到的錯誤：`[firebase_auth/operation-not-allowed]` 表示 Firebase Console 中沒有啟用電子郵件/密碼登入功能。

## 🔧 解決步驟（5分鐘完成）

### 步驟 1：前往 Firebase Console
1. 打開瀏覽器
2. 前往：https://console.firebase.google.com/
3. 選擇項目：`family-location-chat`

### 步驟 2：啟用 Authentication
1. 左側選單 → 點擊「Authentication」
2. 點擊「開始使用」（如果看到的話）
3. 點擊「登入方法」標籤
4. 找到「電子郵件/密碼」
5. 點擊「電子郵件/密碼」
6. **切換「啟用」開關為開啟**
7. 點擊「儲存」

### 步驟 3：確認設定
您應該看到：
- ✅ 電子郵件/密碼：已啟用
- ✅ 項目 ID：family-location-chat

### 步驟 4：測試
1. 重新運行應用
2. 嘗試註冊：`test@gmail.com` / `123456`
3. 應該可以成功！

## 🎯 關鍵點
- **必須在 Firebase Console 中啟用電子郵件/密碼登入**
- 這是 Firebase 的安全設定，預設是關閉的
- 啟用後，您的應用就可以正常註冊和登入了

## 📞 如果還有問題
請確認：
1. 您有 Firebase Console 的訪問權限
2. 網路連接正常
3. 已按照上述步驟啟用 Authentication
