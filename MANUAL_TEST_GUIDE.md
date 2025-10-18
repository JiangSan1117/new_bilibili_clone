# 🔧 手動測試指南

## 🎯 **當前狀態**
- ✅ **後端API服務**: 正常運行在 http://localhost:3000
- ✅ **所有API端點**: 測試通過
- ✅ **Flutter應用**: 編譯成功，已集成API

## 📱 **測試步驟**

### **方法1: 使用瀏覽器測試**
1. 打開瀏覽器訪問: `http://localhost:3000/health`
2. 應該看到: `{"status":"OK","timestamp":"...","uptime":...}`
3. 這證明後端服務正常運行

### **方法2: 使用PowerShell測試API**
```powershell
# 運行快速測試
.\QUICK_API_TEST.ps1

# 或手動測試註冊
$data = '{"email":"test@example.com","password":"123456","nickname":"測試用戶","realName":"王小明","idCardNumber":"A123456789"}'
Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -ContentType "application/json" -Body $data
```

### **方法3: 啟動Flutter應用**
```bash
# 嘗試不同平台
flutter run -d chrome    # 瀏覽器版本
flutter run -d windows   # Windows桌面版
flutter run              # 自動選擇設備
```

## 🐛 **如果遇到問題**

### **問題1: Flutter應用無法啟動**
**解決方案**:
```bash
# 清理並重新啟動
flutter clean
flutter pub get
flutter run -d chrome
```

### **問題2: 註冊/登入失敗**
**可能原因**:
1. **網絡連接問題**: Flutter無法訪問localhost:3000
2. **CORS問題**: 瀏覽器阻擋跨域請求
3. **API地址錯誤**: 檢查API服務配置

**解決方案**:
1. **檢查API地址**: 確認 `lib/services/real_api_service.dart` 中的 `baseUrl` 設置正確
2. **檢查網絡**: 在Flutter應用中添加網絡調試信息
3. **使用瀏覽器測試**: 先在瀏覽器中測試API是否正常

### **問題3: Windows CMake錯誤**
**解決方案**:
```bash
# 使用瀏覽器版本避免Windows問題
flutter run -d chrome

# 或清理Windows構建緩存
Remove-Item -Recurse -Force build\windows -ErrorAction SilentlyContinue
flutter run -d windows
```

## 🔍 **調試技巧**

### **1. 檢查Flutter日誌**
啟動Flutter應用時，注意控制台輸出：
```
flutter run -d chrome --verbose
```

### **2. 檢查API調用**
在 `lib/services/real_api_service.dart` 中已添加調試信息：
- 註冊失敗時會顯示: `❌ 註冊失敗: [狀態碼] - [響應內容]`
- 登入失敗時會顯示: `❌ 登入失敗: [狀態碼] - [響應內容]`
- 網絡錯誤時會顯示: `❌ 註冊API錯誤: [錯誤信息]`

### **3. 檢查後端日誌**
在運行後端的終端中，應該看到：
```
POST /api/auth/register HTTP/1.1 201
POST /api/auth/login HTTP/1.1 200
```

## 📋 **測試檢查清單**

### **後端測試**
- [ ] 後端服務運行在 http://localhost:3000
- [ ] 健康檢查API返回正常
- [ ] 註冊API測試通過
- [ ] 登入API測試通過
- [ ] 用戶資料API測試通過

### **Flutter測試**
- [ ] Flutter應用成功啟動
- [ ] 能夠進入註冊頁面
- [ ] 註冊表單可以填寫
- [ ] 註冊API調用成功
- [ ] 登入功能正常
- [ ] 成功跳轉到主頁面

## 🎯 **成功標準**

當您能夠：
1. ✅ 在瀏覽器中看到Flutter應用界面
2. ✅ 成功填寫註冊表單
3. ✅ 看到「註冊成功」或「登入成功」訊息
4. ✅ 應用正常跳轉到主頁面
5. ✅ 後端日誌顯示API調用記錄

就表示Flutter與後端API的集成完全成功！🎉

## 💡 **下一步建議**

測試成功後，您可以：
1. **實裝文章功能** - 添加文章發布、搜索、列表
2. **添加互動功能** - 點讚、評論、關注
3. **設置真實數據庫** - 安裝MongoDB
4. **部署到雲端** - 使用Railway、Vercel等平台

---

## 🆘 **需要幫助？**

如果遇到任何問題，請提供：
1. 具體的錯誤訊息
2. Flutter控制台輸出
3. 後端服務日誌
4. 使用的測試步驟

我會幫助您解決問題！🚀



