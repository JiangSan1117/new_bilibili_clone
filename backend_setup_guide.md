# 🚀 想享APP後端實裝指南

## 📋 第一階段：後端基礎架構

### 🛠️ 技術棧選擇
- **後端框架**: Node.js + Express.js
- **數據庫**: MongoDB + Mongoose
- **認證**: JWT + bcrypt
- **文件存儲**: Multer + AWS S3 (或本地存儲)
- **API文檔**: Swagger
- **部署**: Heroku / Railway / Vercel

### 📁 項目結構
```
backend/
├── src/
│   ├── controllers/     # 控制器
│   ├── models/         # 數據模型
│   ├── routes/         # 路由定義
│   ├── middleware/     # 中間件
│   ├── services/       # 業務邏輯
│   ├── utils/          # 工具函數
│   └── config/         # 配置文件
├── uploads/            # 文件上傳目錄
├── package.json
├── .env               # 環境變量
└── server.js          # 入口文件
```

## 🔥 核心API端點設計

### 1. 用戶認證API
```
POST /api/auth/register     # 用戶註冊
POST /api/auth/login        # 用戶登入
POST /api/auth/logout       # 用戶登出
POST /api/auth/refresh      # 刷新Token
POST /api/auth/forgot-password  # 忘記密碼
POST /api/auth/reset-password   # 重置密碼
```

### 2. 用戶資料API
```
GET    /api/users/profile       # 獲取用戶資料
PUT    /api/users/profile       # 更新用戶資料
POST   /api/users/avatar        # 上傳頭像
GET    /api/users/:id           # 獲取其他用戶資料
```

### 3. 文章管理API
```
GET    /api/posts               # 獲取文章列表
POST   /api/posts               # 發布文章
GET    /api/posts/:id           # 獲取單篇文章
PUT    /api/posts/:id           # 編輯文章
DELETE /api/posts/:id           # 刪除文章
GET    /api/posts/category/:category  # 按分類獲取文章
GET    /api/posts/search        # 搜索文章
```

### 4. 互動功能API
```
POST   /api/posts/:id/like      # 點讚/取消點讚
POST   /api/posts/:id/comment   # 評論
GET    /api/posts/:id/comments  # 獲取評論列表
POST   /api/users/:id/follow    # 關注用戶
DELETE /api/users/:id/follow    # 取消關注
```

### 5. 訊息系統API
```
GET    /api/messages            # 獲取訊息列表
POST   /api/messages            # 發送訊息
GET    /api/messages/:id        # 獲取特定對話
PUT    /api/messages/:id/read   # 標記已讀
GET    /api/notifications       # 獲取通知列表
```

## 🗄️ 數據庫設計

### 用戶模型 (User)
```javascript
{
  _id: ObjectId,
  email: String,
  password: String (hashed),
  nickname: String,
  avatar: String,
  realName: String,
  idCardNumber: String (encrypted),
  verificationStatus: String,
  membershipType: String,
  levelNum: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### 文章模型 (Post)
```javascript
{
  _id: ObjectId,
  authorId: ObjectId (ref: User),
  title: String,
  content: String,
  category: String,
  mainTab: String,
  type: String,
  city: String,
  images: [String], // 圖片URLs
  videos: [String], // 視頻URLs
  likes: Number,
  views: Number,
  comments: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### 互動模型 (Interaction)
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  targetType: String, // 'post' or 'user'
  targetId: ObjectId,
  actionType: String, // 'like', 'comment', 'follow'
  content: String, // 評論內容
  createdAt: Date
}
```

## 🔐 安全性配置

### JWT配置
```javascript
// 生成Token
const token = jwt.sign(
  { userId: user._id, email: user.email },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);

// 驗證Token中間件
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};
```

### 數據驗證
```javascript
// 使用Joi進行輸入驗證
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  nickname: Joi.string().min(2).max(20).required(),
  realName: Joi.string().required(),
  idCardNumber: Joi.string().pattern(/^[A-Z][12]\d{8}$/).required()
});
```

## 📤 文件上傳配置

### Multer配置
```javascript
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB限制
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('只允許上傳圖片和視頻文件'));
    }
  }
});
```

## 🚀 部署配置

### 環境變量 (.env)
```
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://localhost:27017/xiangxiang
JWT_SECRET=your_super_secret_jwt_key
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_BUCKET_NAME=xiangxiang-uploads
FRONTEND_URL=http://localhost:3000
```

### Docker配置
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## 📱 Flutter端API集成

### HTTP客戶端配置
```dart
class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const String tokenKey = 'auth_token';
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString(tokenKey));
    
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }
}
```

## ⏱️ 開發時程

### 第一週：基礎架構
- [ ] 設置Node.js項目
- [ ] 配置MongoDB連接
- [ ] 建立基本路由結構
- [ ] 實裝JWT認證中間件

### 第二週：用戶認證
- [ ] 用戶註冊API
- [ ] 用戶登入API
- [ ] 密碼加密
- [ ] 實名制驗證邏輯

### 第三週：文章管理
- [ ] 文章CRUD API
- [ ] 文件上傳功能
- [ ] 搜索功能
- [ ] 分頁功能

### 第四週：互動功能
- [ ] 點讚功能
- [ ] 評論系統
- [ ] 關注功能
- [ ] 通知系統

### 第五週：Flutter集成
- [ ] 更新API服務
- [ ] 移除假資料
- [ ] 實裝真實數據
- [ ] 測試完整流程

## 🎯 下一步行動

1. **立即開始**：建立後端項目結構
2. **優先實裝**：用戶認證API
3. **逐步替換**：將Flutter中的假資料替換為真實API調用
4. **測試驗證**：確保前後端數據同步

您希望我現在開始幫您建立後端項目結構嗎？


