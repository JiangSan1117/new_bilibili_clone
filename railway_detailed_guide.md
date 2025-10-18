# 🚀 Railway 詳細部署指南

## 📱 方法1：使用Railway網頁界面（推薦）

### 步驟1：訪問Railway
1. 打開瀏覽器
2. 訪問：https://railway.app
3. 點擊右上角 **"Login"**

### 步驟2：GitHub登入
1. 選擇 **"Login with GitHub"**
2. 點擊 **"Authorize Railway"**
3. 等待重定向回Railway

### 步驟3：創建項目
1. 登入後，點擊 **"New Project"** 按鈕
2. 如果看到選項，選擇 **"Deploy from GitHub repo"**
3. 如果沒看到，點擊 **"Connect GitHub"** 或 **"Import from GitHub"**

### 步驟4：選擇倉庫
1. 在倉庫列表中尋找 `new_bilibili_clone`
2. 如果沒看到，點擊 **"Configure GitHub App"** 授權更多倉庫
3. 選擇 `new_bilibili_clone` 倉庫
4. 點擊 **"Deploy Now"**

### 步驟5：等待部署
1. Railway會自動檢測到Node.js項目
2. 等待構建完成（通常2-3分鐘）
3. 查看部署日誌

## 🖥️ 方法2：使用Railway CLI

### 步驟1：安裝CLI
```bash
npm install -g @railway/cli
```

### 步驟2：登入
```bash
railway login
```
- 會打開瀏覽器進行認證

### 步驟3：初始化項目
```bash
railway init
```

### 步驟4：部署
```bash
railway up
```

## 🔧 方法3：手動配置（如果自動檢測失敗）

### 步驟1：創建空項目
1. 在Railway點擊 **"New Project"**
2. 選擇 **"Empty Project"**

### 步驟2：連接GitHub
1. 在項目設置中點擊 **"Connect GitHub"**
2. 選擇 `new_bilibili_clone` 倉庫

### 步驟3：配置構建
1. 在項目設置中：
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Health Check Path**: `/api/health`

## ⚙️ 環境變數設置

### 在Railway項目設置中添加：

1. 點擊項目名稱
2. 選擇 **"Variables"** 標籤
3. 添加以下環境變數：

```bash
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bilibili_clone
JWT_SECRET=your-super-secret-jwt-key-here
FRONTEND_URL=https://your-app.vercel.app
NODE_ENV=production
```

## 🔍 常見問題解決

### 問題1：找不到 "Deploy from GitHub repo"
**解決方案：**
- 嘗試點擊 **"Connect GitHub"**
- 或使用 **"Import from GitHub"**
- 或直接訪問：https://railway.app/new

### 問題2：倉庫列表為空
**解決方案：**
1. 確保GitHub倉庫是公開的
2. 或點擊 **"Configure GitHub App"** 授權更多倉庫
3. 重新整理頁面

### 問題3：部署失敗
**解決方案：**
1. 檢查 `package.json` 中的 `start` 腳本
2. 確保所有依賴都在 `dependencies` 中
3. 查看部署日誌找出錯誤

## 📊 部署成功後

### 獲取部署URL
1. 部署完成後，Railway會提供一個URL
2. 格式：`https://your-app-name.railway.app`
3. 健康檢查：`https://your-app-name.railway.app/api/health`

### 測試API
```bash
curl https://your-app-name.railway.app/api/health
```

## ✅ 完成！

部署成功後，你的後端API就上線了！
