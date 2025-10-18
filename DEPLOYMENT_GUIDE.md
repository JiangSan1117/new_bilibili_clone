# 🚀 想享APP完整部署指南

## 📋 部署概覽

本指南將幫助您將想享APP從開發環境部署到生產環境，包括後端API和Flutter應用。

## 🏗️ 架構概覽

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Backend API   │    │   MongoDB       │
│   (Frontend)    │◄──►│   (Node.js)     │◄──►│   (Database)    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 部署選項

### 選項1：雲端部署（推薦）
- **Flutter Web**: Vercel / Netlify
- **後端API**: Railway / Heroku / DigitalOcean
- **數據庫**: MongoDB Atlas

### 選項2：VPS部署
- **服務器**: DigitalOcean / Linode / AWS EC2
- **所有服務**: 單一VPS

### 選項3：本地部署
- **開發環境**: 本地機器
- **測試用途**: 適合開發和測試

---

## 🌐 選項1：雲端部署（推薦）

### 1. 後端API部署 - Railway

#### 步驟1：準備後端項目
```bash
cd backend
npm install
```

#### 步驟2：設置環境變量
在Railway項目設置中添加：
```
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/xiangxiang
JWT_SECRET=your_super_secure_jwt_secret_here
JWT_EXPIRES_IN=7d
FRONTEND_URL=https://your-flutter-app.vercel.app
```

#### 步驟3：部署到Railway
```bash
# 安裝Railway CLI
npm install -g @railway/cli

# 登入Railway
railway login

# 初始化項目
railway init

# 部署
railway up
```

### 2. 數據庫部署 - MongoDB Atlas

#### 步驟1：創建MongoDB Atlas帳戶
1. 訪問 [MongoDB Atlas](https://www.mongodb.com/atlas)
2. 創建免費帳戶
3. 創建新集群

#### 步驟2：配置數據庫
1. 創建數據庫用戶
2. 設置網絡訪問（白名單）
3. 獲取連接字符串

#### 步驟3：連接配置
```javascript
// 連接字符串格式
mongodb+srv://username:password@cluster.mongodb.net/xiangxiang?retryWrites=true&w=majority
```

### 3. Flutter Web部署 - Vercel

#### 步驟1：構建Flutter Web
```bash
cd /path/to/flutter/project
flutter build web
```

#### 步驟2：更新API端點
```dart
// lib/services/real_api_service.dart
static const String baseUrl = 'https://your-backend.railway.app/api';
```

#### 步驟3：部署到Vercel
```bash
# 安裝Vercel CLI
npm install -g vercel

# 部署
vercel --prod
```

---

## 🖥️ 選項2：VPS部署

### 服務器要求
- **CPU**: 2核心
- **RAM**: 4GB
- **存儲**: 20GB SSD
- **操作系統**: Ubuntu 20.04+

### 1. 服務器設置

#### 步驟1：連接服務器
```bash
ssh root@your-server-ip
```

#### 步驟2：更新系統
```bash
apt update && apt upgrade -y
```

#### 步驟3：安裝Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
```

#### 步驟4：安裝MongoDB
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt-get update
apt-get install -y mongodb-org
systemctl start mongod
systemctl enable mongod
```

#### 步驟5：安裝Nginx
```bash
apt install nginx -y
systemctl start nginx
systemctl enable nginx
```

### 2. 部署後端API

#### 步驟1：上傳代碼
```bash
# 創建項目目錄
mkdir -p /var/www/xiangxiang-backend
cd /var/www/xiangxiang-backend

# 上傳代碼（使用scp或git）
git clone https://github.com/your-username/xiangxiang-backend.git .
```

#### 步驟2：安裝依賴
```bash
npm install --production
```

#### 步驟3：設置環境變量
```bash
nano .env
```
```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://localhost:27017/xiangxiang
JWT_SECRET=your_super_secure_jwt_secret_here
JWT_EXPIRES_IN=7d
FRONTEND_URL=https://your-domain.com
```

#### 步驟4：設置PM2
```bash
npm install -g pm2
pm2 start server.js --name "xiangxiang-api"
pm2 startup
pm2 save
```

### 3. 配置Nginx反向代理

#### 步驟1：創建Nginx配置
```bash
nano /etc/nginx/sites-available/xiangxiang
```
```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 後端API代理
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Flutter Web應用
    location / {
        root /var/www/xiangxiang-frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
```

#### 步驟2：啟用配置
```bash
ln -s /etc/nginx/sites-available/xiangxiang /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### 4. 部署Flutter Web

#### 步驟1：構建Flutter應用
```bash
cd /path/to/flutter/project
flutter build web
```

#### 步驟2：上傳到服務器
```bash
scp -r build/web/* root@your-server-ip:/var/www/xiangxiang-frontend/
```

#### 步驟3：設置文件權限
```bash
chown -R www-data:www-data /var/www/xiangxiang-frontend
chmod -R 755 /var/www/xiangxiang-frontend
```

---

## 🔒 SSL證書設置

### 使用Let's Encrypt
```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d your-domain.com
```

---

## 📱 移動應用部署

### Android APK構建
```bash
cd /path/to/flutter/project
flutter build apk --release
```

### iOS App Store部署
```bash
flutter build ios --release
# 使用Xcode上傳到App Store Connect
```

---

## 🔧 監控和維護

### 1. 設置監控
```bash
# 安裝監控工具
npm install -g pm2-logrotate
pm2 install pm2-server-monit
```

### 2. 日誌管理
```bash
# 查看API日誌
pm2 logs xiangxiang-api

# 查看Nginx日誌
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 3. 備份策略
```bash
# MongoDB備份腳本
#!/bin/bash
mongodump --db xiangxiang --out /backup/mongodb/$(date +%Y%m%d)
```

---

## 🚨 故障排除

### 常見問題

#### 1. 後端API無法啟動
```bash
# 檢查端口占用
netstat -tulpn | grep :3000

# 檢查PM2狀態
pm2 status
pm2 logs xiangxiang-api
```

#### 2. 數據庫連接失敗
```bash
# 檢查MongoDB狀態
systemctl status mongod

# 檢查連接
mongo --eval "db.adminCommand('ismaster')"
```

#### 3. Nginx配置錯誤
```bash
# 測試配置
nginx -t

# 重新加載配置
systemctl reload nginx
```

---

## 📊 性能優化

### 1. 數據庫優化
```javascript
// 添加索引
db.posts.createIndex({ "createdAt": -1 })
db.posts.createIndex({ "category": 1, "createdAt": -1 })
db.users.createIndex({ "email": 1 })
```

### 2. API緩存
```javascript
// 使用Redis緩存
const redis = require('redis');
const client = redis.createClient();
```

### 3. CDN設置
```bash
# 使用Cloudflare CDN
# 1. 註冊Cloudflare帳戶
# 2. 添加域名
# 3. 更新DNS設置
```

---

## 🔄 更新部署

### 1. 後端更新
```bash
cd /var/www/xiangxiang-backend
git pull origin main
npm install
pm2 restart xiangxiang-api
```

### 2. 前端更新
```bash
cd /path/to/flutter/project
flutter build web
scp -r build/web/* root@your-server-ip:/var/www/xiangxiang-frontend/
```

---

## 📞 技術支持

如果在部署過程中遇到問題，請檢查：

1. **日誌文件**: 查看應用和服務器日誌
2. **網絡連接**: 確保端口和防火牆設置正確
3. **環境變量**: 檢查所有必要的環境變量
4. **依賴版本**: 確保所有依賴版本兼容

---

## 🎉 部署完成檢查清單

- [ ] 後端API正常運行
- [ ] 數據庫連接成功
- [ ] Flutter Web應用可訪問
- [ ] SSL證書安裝
- [ ] 監控設置完成
- [ ] 備份策略實施
- [ ] 性能優化完成
- [ ] 安全設置檢查

恭喜！您的想享APP已成功部署到生產環境！🎊



