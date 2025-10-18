// backend_server.js - 真實數據庫後端服務器

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;

// 中間件
app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:8080', 'http://127.0.0.1:8080'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));
app.use(express.json());

// MongoDB 連接 (使用 MongoDB Atlas 免費雲端數據庫)
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb+srv://demo:demo123@cluster0.mongodb.net/xiangshare?retryWrites=true&w=majority';

mongoose.connect(MONGODB_URI)
  .then(() => console.log('✅ MongoDB 連接成功'))
  .catch(err => console.error('❌ MongoDB 連接失敗:', err));

// 數據模型
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  nickname: { type: String, required: true },
  avatar: { type: String, default: '' },
  levelNum: { type: Number, default: 1 },
  isVerified: { type: Boolean, default: false },
  posts: { type: Number, default: 0 },
  collections: { type: Number, default: 0 },
  follows: { type: Number, default: 0 },
  friends: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

const postSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: String, required: true },
  authorId: { type: String, required: true },
  category: { type: String, required: true },
  mainTab: { type: String, required: true },
  images: [{ type: String }],
  videos: [{ type: String }],
  likes: { type: Number, default: 0 },
  comments: { type: Number, default: 0 },
  views: { type: Number, default: 0 },
  city: { type: String, default: '' },
  type: { type: String, default: '分享' },
  createdAt: { type: Date, default: Date.now }
});

const followSchema = new mongoose.Schema({
  followerId: { type: String, required: true },
  followingId: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const likeSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  postId: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const commentSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  postId: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const conversationSchema = new mongoose.Schema({
  participants: [{ type: String, required: true }],
  lastMessage: { type: String, default: '' },
  lastMessageTime: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now }
});

const messageSchema = new mongoose.Schema({
  conversationId: { type: String, required: true },
  senderId: { type: String, required: true },
  content: { type: String, required: true },
  senderName: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const notificationSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  type: { type: String, required: true }, // like, comment, follow, mention
  title: { type: String, required: true },
  content: { type: String, required: true },
  isRead: { type: Boolean, default: false },
  relatedUserId: { type: String },
  relatedPostId: { type: String },
  createdAt: { type: Date, default: Date.now }
});

// 創建模型
const User = mongoose.model('User', userSchema);
const Post = mongoose.model('Post', postSchema);
const Follow = mongoose.model('Follow', followSchema);
const Like = mongoose.model('Like', likeSchema);
const Comment = mongoose.model('Comment', commentSchema);
const Conversation = mongoose.model('Conversation', conversationSchema);
const Message = mongoose.model('Message', messageSchema);
const Notification = mongoose.model('Notification', notificationSchema);

// JWT 密鑰
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// 中間件：驗證 JWT Token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: '需要認證令牌' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: '無效的認證令牌' });
    }
    req.user = user;
    next();
  });
};

// 初始化測試數據
const initializeTestData = async () => {
  try {
    // 檢查是否已有數據
    const userCount = await User.countDocuments();
    if (userCount > 0) {
      console.log('📊 數據庫已有數據，跳過初始化');
      return;
    }

    console.log('🔄 開始初始化測試數據...');

    // 創建測試用戶
    const testUsers = [];
    for (let i = 1; i <= 10; i++) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      const user = new User({
        email: `test${i}@example.com`,
        password: hashedPassword,
        nickname: `測試用戶${i}`,
        avatar: `https://picsum.photos/seed/user${i}/100`,
        levelNum: Math.floor(Math.random() * 5) + 1,
        isVerified: Math.random() > 0.5,
        posts: Math.floor(Math.random() * 20),
        collections: Math.floor(Math.random() * 50),
        follows: Math.floor(Math.random() * 100),
        friends: Math.floor(Math.random() * 50)
      });
      testUsers.push(await user.save());
    }

    // 創建相互關注關係
    for (let i = 0; i < testUsers.length; i++) {
      for (let j = 0; j < testUsers.length; j++) {
        if (i !== j) {
          await new Follow({
            followerId: testUsers[i]._id.toString(),
            followingId: testUsers[j]._id.toString()
          }).save();
        }
      }
    }

    // 創建測試文章
    const samplePosts = [
      {
        title: '今天在市集找到的古董相機！',
        content: '今天在市集發現了一台古董相機，狀態非常好，和大家分享一下！',
        author: '測試用戶1',
        category: '電子產品',
        mainTab: '交換',
        images: ['https://picsum.photos/seed/camera1/400', 'https://picsum.photos/seed/camera2/400'],
        city: '臺北市',
        type: '二手'
      },
      {
        title: '試做米其林三星甜點，結果大成功！',
        content: '跟著YouTube教程做了米其林三星甜點，沒想到一次就成功了！',
        author: '測試用戶2',
        category: '飲食',
        mainTab: '分享',
        images: ['https://picsum.photos/seed/dessert1/400'],
        city: '高雄市',
        type: '美食'
      },
      {
        title: '分享我的極簡主義穿搭心得',
        content: '最近迷上了極簡主義穿搭，來和大家分享一些心得和技巧。',
        author: '測試用戶3',
        category: '穿著',
        mainTab: '共享',
        images: ['https://picsum.photos/seed/fashion1/400', 'https://picsum.photos/seed/fashion2/400'],
        city: '臺中市',
        type: '穿搭'
      }
    ];

    for (const postData of samplePosts) {
      const user = testUsers.find(u => u.nickname === postData.author);
      if (user) {
        const post = new Post({
          ...postData,
          authorId: user._id.toString(),
          likes: Math.floor(Math.random() * 500),
          comments: Math.floor(Math.random() * 50),
          views: Math.floor(Math.random() * 5000)
        });
        await post.save();
      }
    }

    console.log('✅ 測試數據初始化完成');
  } catch (error) {
    console.error('❌ 初始化測試數據失敗:', error);
  }
};

// API 路由

// 用戶註冊
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, nickname } = req.body;
    
    // 檢查用戶是否已存在
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: '用戶已存在' });
    }

    // 加密密碼
    const hashedPassword = await bcrypt.hash(password, 10);

    // 創建新用戶
    const user = new User({
      email,
      password: hashedPassword,
      nickname,
      avatar: `https://picsum.photos/seed/${nickname}/100`
    });

    await user.save();

    // 生成 JWT Token
    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: '註冊成功',
      token,
      user: {
        id: user._id.toString(),
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }
    });
  } catch (error) {
    console.error('註冊錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 用戶登入
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // 查找用戶
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: '用戶不存在' });
    }

    // 驗證密碼
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(400).json({ error: '密碼錯誤' });
    }

    // 生成 JWT Token
    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: '登入成功',
      token,
      user: {
        id: user._id.toString(),
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }
    });
  } catch (error) {
    console.error('登入錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶資料
app.get('/api/auth/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    // 計算統計數據
    const postsCount = await Post.countDocuments({ authorId: user._id.toString() });
    const followersCount = await Follow.countDocuments({ followingId: user._id.toString() });
    const followingCount = await Follow.countDocuments({ followerId: user._id.toString() });

    res.json({
      id: user._id.toString(),
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified,
      posts: postsCount,
      collections: user.collections,
      follows: followingCount,
      friends: followersCount
    });
  } catch (error) {
    console.error('獲取用戶資料錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取文章列表
app.get('/api/posts', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const category = req.query.category;
    const mainTab = req.query.mainTab;

    let query = {};
    if (category && category !== '全部') {
      query.category = category;
    }
    if (mainTab && mainTab !== '全部') {
      query.mainTab = mainTab;
    }

    const posts = await Post.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .exec();

    const total = await Post.countDocuments(query);

    res.json({
      posts: posts,
      total: total,
      page: page,
      limit: limit
    });
  } catch (error) {
    console.error('獲取文章列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 創建文章
app.post('/api/posts', authenticateToken, async (req, res) => {
  try {
    const { title, content, category, mainTab, images, videos, city, type } = req.body;
    
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    const post = new Post({
      title,
      content,
      author: user.nickname,
      authorId: user._id.toString(),
      category,
      mainTab,
      images: images || [],
      videos: videos || [],
      city: city || '',
      type: type || '分享'
    });

    await post.save();

    // 更新用戶文章數量
    await User.findByIdAndUpdate(req.user.userId, { $inc: { posts: 1 } });

    res.status(201).json({
      message: '文章發布成功',
      post: post
    });
  } catch (error) {
    console.error('創建文章錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 搜索文章
app.get('/api/posts/search', async (req, res) => {
  try {
    const { q: query, category, page = 1, limit = 20 } = req.query;

    let searchQuery = {};
    
    if (query) {
      searchQuery.$or = [
        { title: { $regex: query, $options: 'i' } },
        { content: { $regex: query, $options: 'i' } },
        { author: { $regex: query, $options: 'i' } }
      ];
    }

    if (category && category !== '全部') {
      searchQuery.category = category;
    }

    const posts = await Post.find(searchQuery)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .exec();

    const total = await Post.countDocuments(searchQuery);

    res.json({
      posts: posts,
      total: total,
      page: parseInt(page),
      limit: parseInt(limit)
    });
  } catch (error) {
    console.error('搜索文章錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 點讚/取消點讚
app.post('/api/interactions/posts/:postId/like', authenticateToken, async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.userId;

    const existingLike = await Like.findOne({ userId, postId });
    
    if (existingLike) {
      // 取消點讚
      await Like.findByIdAndDelete(existingLike._id);
      await Post.findByIdAndUpdate(postId, { $inc: { likes: -1 } });
      res.json({ message: '取消點讚成功', isLiked: false });
    } else {
      // 點讚
      await new Like({ userId, postId }).save();
      await Post.findByIdAndUpdate(postId, { $inc: { likes: 1 } });
      res.json({ message: '點讚成功', isLiked: true });
    }
  } catch (error) {
    console.error('點讚錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 評論文章
app.post('/api/interactions/posts/:postId/comment', authenticateToken, async (req, res) => {
  try {
    const { postId } = req.params;
    const { content } = req.body;
    const userId = req.user.userId;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    const comment = new Comment({
      userId,
      postId,
      content,
      author: user.nickname
    });

    await comment.save();
    await Post.findByIdAndUpdate(postId, { $inc: { comments: 1 } });

    res.status(201).json({
      message: '評論成功',
      comment: comment
    });
  } catch (error) {
    console.error('評論錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取文章評論
app.get('/api/interactions/posts/:postId/comments', async (req, res) => {
  try {
    const { postId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    const comments = await Comment.find({ postId })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .exec();

    res.json({
      comments: comments,
      page: page,
      limit: limit
    });
  } catch (error) {
    console.error('獲取評論錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 關注/取消關注用戶
app.post('/api/interactions/users/:targetUserId/follow', authenticateToken, async (req, res) => {
  try {
    const { targetUserId } = req.params;
    const followerId = req.user.userId;

    if (followerId === targetUserId) {
      return res.status(400).json({ error: '不能關注自己' });
    }

    const existingFollow = await Follow.findOne({ followerId, followingId: targetUserId });
    
    if (existingFollow) {
      // 取消關注
      await Follow.findByIdAndDelete(existingFollow._id);
      res.json({ message: '取消關注成功', isFollowing: false });
    } else {
      // 關注
      await new Follow({ followerId, followingId: targetUserId }).save();
      res.json({ message: '關注成功', isFollowing: true });
    }
  } catch (error) {
    console.error('關注錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶關注列表
app.get('/api/users/:userId/following', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const follows = await Follow.find({ followerId: userId });
    const followingIds = follows.map(f => f.followingId);
    
    const users = await User.find({ _id: { $in: followingIds } })
      .select('_id nickname avatar levelNum isVerified');

    res.json({
      users: users.map(user => ({
        id: user._id.toString(),
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }))
    });
  } catch (error) {
    console.error('獲取關注列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶粉絲列表
app.get('/api/users/:userId/followers', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const follows = await Follow.find({ followingId: userId });
    const followerIds = follows.map(f => f.followerId);
    
    const users = await User.find({ _id: { $in: followerIds } })
      .select('_id nickname avatar levelNum isVerified');

    res.json({
      users: users.map(user => ({
        id: user._id.toString(),
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }))
    });
  } catch (error) {
    console.error('獲取粉絲列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶資料
app.get('/api/users/:userId/profile', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    // 計算統計數據
    const postsCount = await Post.countDocuments({ authorId: userId });
    const followersCount = await Follow.countDocuments({ followingId: userId });
    const followingCount = await Follow.countDocuments({ followerId: userId });

    res.json({
      id: user._id.toString(),
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified,
      posts: postsCount,
      collections: user.collections,
      follows: followingCount,
      friends: followersCount
    });
  } catch (error) {
    console.error('獲取用戶資料錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取會話列表
app.get('/api/messages/conversations', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const conversations = await Conversation.find({
      participants: userId
    }).sort({ lastMessageTime: -1 });

    res.json({
      conversations: conversations
    });
  } catch (error) {
    console.error('獲取會話列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取會話消息
app.get('/api/messages/conversations/:conversationId/messages', authenticateToken, async (req, res) => {
  try {
    const { conversationId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;

    const messages = await Message.find({ conversationId })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .exec();

    res.json({
      messages: messages.reverse()
    });
  } catch (error) {
    console.error('獲取消息錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 發送消息
app.post('/api/messages/conversations/:conversationId/messages', authenticateToken, async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { content } = req.body;
    const senderId = req.user.userId;

    const user = await User.findById(senderId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    const message = new Message({
      conversationId,
      senderId,
      content,
      senderName: user.nickname
    });

    await message.save();

    // 更新會話的最後消息
    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: content,
      lastMessageTime: new Date()
    });

    res.status(201).json({
      message: '消息發送成功',
      data: message
    });
  } catch (error) {
    console.error('發送消息錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取通知列表
app.get('/api/notifications', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .exec();

    res.json({
      notifications: notifications
    });
  } catch (error) {
    console.error('獲取通知錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 標記通知為已讀
app.post('/api/notifications/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const { notificationId } = req.params;

    await Notification.findByIdAndUpdate(notificationId, { isRead: true });

    res.json({ message: '通知已標記為已讀' });
  } catch (error) {
    console.error('標記通知錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 後端服務器運行在 http://localhost:${PORT}`);
  console.log('📊 正在初始化數據庫...');
  
  // 延遲初始化測試數據，確保數據庫連接完成
  setTimeout(initializeTestData, 2000);
});

// 優雅關閉
process.on('SIGINT', () => {
  console.log('\n🛑 正在關閉服務器...');
  mongoose.connection.close(() => {
    console.log('📊 MongoDB 連接已關閉');
    process.exit(0);
  });
});
