# 🚀 想享APP後端API服務

## 📋 項目概述

這是想享APP的後端API服務，提供用戶認證、文章管理、互動功能等核心API。

## 🛠️ 技術棧

- **Node.js** - 運行環境
- **Express.js** - Web框架
- **MongoDB** - 數據庫
- **Mongoose** - ODM
- **JWT** - 認證
- **bcryptjs** - 密碼加密
- **Joi** - 數據驗證

## 📁 項目結構

```
backend/
├── src/
│   ├── controllers/     # 控制器
│   │   └── authController.js
│   ├── models/         # 數據模型
│   │   ├── User.js
│   │   ├── Post.js
│   │   └── Interaction.js
│   ├── routes/         # 路由定義
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── posts.js
│   │   ├── interactions.js
│   │   └── messages.js
│   ├── middleware/     # 中間件
│   │   └── auth.js
│   ├── services/       # 業務邏輯
│   ├── utils/          # 工具函數
│   │   └── validation.js
│   └── config/         # 配置文件
├── uploads/            # 文件上傳目錄
├── package.json
├── server.js           # 入口文件
└── README.md
```

## 🚀 快速開始

### 1. 安裝依賴

```bash
cd backend
npm install
```

### 2. 環境配置

複製環境變量模板：
```bash
cp env.example .env
```

編輯 `.env` 文件，配置必要的環境變量：
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/xiangxiang
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=7d
```

### 3. 啟動MongoDB

確保MongoDB服務正在運行：
```bash
# Windows
net start MongoDB

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

### 4. 啟動服務

```bash
# 開發模式
npm run dev

# 生產模式
npm start
```

服務將在 `http://localhost:3000` 啟動。

## 📚 API文檔

### 認證API

| 方法 | 端點 | 描述 | 認證 |
|------|------|------|------|
| POST | `/api/auth/register` | 用戶註冊 | ❌ |
| POST | `/api/auth/login` | 用戶登入 | ❌ |
| POST | `/api/auth/logout` | 用戶登出 | ✅ |
| GET | `/api/auth/profile` | 獲取用戶資料 | ✅ |
| POST | `/api/auth/refresh` | 刷新令牌 | ✅ |

### 用戶API

| 方法 | 端點 | 描述 | 認證 |
|------|------|------|------|
| PUT | `/api/users/profile` | 更新用戶資料 | ✅ |
| POST | `/api/users/avatar` | 上傳頭像 | ✅ |
| GET | `/api/users/:id` | 獲取其他用戶資料 | ✅ |

### 文章API

| 方法 | 端點 | 描述 | 認證 |
|------|------|------|------|
| GET | `/api/posts` | 獲取文章列表 | 可選 |
| POST | `/api/posts` | 發布文章 | ✅ |
| GET | `/api/posts/:id` | 獲取單篇文章 | 可選 |
| PUT | `/api/posts/:id` | 編輯文章 | ✅ |
| DELETE | `/api/posts/:id` | 刪除文章 | ✅ |
| GET | `/api/posts/search` | 搜索文章 | 可選 |

### 互動API

| 方法 | 端點 | 描述 | 認證 |
|------|------|------|------|
| POST | `/api/interactions/posts/:id/like` | 點讚文章 | ✅ |
| POST | `/api/interactions/posts/:id/comment` | 評論文章 | ✅ |
| GET | `/api/interactions/posts/:id/comments` | 獲取評論 | ❌ |
| POST | `/api/interactions/users/:id/follow` | 關注用戶 | ✅ |

### 訊息API

| 方法 | 端點 | 描述 | 認證 |
|------|------|------|------|
| GET | `/api/messages` | 獲取訊息列表 | ✅ |
| POST | `/api/messages` | 發送訊息 | ✅ |
| GET | `/api/messages/:id` | 獲取對話 | ✅ |

## 🔐 認證機制

API使用JWT（JSON Web Token）進行認證。

### 請求頭格式
```
Authorization: Bearer <your_jwt_token>
```

### 令牌格式
```json
{
  "userId": "user_id_here",
  "iat": 1234567890,
  "exp": 1234567890
}
```

## 📊 數據模型

### 用戶模型 (User)
```javascript
{
  email: String,
  password: String (hashed),
  nickname: String,
  avatar: String,
  realName: String,
  idCardNumber: String (encrypted),
  verificationStatus: String,
  membershipType: String,
  levelNum: Number,
  posts: Number,
  followers: Number,
  following: Number,
  likes: Number,
  phone: String,
  location: String,
  isActive: Boolean,
  lastLoginAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### 文章模型 (Post)
```javascript
{
  title: String,
  content: String,
  category: String,
  mainTab: String,
  type: String,
  city: String,
  images: [String],
  videos: [String],
  author: ObjectId,
  authorName: String,
  likes: Number,
  views: Number,
  comments: Number,
  shares: Number,
  status: String,
  isPinned: Boolean,
  tags: [String],
  location: {
    type: String,
    coordinates: [Number]
  },
  createdAt: Date,
  updatedAt: Date
}
```

## 🧪 測試API

### 註冊用戶
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

### 登入
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }'
```

### 獲取用戶資料
```bash
curl -X GET http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer <your_token>"
```

## 🔧 開發指南

### 添加新的API端點

1. 在 `src/models/` 中定義數據模型
2. 在 `src/controllers/` 中實現控制器邏輯
3. 在 `src/routes/` 中定義路由
4. 在 `src/utils/validation.js` 中添加驗證規則
5. 在 `server.js` 中註冊路由

### 數據驗證

使用Joi進行輸入驗證：
```javascript
const { validate } = require('../utils/validation');
const { mySchema } = require('../utils/validation');

router.post('/endpoint', validate(mySchema), controller);
```

### 錯誤處理

API返回統一的錯誤格式：
```json
{
  "error": "錯誤描述",
  "code": "ERROR_CODE",
  "details": ["詳細錯誤信息"]
}
```

## 🚀 部署

### 生產環境配置

1. 設置 `NODE_ENV=production`
2. 配置生產數據庫連接
3. 設置強密碼的JWT_SECRET
4. 配置CORS允許的前端域名
5. 設置文件上傳限制

### Docker部署

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## 📝 待開發功能

- [ ] 文章管理API完整實現
- [ ] 文件上傳功能
- [ ] 互動功能完整實現
- [ ] 訊息系統完整實現
- [ ] 推送通知
- [ ] 郵件服務
- [ ] 數據分析
- [ ] API文檔自動生成

## 🤝 貢獻指南

1. Fork 項目
2. 創建功能分支
3. 提交更改
4. 推送到分支
5. 創建 Pull Request

## 📄 許可證

MIT License



