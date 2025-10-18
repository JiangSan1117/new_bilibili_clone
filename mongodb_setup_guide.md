# MongoDB Atlas 設置指南

## 1. 註冊MongoDB Atlas帳號

1. 前往 https://cloud.mongodb.com/
2. 點擊 "Try Free" 註冊免費帳號
3. 填寫註冊信息（姓名、郵箱、密碼）

## 2. 創建免費集群

1. 選擇 "Build a Database"
2. 選擇 "M0 Sandbox" (免費方案)
3. 選擇雲端提供商和地區（建議選擇離台灣最近的）
4. 集群名稱保持默認 "Cluster0"
5. 點擊 "Create Cluster"

## 3. 設置數據庫用戶

1. 創建數據庫用戶：
   - Username: `xiangxiang_user`
   - Password: `your_secure_password_here`
   - 點擊 "Create Database User"

## 4. 設置網絡訪問

1. 點擊 "Network Access"
2. 點擊 "Add IP Address"
3. 選擇 "Allow Access from Anywhere" (0.0.0.0/0) 用於開發
4. 點擊 "Confirm"

## 5. 獲取連接字符串

1. 點擊 "Connect"
2. 選擇 "Connect your application"
3. 選擇 Driver: "Node.js"
4. 複製連接字符串，格式如下：
   ```
   mongodb+srv://xiangxiang_user:<password>@cluster0.xxxxx.mongodb.net/xiangxiang?retryWrites=true&w=majority
   ```

## 6. 更新配置文件

將獲取的連接字符串更新到 `config.env` 文件中：

```
MONGODB_URI=mongodb+srv://xiangxiang_user:your_actual_password@cluster0.xxxxx.mongodb.net/xiangxiang?retryWrites=true&w=majority
JWT_SECRET=your-super-secret-jwt-key-here
PORT=8080
```

## 7. 測試連接

運行以下命令測試連接：
```bash
npm start
```

如果看到 "✅ MongoDB連接成功"，表示設置完成！

## 注意事項

- 免費方案有512MB存儲限制
- 連接數限制為100
- 適合開發和小型應用
- 生產環境建議升級到付費方案
