# MongoDB Atlas 設置指南

## 🗄️ 步驟1：創建MongoDB Atlas帳戶

1. 訪問 [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. 點擊 "Try Free" 創建免費帳戶
3. 填寫註冊信息並驗證郵箱

## 🏗️ 步驟2：創建集群

1. 選擇 "Build a Database"
2. 選擇 "FREE" 免費層
3. 選擇雲端提供商（AWS、Google Cloud、Azure）
4. 選擇地區（建議選擇離你最近的）
5. 集群名稱：`bilibili-cluster`
6. 點擊 "Create"

## 🔐 步驟3：設置數據庫用戶

1. 在 "Database Access" 頁面
2. 點擊 "Add New Database User"
3. 用戶名：`bilibili_user`
4. 密碼：生成強密碼並保存
5. 權限：選擇 "Read and write to any database"
6. 點擊 "Add User"

## 🌐 步驟4：設置網路訪問

1. 在 "Network Access" 頁面
2. 點擊 "Add IP Address"
3. 選擇 "Allow Access from Anywhere" (0.0.0.0/0)
4. 點擊 "Confirm"

## 🔗 步驟5：獲取連接字符串

1. 在 "Database" 頁面
2. 點擊 "Connect"
3. 選擇 "Connect your application"
4. 驅動程序：Node.js
5. 版本：4.1 or later
6. 複製連接字符串

連接字符串格式：
```
mongodb+srv://bilibili_user:<password>@bilibili-cluster.xxxxx.mongodb.net/bilibili_clone?retryWrites=true&w=majority
```

## 📝 步驟6：在Railway中設置環境變數

1. 在Railway項目設置中
2. 添加環境變數：
   - `MONGODB_URI`: 你的連接字符串
   - `JWT_SECRET`: 隨機生成的JWT密鑰
   - `FRONTEND_URL`: 你的前端URL

## ✅ 完成！

現在你的MongoDB Atlas數據庫已經準備好供生產環境使用！
