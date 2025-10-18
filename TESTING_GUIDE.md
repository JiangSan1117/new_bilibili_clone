# 🧪 想享APP後端API測試指南

## 🚀 服務器狀態
✅ **後端服務器已啟動**  
📍 **地址**: http://localhost:3000  
🔧 **模式**: 測試模式（模擬數據）  

---

## 📋 可用的API端點

### 1. 健康檢查
```
GET http://localhost:3000/health
```
**用途**: 檢查服務器是否正常運行

### 2. API文檔
```
GET http://localhost:3000/api/docs
```
**用途**: 查看所有可用的API端點

### 3. 用戶認證API
```
POST http://localhost:3000/api/auth/register  # 註冊
POST http://localhost:3000/api/auth/login     # 登入
POST http://localhost:3000/api/auth/logout    # 登出
GET  http://localhost:3000/api/auth/profile   # 獲取用戶資料
```

### 4. 其他API（開發中）
```
GET  http://localhost:3000/api/posts          # 獲取文章列表
POST http://localhost:3000/api/posts          # 發布文章
GET  http://localhost:3000/api/messages       # 獲取訊息
```

---

## 🧪 測試方法

### 方法1: 瀏覽器測試
直接在瀏覽器中訪問：
- ✅ http://localhost:3000/health
- ✅ http://localhost:3000/api/docs

### 方法2: 使用PowerShell測試
```powershell
# 健康檢查
Invoke-RestMethod -Uri "http://localhost:3000/health"

# API文檔
Invoke-RestMethod -Uri "http://localhost:3000/api/docs"
```

### 方法3: 使用curl測試
```bash
# 健康檢查
curl http://localhost:3000/health

# API文檔
curl http://localhost:3000/api/docs
```

### 方法4: 使用Postman
1. 打開Postman
2. 創建新的請求
3. 設置URL為 `http://localhost:3000/health`
4. 點擊Send

---

## 📱 測試用戶註冊和登入

### 註冊新用戶
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456",
    "nickname": "測試用戶",
    "realName": "王小明",
    "idCardNumber": "A123456789"
  }'
```

### 用戶登入
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }'
```

### 獲取用戶資料（需要Token）
```bash
curl -X GET http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🔍 常見問題解決

### Q: 看到 "API端點不存在" 錯誤
**A**: 這是正常的！請訪問 `/api/` 路徑下的端點，不要訪問根路徑 `/`

### Q: 如何獲取Token？
**A**: 先調用註冊或登入API，響應中會包含 `token` 字段

### Q: Token過期怎麼辦？
**A**: 重新調用登入API獲取新的Token

### Q: 如何查看完整的API響應？
**A**: 使用 `-v` 參數：
```bash
curl -v http://localhost:3000/health
```

---

## 🎯 下一步測試建議

1. **✅ 基礎測試**: 先測試健康檢查和API文檔
2. **✅ 認證測試**: 測試註冊、登入、獲取用戶資料
3. **🔄 功能測試**: 測試文章發布、搜索等功能（需要實裝）
4. **📱 Flutter集成**: 在Flutter應用中測試API調用

---

## 💡 提示

- 所有測試都在**模擬模式**下運行，數據不會持久化
- 服務器重啟後，之前的Token會失效
- 如需真實數據庫功能，需要安裝MongoDB



