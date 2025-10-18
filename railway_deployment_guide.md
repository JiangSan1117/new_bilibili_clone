# Railway 部署指南

## 🚀 步驟1：創建Railway帳戶

1. 訪問 [Railway](https://railway.app)
2. 點擊 "Login" 使用GitHub登入
3. 授權Railway訪問你的GitHub倉庫

## 📦 步驟2：部署項目

### 方法A：從GitHub倉庫部署（推薦）

1. 在Railway儀表板點擊 "New Project"
2. 選擇 "Deploy from GitHub repo"
3. 選擇你的 `new_bilibili_clone` 倉庫
4. Railway會自動檢測到Node.js項目

### 方法B：手動部署

1. 在Railway儀表板點擊 "New Project"
2. 選擇 "Empty Project"
3. 點擊 "Deploy from GitHub repo"
4. 選擇你的倉庫

## ⚙️ 步驟3：配置環境變數

在Railway項目設置中添加以下環境變數：

```bash
# 數據庫
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bilibili_clone

# JWT密鑰
JWT_SECRET=your-super-secret-jwt-key-here

# 前端URL
FRONTEND_URL=https://your-app.vercel.app

# 端口（Railway自動設置）
PORT=8080
```

## 🔧 步驟4：配置部署設置

1. 在項目設置中：
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Health Check Path**: `/api/health`

## 📊 步驟5：監控部署

1. 查看部署日誌
2. 檢查健康檢查狀態
3. 測試API端點

## 🌐 步驟6：獲取部署URL

部署完成後，Railway會提供：
- **後端API URL**: `https://your-app.railway.app`
- **健康檢查**: `https://your-app.railway.app/api/health`

## 🔄 步驟7：更新Flutter應用

更新 `lib/services/real_api_service.dart` 中的 `baseUrl`：

```dart
static const String baseUrl = 'https://your-app.railway.app/api';
```

## ✅ 完成！

你的後端現在已經部署到Railway並使用MongoDB Atlas數據庫！
