// real_database_server.js - 真實數據庫服務器

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

// CORS配置
app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:8080', 'http://127.0.0.1:8080', 'http://192.168.1.120:8080'],
  credentials: true
}));

app.use(express.json());

// MongoDB連接
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb+srv://username:password@cluster.mongodb.net/xiangxiang?retryWrites=true&w=majority';

mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB連接成功'))
.catch(err => console.error('❌ MongoDB連接失敗:', err));

// 數據模型定義

// 用戶模型
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  nickname: { type: String, required: true },
  avatar: { type: String, default: '' },
  levelNum: { type: Number, default: 1 },
  isVerified: { type: Boolean, default: false },
  realName: { type: String, default: '' },
  idCardNumber: { type: String, default: '' },
  phone: { type: String, default: '' },
  location: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// 文章模型
const postSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  category: { type: String, required: true },
  mainTab: { type: String, required: true },
  type: { type: String, required: true },
  city: { type: String, required: true },
  images: [{ type: String }],
  videos: [{ type: String }],
  likes: { type: Number, default: 0 },
  comments: { type: Number, default: 0 },
  views: { type: Number, default: 0 },
  shares: { type: Number, default: 0 },
  tags: [{ type: String }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// 關注關係模型
const followSchema = new mongoose.Schema({
  follower: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  following: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  createdAt: { type: Date, default: Date.now }
});

// 評論模型
const commentSchema = new mongoose.Schema({
  post: { type: mongoose.Schema.Types.ObjectId, ref: 'Post', required: true },
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true },
  likes: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

// 通知模型
const notificationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, required: true }, // like, comment, follow, message
  title: { type: String, required: true },
  content: { type: String, required: true },
  isRead: { type: Boolean, default: false },
  relatedUser: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  relatedPost: { type: mongoose.Schema.Types.ObjectId, ref: 'Post' },
  createdAt: { type: Date, default: Date.now }
});

// 私訊模型
const messageSchema = new mongoose.Schema({
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

// 創建模型
const User = mongoose.model('User', userSchema);
const Post = mongoose.model('Post', postSchema);
const Follow = mongoose.model('Follow', followSchema);
const Comment = mongoose.model('Comment', commentSchema);
const Notification = mongoose.model('Notification', notificationSchema);
const Message = mongoose.model('Message', messageSchema);

// JWT密鑰
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// 中間件：驗證JWT
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: '需要登入' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(decoded.userId);
    if (!user) {
      return res.status(401).json({ error: '用戶不存在' });
    }
    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({ error: '無效的token' });
  }
};

// API路由

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

    // 創建用戶
    const user = new User({
      email,
      password: hashedPassword,
      nickname
    });

    await user.save();

    // 生成JWT
    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      message: '註冊成功',
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

    // 生成JWT
    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      message: '登入成功',
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
    const user = req.user;
    
    // 計算統計數據
    const postsCount = await Post.countDocuments({ author: user._id });
    const followersCount = await Follow.countDocuments({ following: user._id });
    const followingCount = await Follow.countDocuments({ follower: user._id });
    
    res.json({
      id: user._id,
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified,
      posts: postsCount,
      followers: followersCount,
      following: followingCount,
      collections: 0, // 暫時設為0，後續實現收藏功能
      friends: followersCount // 暫時用粉絲數代替
    });
  } catch (error) {
    console.error('獲取用戶資料錯誤:', error);
    res.status(500).json({ error: '獲取用戶資料失敗' });
  }
});

// 獲取文章列表
app.get('/api/posts', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const posts = await Post.find()
      .populate('author', 'nickname avatar')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments();

    res.json({
      posts: posts.map(post => ({
        id: post._id,
        title: post.title,
        content: post.content,
        author: post.author.nickname,
        authorId: post.author._id,
        category: post.category,
        mainTab: post.mainTab,
        type: post.type,
        city: post.city,
        images: post.images,
        videos: post.videos,
        likes: post.likes,
        comments: post.comments,
        views: post.views,
        shares: post.shares,
        tags: post.tags,
        createdAt: post.createdAt
      })),
      total,
      page,
      limit
    });
  } catch (error) {
    console.error('獲取文章列表錯誤:', error);
    res.status(500).json({ error: '獲取文章列表失敗' });
  }
});

// 創建文章
app.post('/api/posts', authenticateToken, async (req, res) => {
  try {
    const { title, content, category, mainTab, type, city, images, videos, tags } = req.body;

    const post = new Post({
      title,
      content,
      author: req.user._id,
      category,
      mainTab,
      type,
      city,
      images: images || [],
      videos: videos || [],
      tags: tags || []
    });

    await post.save();
    await post.populate('author', 'nickname avatar');

    res.status(201).json({
      message: '文章發布成功',
      post: {
        id: post._id,
        title: post.title,
        content: post.content,
        author: post.author.nickname,
        authorId: post.author._id,
        category: post.category,
        mainTab: post.mainTab,
        type: post.type,
        city: post.city,
        images: post.images,
        videos: post.videos,
        likes: post.likes,
        comments: post.comments,
        views: post.views,
        shares: post.shares,
        tags: post.tags,
        createdAt: post.createdAt
      }
    });
  } catch (error) {
    console.error('創建文章錯誤:', error);
    res.status(500).json({ error: '創建文章失敗' });
  }
});

// 點讚/取消點讚
app.post('/api/interactions/posts/:postId/like', authenticateToken, async (req, res) => {
  try {
    const postId = req.params.postId;
    const post = await Post.findById(postId);
    
    if (!post) {
      return res.status(404).json({ error: '文章不存在' });
    }

    // 簡單的點讚邏輯（實際應用中應該記錄用戶點讚狀態）
    post.likes += 1;
    await post.save();

    res.json({
      message: '點讚成功',
      isLiked: true,
      likeCount: post.likes
    });
  } catch (error) {
    console.error('點讚錯誤:', error);
    res.status(500).json({ error: '點讚失敗' });
  }
});

// 評論文章
app.post('/api/interactions/posts/:postId/comment', authenticateToken, async (req, res) => {
  try {
    const postId = req.params.postId;
    const { content } = req.body;

    const comment = new Comment({
      post: postId,
      author: req.user._id,
      content
    });

    await comment.save();
    await comment.populate('author', 'nickname avatar');

    // 更新文章評論數
    await Post.findByIdAndUpdate(postId, { $inc: { comments: 1 } });

    res.json({
      message: '評論成功',
      comment: {
        id: comment._id,
        content: comment.content,
        username: comment.author.nickname,
        userAvatar: comment.author.avatar,
        createdAt: comment.createdAt
      }
    });
  } catch (error) {
    console.error('評論錯誤:', error);
    res.status(500).json({ error: '評論失敗' });
  }
});

// 獲取文章評論
app.get('/api/interactions/posts/:postId/comments', async (req, res) => {
  try {
    const postId = req.params.postId;
    const comments = await Comment.find({ post: postId })
      .populate('author', 'nickname avatar')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      comments: comments.map(comment => ({
        id: comment._id,
        content: comment.content,
        username: comment.author.nickname,
        userAvatar: comment.author.avatar,
        createdAt: comment.createdAt
      }))
    });
  } catch (error) {
    console.error('獲取評論錯誤:', error);
    res.status(500).json({ error: '獲取評論失敗' });
  }
});

// 關注用戶
app.post('/api/interactions/users/:targetUserId/follow', authenticateToken, async (req, res) => {
  try {
    const targetUserId = req.params.targetUserId;
    const followerId = req.user._id;

    if (followerId.toString() === targetUserId) {
      return res.status(400).json({ error: '不能關注自己' });
    }

    // 檢查是否已經關注
    const existingFollow = await Follow.findOne({ follower: followerId, following: targetUserId });
    if (existingFollow) {
      return res.status(400).json({ error: '已經關注此用戶' });
    }

    const follow = new Follow({
      follower: followerId,
      following: targetUserId
    });

    await follow.save();

    res.json({
      message: '關注成功',
      isFollowing: true
    });
  } catch (error) {
    console.error('關注錯誤:', error);
    res.status(500).json({ error: '關注失敗' });
  }
});

// 獲取用戶關注列表
app.get('/api/users/:userId/following', async (req, res) => {
  try {
    const userId = req.params.userId;
    const following = await Follow.find({ follower: userId })
      .populate('following', 'nickname avatar levelNum isVerified');

    res.json({
      users: following.map(follow => ({
        id: follow.following._id,
        nickname: follow.following.nickname,
        avatar: follow.following.avatar,
        levelNum: follow.following.levelNum,
        isVerified: follow.following.isVerified
      }))
    });
  } catch (error) {
    console.error('獲取關注列表錯誤:', error);
    res.status(500).json({ error: '獲取關注列表失敗' });
  }
});

// 獲取用戶粉絲列表
app.get('/api/users/:userId/followers', async (req, res) => {
  try {
    const userId = req.params.userId;
    const followers = await Follow.find({ following: userId })
      .populate('follower', 'nickname avatar levelNum isVerified');

    res.json({
      users: followers.map(follow => ({
        id: follow.follower._id,
        nickname: follow.follower.nickname,
        avatar: follow.follower.avatar,
        levelNum: follow.follower.levelNum,
        isVerified: follow.follower.isVerified
      }))
    });
  } catch (error) {
    console.error('獲取粉絲列表錯誤:', error);
    res.status(500).json({ error: '獲取粉絲列表失敗' });
  }
});

// 搜索文章
app.get('/api/posts/search', async (req, res) => {
  try {
    const query = req.query.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const searchQuery = {
      $or: [
        { title: { $regex: query, $options: 'i' } },
        { content: { $regex: query, $options: 'i' } },
        { category: { $regex: query, $options: 'i' } }
      ]
    };

    const posts = await Post.find(searchQuery)
      .populate('author', 'nickname avatar')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments(searchQuery);

    res.json({
      posts: posts.map(post => ({
        id: post._id,
        title: post.title,
        content: post.content,
        author: post.author.nickname,
        authorId: post.author._id,
        category: post.category,
        mainTab: post.mainTab,
        type: post.type,
        city: post.city,
        images: post.images,
        videos: post.videos,
        likes: post.likes,
        comments: post.comments,
        views: post.views,
        shares: post.shares,
        tags: post.tags,
        createdAt: post.createdAt
      })),
      total,
      page,
      limit
    });
  } catch (error) {
    console.error('搜索錯誤:', error);
    res.status(500).json({ error: '搜索失敗' });
  }
});

// 分享文章
app.post('/api/interactions/posts/:postId/share', async (req, res) => {
  try {
    const postId = req.params.postId;
    const post = await Post.findById(postId);
    
    if (!post) {
      return res.status(404).json({ error: '文章不存在' });
    }

    post.shares += 1;
    await post.save();

    res.json({
      message: '分享成功',
      shareCount: post.shares,
      shareUrl: `https://xiangxiang.com/post/${postId}`
    });
  } catch (error) {
    console.error('分享錯誤:', error);
    res.status(500).json({ error: '分享失敗' });
  }
});

// 獲取通知
app.get('/api/notifications', authenticateToken, async (req, res) => {
  try {
    const notifications = await Notification.find({ user: req.user._id })
      .populate('relatedUser', 'nickname avatar')
      .populate('relatedPost', 'title')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      notifications: notifications.map(notification => ({
        id: notification._id,
        type: notification.type,
        title: notification.title,
        content: notification.content,
        isRead: notification.isRead,
        relatedUser: notification.relatedUser ? {
          nickname: notification.relatedUser.nickname,
          avatar: notification.relatedUser.avatar
        } : null,
        relatedPost: notification.relatedPost ? {
          title: notification.relatedPost.title
        } : null,
        createdAt: notification.createdAt
      }))
    });
  } catch (error) {
    console.error('獲取通知錯誤:', error);
    res.status(500).json({ error: '獲取通知失敗' });
  }
});

// 標記通知為已讀
app.post('/api/notifications/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const notificationId = req.params.notificationId;
    await Notification.findByIdAndUpdate(notificationId, { isRead: true });
    res.json({ message: '通知已標記為已讀' });
  } catch (error) {
    console.error('標記通知錯誤:', error);
    res.status(500).json({ error: '標記通知失敗' });
  }
});

// 標記所有通知為已讀
app.post('/api/notifications/mark-all-read', authenticateToken, async (req, res) => {
  try {
    await Notification.updateMany({ user: req.user._id }, { isRead: true });
    res.json({ message: '所有通知已標記為已讀', success: true });
  } catch (error) {
    console.error('標記所有通知錯誤:', error);
    res.status(500).json({ error: '標記所有通知失敗' });
  }
});

// 刪除所有通知
app.delete('/api/notifications/delete-all', authenticateToken, async (req, res) => {
  try {
    await Notification.deleteMany({ user: req.user._id });
    res.json({ message: '所有通知已刪除', success: true });
  } catch (error) {
    console.error('刪除所有通知錯誤:', error);
    res.status(500).json({ error: '刪除所有通知失敗' });
  }
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 真實數據庫服務器運行在 http://0.0.0.0:${PORT}`);
  console.log('📊 使用MongoDB Atlas真實數據庫');
});

module.exports = app;
