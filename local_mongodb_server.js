// local_mongodb_server.js - 本地MongoDB服務器（備用方案）

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 8080;

// CORS配置
app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:8080', 'http://127.0.0.1:8080', 'http://192.168.1.120:8080'],
  credentials: true
}));

app.use(express.json());

// 本地MongoDB連接（如果沒有安裝MongoDB，會使用內存數據庫）
let db;
try {
  // 嘗試連接本地MongoDB，設置超時避免阻塞
  mongoose.connect('mongodb://localhost:27017/xiangxiang', {
    serverSelectionTimeoutMS: 2000, // 2秒超時
    connectTimeoutMS: 2000,
  });
  db = mongoose.connection;
  db.on('error', (error) => {
    console.log('⚠️ 本地MongoDB連接失敗，切換到內存數據庫');
    db = null;
  });
  db.once('open', () => {
    console.log('✅ 本地MongoDB連接成功');
    db = mongoose.connection;
  });
} catch (error) {
  console.log('⚠️ 本地MongoDB不可用，使用內存數據庫');
  db = null;
}

// 設置超時，如果2秒內無法連接就使用內存數據庫
setTimeout(() => {
  if (!db || db.readyState !== 1) {
    console.log('⚠️ MongoDB連接超時，使用內存數據庫');
    db = null;
  }
}, 2000);

// 內存數據庫（如果MongoDB不可用）
const memoryDB = {
  users: [],
  posts: [],
  follows: [],
  comments: [],
  notifications: [],
  messages: []
};

// 數據模型定義
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

// 創建模型
const User = mongoose.model('User', userSchema);
const Post = mongoose.model('Post', postSchema);

// JWT密鑰
const JWT_SECRET = 'your-secret-key';

// 中間件：驗證JWT
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: '需要登入' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    let user;
    
    if (db) {
      user = await User.findById(decoded.userId);
    } else {
      user = memoryDB.users.find(u => u.id === decoded.userId);
    }
    
    if (!user) {
      return res.status(401).json({ error: '用戶不存在' });
    }
    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({ error: '無效的token' });
  }
};

// 用戶註冊
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, nickname } = req.body;
    
    if (db) {
      // 使用MongoDB
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({ error: '用戶已存在' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const user = new User({ email, password: hashedPassword, nickname });
      await user.save();

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
    } else {
      // 使用內存數據庫
      const existingUser = memoryDB.users.find(u => u.email === email);
      if (existingUser) {
        return res.status(400).json({ error: '用戶已存在' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const user = {
        id: Date.now().toString(),
        email,
        password: hashedPassword,
        nickname,
        avatar: '',
        levelNum: 1,
        isVerified: false,
        createdAt: new Date()
      };
      
      memoryDB.users.push(user);
      
      const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
      res.status(201).json({
        message: '註冊成功',
        token,
        user: {
          id: user.id,
          email: user.email,
          nickname: user.nickname,
          avatar: user.avatar,
          levelNum: user.levelNum,
          isVerified: user.isVerified
        }
      });
    }
  } catch (error) {
    console.error('註冊錯誤:', error);
    res.status(500).json({ error: '註冊失敗' });
  }
});

// 用戶登入
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (db) {
      // 使用MongoDB
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(400).json({ error: '用戶不存在' });
      }

      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        return res.status(400).json({ error: '密碼錯誤' });
      }

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
    } else {
      // 使用內存數據庫
      const user = memoryDB.users.find(u => u.email === email);
      if (!user) {
        return res.status(400).json({ error: '用戶不存在' });
      }

      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        return res.status(400).json({ error: '密碼錯誤' });
      }

      const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
      res.json({
        message: '登入成功',
        token,
        user: {
          id: user.id,
          email: user.email,
          nickname: user.nickname,
          avatar: user.avatar,
          levelNum: user.levelNum,
          isVerified: user.isVerified
        }
      });
    }
  } catch (error) {
    console.error('登入錯誤:', error);
    res.status(500).json({ error: '登入失敗' });
  }
});

// 獲取用戶資料
app.get('/api/auth/profile', authenticateToken, async (req, res) => {
  try {
    const user = req.user;
    
    if (db) {
      const postsCount = await Post.countDocuments({ author: user._id });
      res.json({
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified,
        posts: postsCount,
        followers: 0,
        following: 0,
        collections: 0,
        friends: 0
      });
    } else {
      const postsCount = memoryDB.posts.filter(p => p.author === user.id).length;
      res.json({
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified,
        posts: postsCount,
        followers: 0,
        following: 0,
        collections: 0,
        friends: 0
      });
    }
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

    if (db) {
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
    } else {
      // 使用內存數據庫
      const posts = memoryDB.posts
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
        .slice(skip, skip + limit);

      res.json({
        posts: posts.map(post => ({
          id: post.id,
          title: post.title,
          content: post.content,
          author: post.author,
          authorId: post.authorId,
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
        total: memoryDB.posts.length,
        page,
        limit
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
    const { title, content, category, mainTab, type, city, images, videos, tags } = req.body;

    if (db) {
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
    } else {
      // 使用內存數據庫
      const post = {
        id: Date.now().toString(),
        title,
        content,
        author: req.user.nickname,
        authorId: req.user.id,
        category,
        mainTab,
        type,
        city,
        images: images || [],
        videos: videos || [],
        likes: 0,
        comments: 0,
        views: 0,
        shares: 0,
        tags: tags || [],
        createdAt: new Date()
      };

      memoryDB.posts.push(post);

      res.status(201).json({
        message: '文章發布成功',
        post
      });
    }
  } catch (error) {
    console.error('創建文章錯誤:', error);
    res.status(500).json({ error: '創建文章失敗' });
  }
});

// 點讚/取消點讚
app.post('/api/interactions/posts/:postId/like', authenticateToken, async (req, res) => {
  try {
    const postId = req.params.postId;

    if (db) {
      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({ error: '文章不存在' });
      }
      post.likes += 1;
      await post.save();

      res.json({
        message: '點讚成功',
        isLiked: true,
        likeCount: post.likes
      });
    } else {
      const post = memoryDB.posts.find(p => p.id === postId);
      if (!post) {
        return res.status(404).json({ error: '文章不存在' });
      }
      post.likes += 1;

      res.json({
        message: '點讚成功',
        isLiked: true,
        likeCount: post.likes
      });
    }
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

    if (db) {
      const comment = new Comment({
        post: postId,
        author: req.user._id,
        content
      });

      await comment.save();
      await comment.populate('author', 'nickname avatar');

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
    } else {
      const comment = {
        id: Date.now().toString(),
        post: postId,
        author: req.user.id,
        content,
        username: req.user.nickname,
        userAvatar: req.user.avatar,
        createdAt: new Date()
      };

      memoryDB.comments.push(comment);

      const post = memoryDB.posts.find(p => p.id === postId);
      if (post) {
        post.comments += 1;
      }

      res.json({
        message: '評論成功',
        comment
      });
    }
  } catch (error) {
    console.error('評論錯誤:', error);
    res.status(500).json({ error: '評論失敗' });
  }
});

// 獲取文章評論
app.get('/api/interactions/posts/:postId/comments', async (req, res) => {
  try {
    const postId = req.params.postId;

    if (db) {
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
    } else {
      const comments = memoryDB.comments
        .filter(c => c.post === postId)
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

      res.json({
        success: true,
        comments: comments.map(comment => ({
          id: comment.id,
          content: comment.content,
          username: comment.username,
          userAvatar: comment.userAvatar,
          createdAt: comment.createdAt
        }))
      });
    }
  } catch (error) {
    console.error('獲取評論錯誤:', error);
    res.status(500).json({ error: '獲取評論失敗' });
  }
});

// 分享文章
app.post('/api/interactions/posts/:postId/share', async (req, res) => {
  try {
    const postId = req.params.postId;

    if (db) {
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
    } else {
      const post = memoryDB.posts.find(p => p.id === postId);
      if (!post) {
        return res.status(404).json({ error: '文章不存在' });
      }
      post.shares += 1;

      res.json({
        message: '分享成功',
        shareCount: post.shares,
        shareUrl: `https://xiangxiang.com/post/${postId}`
      });
    }
  } catch (error) {
    console.error('分享錯誤:', error);
    res.status(500).json({ error: '分享失敗' });
  }
});

// 搜索文章
app.get('/api/posts/search', async (req, res) => {
  try {
    const query = req.query.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (db) {
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
    } else {
      // 使用內存數據庫
      const posts = memoryDB.posts
        .filter(post => 
          post.title.toLowerCase().includes(query.toLowerCase()) ||
          post.content.toLowerCase().includes(query.toLowerCase()) ||
          post.category.toLowerCase().includes(query.toLowerCase())
        )
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
        .slice(skip, skip + limit);

      res.json({
        posts,
        total: posts.length,
        page,
        limit
      });
    }
  } catch (error) {
    console.error('搜索錯誤:', error);
    res.status(500).json({ error: '搜索失敗' });
  }
});

// 獲取通知
app.get('/api/notifications', authenticateToken, async (req, res) => {
  try {
    if (db) {
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
    } else {
      // 使用內存數據庫
      const notifications = memoryDB.notifications
        .filter(n => n.user === req.user.id)
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

      res.json({
        success: true,
        notifications: notifications.map(notification => ({
          id: notification.id,
          type: notification.type,
          title: notification.title,
          content: notification.content,
          isRead: notification.isRead,
          relatedUser: notification.relatedUser,
          relatedPost: notification.relatedPost,
          createdAt: notification.createdAt
        }))
      });
    }
  } catch (error) {
    console.error('獲取通知錯誤:', error);
    res.status(500).json({ error: '獲取通知失敗' });
  }
});

// 標記所有通知為已讀
app.post('/api/notifications/mark-all-read', authenticateToken, async (req, res) => {
  try {
    if (db) {
      await Notification.updateMany({ user: req.user._id }, { isRead: true });
    } else {
      memoryDB.notifications
        .filter(n => n.user === req.user.id)
        .forEach(n => n.isRead = true);
    }
    
    res.json({ message: '所有通知已標記為已讀', success: true });
  } catch (error) {
    console.error('標記所有通知錯誤:', error);
    res.status(500).json({ error: '標記所有通知失敗' });
  }
});

// 刪除所有通知
app.delete('/api/notifications/delete-all', authenticateToken, async (req, res) => {
  try {
    if (db) {
      await Notification.deleteMany({ user: req.user._id });
    } else {
      memoryDB.notifications = memoryDB.notifications.filter(n => n.user !== req.user.id);
    }
    
    res.json({ message: '所有通知已刪除', success: true });
  } catch (error) {
    console.error('刪除所有通知錯誤:', error);
    res.status(500).json({ error: '刪除所有通知失敗' });
  }
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 本地數據庫服務器運行在 http://0.0.0.0:${PORT}`);
  if (db) {
    console.log('📊 使用本地MongoDB數據庫');
  } else {
    console.log('📊 使用內存數據庫（重啟後數據會丟失）');
  }
});

module.exports = app;
