// production_server.js - 生產環境後端服務器
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

// 載入環境變數
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// 內存數據庫（備用）
const memoryDB = {
  users: [
    {
      _id: 'test_user_1',
      email: 'test@example.com',
      password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password: "password"
      nickname: '測試用戶1',
      avatar: 'https://picsum.photos/seed/test1/100',
      levelNum: 1,
      isVerified: false,
      posts: 0,
      follows: 0,
      friends: 0,
      createdAt: new Date()
    }
  ],
  posts: [
    {
      _id: 'post_1',
      title: '測試文章1',
      content: '這是測試文章內容',
      author: '測試用戶1',
      authorId: 'test_user_1',
      category: '測試',
      mainTab: '分享',
      type: '分享',
      city: '台北市',
      tags: [],
      images: ['https://picsum.photos/seed/test1/400'],
      videos: [],
      likes: 11,
      comments: 7,
      views: 100,
      shares: 8,
      createdAt: new Date()
    },
    {
      _id: 'post_2',
      title: '測試文章2',
      content: '這是另一篇測試文章',
      author: '測試用戶1',
      authorId: 'test_user_1',
      category: '測試',
      mainTab: '共享',
      type: '共享',
      city: '高雄市',
      tags: [],
      images: ['https://picsum.photos/seed/test2/400'],
      videos: [],
      likes: 5,
      comments: 1,
      views: 50,
      shares: 0,
      createdAt: new Date()
    }
  ],
  follows: [],
  messages: [],
  notifications: []
};

// 中間件 - CORS 配置
const allowedOrigins = [
  'https://merry-kulfi-eb044d.netlify.app',
  'http://localhost:3000',
  'http://localhost:8080',
  process.env.FRONTEND_URL
].filter(Boolean); // 過濾掉 undefined

app.use(cors({
  origin: function(origin, callback) {
    // 允許沒有 origin 的請求（如 Postman、curl）
    if (!origin) return callback(null, true);
    
    // 允許所有 netlify.app 域名和白名單域名
    if (origin.includes('netlify.app') || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 健康檢查端點
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    database: isMongoConnected() ? 'MongoDB Atlas' : 'Memory Database'
  });
});

// 連接MongoDB Atlas
const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI;
    
    if (!mongoURI) {
      console.log('⚠️ MONGODB_URI 環境變數未設置，使用內存數據庫');
      return;
    }
    
    console.log('🔗 正在連接 MongoDB Atlas...');
    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 30000,
      connectTimeoutMS: 30000,
      socketTimeoutMS: 30000,
    });
    console.log('🗄️ MongoDB Atlas 連接成功');
  } catch (error) {
    console.error('❌ MongoDB 連接失敗:', error.message);
    console.error('詳細錯誤:', error);
    console.log('⚠️ 使用內存數據庫作為備用');
  }
};

// 用戶模型
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  nickname: { type: String, required: true },
  avatar: { type: String, default: 'https://picsum.photos/seed/default/100' },
  levelNum: { type: Number, default: 1 },
  isVerified: { type: Boolean, default: false },
  posts: { type: Number, default: 0 },
  follows: { type: Number, default: 0 },
  friends: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

// 文章模型
const postSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: String, required: true },
  authorId: { type: String, required: true },
  category: { type: String, required: true },
  mainTab: { type: String, required: true },
  type: { type: String, required: true },
  city: { type: String, required: true },
  tags: [String],
  images: [String],
  videos: [String],
  likes: { type: Number, default: 0 },
  comments: { type: Number, default: 0 },
  views: { type: Number, default: 0 },
  shares: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

const Post = mongoose.model('Post', postSchema);

// 關注模型
const followSchema = new mongoose.Schema({
  follower: { type: String, required: true },
  following: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const Follow = mongoose.model('Follow', followSchema);

// 訊息模型
const messageSchema = new mongoose.Schema({
  sender: { type: String, required: true },
  receiver: { type: String, required: true },
  content: { type: String, required: true },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

const Message = mongoose.model('Message', messageSchema);

// 通知模型
const notificationSchema = new mongoose.Schema({
  user: { type: String, required: true },
  type: { type: String, required: true },
  title: { type: String, required: true },
  content: { type: String, required: true },
  isRead: { type: Boolean, default: false },
  relatedUser: {
    nickname: String,
    avatar: String
  },
  createdAt: { type: Date, default: Date.now }
});

const Notification = mongoose.model('Notification', notificationSchema);

// 檢查數據庫連接狀態
const isMongoConnected = () => {
  return mongoose.connection.readyState === 1;
};

// JWT認證中間件
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: '需要認證令牌' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: '無效的令牌' });
    }
    req.user = user;
    next();
  });
};

// ===== 認證API =====

// 用戶註冊
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, nickname } = req.body;

    if (!email || !password || !nickname) {
      return res.status(400).json({ error: '請填寫所有必填欄位' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: '用戶已存在' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      email,
      password: hashedPassword,
      nickname
    });

    await user.save();

    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }
    });
  } catch (error) {
    console.error('註冊錯誤:', error);
    res.status(500).json({ error: '註冊失敗' });
  }
});

// 用戶登入
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: '用戶不存在' });
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(400).json({ error: '密碼錯誤' });
    }

    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }
    });
  } catch (error) {
    console.error('登入錯誤:', error);
    res.status(500).json({ error: '登入失敗' });
  }
});

// 獲取用戶資料
app.get('/api/auth/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    // 計算統計數據
    const postsCount = await Post.countDocuments({ authorId: user._id });
    const followsCount = await Follow.countDocuments({ follower: user._id });
    const friendsCount = await Follow.countDocuments({ follower: user._id });

    res.json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified,
        posts: postsCount,
        follows: followsCount,
        friends: friendsCount
      }
    });
  } catch (error) {
    console.error('獲取用戶資料錯誤:', error);
    res.status(500).json({ error: '獲取用戶資料失敗' });
  }
});

// ===== 文章API =====

// 獲取文章列表
app.get('/api/posts', async (req, res) => {
  try {
    const { page = 1, limit = 20, mainTab, category } = req.query;
    const skip = (page - 1) * limit;

    if (isMongoConnected()) {
      // 使用 MongoDB
      let query = {};
      if (mainTab) query.mainTab = mainTab;
      if (category) query.category = category;

      const posts = await Post.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

      const total = await Post.countDocuments(query);

      res.json({
        success: true,
        posts,
        total,
        page: parseInt(page),
        limit: parseInt(limit)
      });
    } else {
      // 使用內存數據庫
      let filteredPosts = memoryDB.posts;
      
      if (mainTab) {
        filteredPosts = filteredPosts.filter(post => post.mainTab === mainTab);
      }
      if (category) {
        filteredPosts = filteredPosts.filter(post => post.category === category);
      }

      const total = filteredPosts.length;
      const posts = filteredPosts
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
        .slice(skip, skip + parseInt(limit));

      res.json({
        success: true,
        posts,
        total,
        page: parseInt(page),
        limit: parseInt(limit)
      });
    }
  } catch (error) {
    console.error('獲取文章列表錯誤:', error);
    res.status(500).json({ error: '獲取文章列表失敗' });
  }
});

// 創建文章
app.post('/api/posts', authenticateToken, async (req, res) => {
  try {
    const { title, content, category, mainTab, type, city, images, videos } = req.body;

    const post = new Post({
      title,
      content,
      author: req.user.nickname,
      authorId: req.user.id,
      category,
      mainTab,
      type,
      city,
      images: images || [],
      videos: videos || []
    });

    await post.save();

    res.json({
      success: true,
      post
    });
  } catch (error) {
    console.error('創建文章錯誤:', error);
    res.status(500).json({ error: '創建文章失敗' });
  }
});

// ===== 搜索API =====

// 搜索文章
app.get('/api/search/posts', async (req, res) => {
  try {
    const { q: query, category, page = 1, limit = 20 } = req.query;

    if (!query || query.trim().isEmpty) {
      return res.status(400).json({ error: '搜索關鍵字不能為空' });
    }

    const searchQuery = query.trim();
    let filter = {
      $or: [
        { title: { $regex: searchQuery, $options: 'i' } },
        { content: { $regex: searchQuery, $options: 'i' } },
        { author: { $regex: searchQuery, $options: 'i' } },
        { category: { $regex: searchQuery, $options: 'i' } },
        { city: { $regex: searchQuery, $options: 'i' } }
      ]
    };

    if (category && category !== 'all') {
      filter.category = category;
    }

    const posts = await Post.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await Post.countDocuments(filter);

    res.json({
      success: true,
      posts,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      query: searchQuery
    });
  } catch (error) {
    console.error('搜索文章錯誤:', error);
    res.status(500).json({ error: '搜索失敗' });
  }
});

// 獲取熱門搜索關鍵字
app.get('/api/search/trending', async (req, res) => {
  try {
    const trendingKeywords = [
      '美食推薦',
      '旅遊景點',
      '二手相機',
      '健身運動',
      '手作工藝',
      '科技產品',
      '書籍交換',
      '寵物用品',
      '服裝搭配',
      '家居佈置'
    ];

    res.json({
      success: true,
      keywords: trendingKeywords
    });
  } catch (error) {
    console.error('獲取熱門搜索錯誤:', error);
    res.status(500).json({ error: '獲取熱門搜索失敗' });
  }
});

// 啟動服務器
const startServer = async () => {
  await connectDB();
  
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 生產環境服務器運行在端口 ${PORT}`);
    console.log(`🌐 健康檢查: http://localhost:${PORT}/api/health`);
    console.log(`📊 使用MongoDB Atlas數據庫`);
  });
};

startServer().catch(console.error);
