// simple_backend_server.js - 簡化後端服務器，使用模擬數據

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 8080;

// 中間件
app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:8080', 'http://127.0.0.1:8080'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));
app.use(express.json());

// JWT 密鑰
const JWT_SECRET = 'your-super-secret-jwt-key-2024';

// 模擬數據存儲
let users = [];
let posts = [];
let follows = [];
let likes = [];
let comments = [];
let conversations = [];
let messages = [];
let notifications = [];

// 初始化測試數據
const initializeTestData = () => {
  console.log('🔄 初始化測試數據...');
  
  // 創建測試用戶
  for (let i = 1; i <= 10; i++) {
    const hashedPassword = bcrypt.hashSync('123456', 10);
    users.push({
      id: `test_user_${i}`,
      email: `test${i}@example.com`,
      password: hashedPassword,
      nickname: `測試用戶${i}`,
      avatar: `https://picsum.photos/seed/user${i}/100`,
      levelNum: Math.floor(Math.random() * 5) + 1,
      isVerified: Math.random() > 0.5,
      posts: Math.floor(Math.random() * 20),
      collections: Math.floor(Math.random() * 50),
      follows: Math.floor(Math.random() * 100),
      friends: Math.floor(Math.random() * 50),
      createdAt: new Date()
    });
  }

  // 創建相互關注關係
  for (let i = 1; i <= 10; i++) {
    for (let j = 1; j <= 10; j++) {
      if (i !== j) {
        follows.push({
          id: `follow_${i}_${j}`,
          followerId: `test_user_${i}`,
          followingId: `test_user_${j}`,
          createdAt: new Date()
        });
      }
    }
  }

  // 創建測試文章
  const samplePosts = [
    {
      id: 'post_1',
      title: '分享一個很棒的美食推薦',
      content: '今天發現了一家很棒的餐廳，推薦給大家...',
      author: '測試用戶1',
      authorId: 'test_user_1',
      category: '飲食',
      mainTab: '分享',
      images: ['https://picsum.photos/seed/food1/400'],
      videos: [],
      city: '台北市',
      type: '分享',
      likes: 25,
      comments: 8,
      views: 150,
      createdAt: new Date()
    },
    {
      id: 'post_2',
      title: '台北旅遊景點分享',
      content: '周末去了台北幾個景點，風景很美...',
      author: '測試用戶1',
      authorId: 'test_user_1',
      category: '娛樂',
      mainTab: '共享',
      images: ['https://picsum.photos/seed/travel1/400'],
      videos: [],
      city: '台北市',
      type: '共享',
      likes: 18,
      comments: 5,
      views: 200,
      createdAt: new Date()
    },
    {
      id: 'post_3',
      title: '推薦好用的手機App',
      content: '最近發現幾個很實用的App，分享給大家...',
      author: '測試用戶1',
      authorId: 'test_user_1',
      category: '教育',
      mainTab: '分享',
      images: ['https://picsum.photos/seed/app1/400'],
      videos: [],
      city: '新北市',
      type: '分享',
      likes: 32,
      comments: 12,
      views: 300,
      createdAt: new Date()
    }
  ];

  posts = samplePosts;
  console.log('✅ 測試數據初始化完成');
};

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

// API 路由

// 用戶登入
app.post('/api/auth/login', (req, res) => {
  try {
    const { email, password } = req.body;

    // 查找用戶
    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(400).json({ error: '用戶不存在' });
    }

    // 驗證密碼
    const isValidPassword = bcrypt.compareSync(password, user.password);
    if (!isValidPassword) {
      return res.status(400).json({ error: '密碼錯誤' });
    }

    // 生成 JWT Token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

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
  } catch (error) {
    console.error('登入錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶資料
app.get('/api/auth/profile', authenticateToken, (req, res) => {
  try {
    const user = users.find(u => u.id === req.user.userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    // 計算統計數據
    const postsCount = posts.filter(p => p.authorId === user.id).length;
    const followersCount = follows.filter(f => f.followingId === user.id).length;
    const followingCount = follows.filter(f => f.followerId === user.id).length;

    res.json({
      id: user.id,
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
app.get('/api/posts', (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const category = req.query.category;
    const mainTab = req.query.mainTab;

    let filteredPosts = [...posts];
    
    if (category && category !== '全部') {
      filteredPosts = filteredPosts.filter(p => p.category === category);
    }
    if (mainTab && mainTab !== '全部') {
      filteredPosts = filteredPosts.filter(p => p.mainTab === mainTab);
    }

    // 分頁
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedPosts = filteredPosts.slice(startIndex, endIndex);

    res.json({
      posts: paginatedPosts,
      total: filteredPosts.length,
      page: page,
      limit: limit
    });
  } catch (error) {
    console.error('獲取文章列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 創建文章
app.post('/api/posts', authenticateToken, (req, res) => {
  try {
    const { title, content, category, mainTab, images, videos, city, type } = req.body;
    
    const user = users.find(u => u.id === req.user.userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    const newPost = {
      id: `post_${Date.now()}`,
      title,
      content,
      author: user.nickname,
      authorId: user.id,
      category,
      mainTab,
      images: images || [],
      videos: videos || [],
      city: city || '',
      type: type || '分享',
      likes: 0,
      comments: 0,
      views: 0,
      createdAt: new Date()
    };

    posts.unshift(newPost); // 添加到開頭

    // 更新用戶文章數量
    user.posts = user.posts + 1;

    res.status(201).json({
      message: '文章發布成功',
      post: newPost
    });
  } catch (error) {
    console.error('創建文章錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 搜索文章
app.get('/api/posts/search', (req, res) => {
  try {
    const { q: query, category, page = 1, limit = 20 } = req.query;

    let filteredPosts = [...posts];
    
    if (query) {
      filteredPosts = filteredPosts.filter(p => 
        p.title.includes(query) || 
        p.content.includes(query) || 
        p.author.includes(query)
      );
    }

    if (category && category !== '全部') {
      filteredPosts = filteredPosts.filter(p => p.category === category);
    }

    // 分頁
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedPosts = filteredPosts.slice(startIndex, endIndex);

    res.json({
      posts: paginatedPosts,
      total: filteredPosts.length,
      page: parseInt(page),
      limit: parseInt(limit)
    });
  } catch (error) {
    console.error('搜索文章錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 點讚/取消點讚
app.post('/api/interactions/posts/:postId/like', authenticateToken, (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.userId;

    const existingLike = likes.find(l => l.userId === userId && l.postId === postId);
    
    if (existingLike) {
      // 取消點讚
      const likeIndex = likes.findIndex(l => l.userId === userId && l.postId === postId);
      likes.splice(likeIndex, 1);
      
      const post = posts.find(p => p.id === postId);
      if (post) post.likes = Math.max(0, post.likes - 1);
      
      res.json({ message: '取消點讚成功', isLiked: false });
    } else {
      // 點讚
      likes.push({
        id: `like_${Date.now()}`,
        userId,
        postId,
        createdAt: new Date()
      });
      
      const post = posts.find(p => p.id === postId);
      if (post) post.likes = post.likes + 1;
      
      res.json({ message: '點讚成功', isLiked: true });
    }
  } catch (error) {
    console.error('點讚錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶關注列表
app.get('/api/users/:userId/following', (req, res) => {
  try {
    const { userId } = req.params;
    
    const userFollows = follows.filter(f => f.followerId === userId);
    const followingIds = userFollows.map(f => f.followingId);
    
    const followingUsers = users
      .filter(u => followingIds.includes(u.id))
      .map(user => ({
        id: user.id,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }));

    res.json({
      users: followingUsers
    });
  } catch (error) {
    console.error('獲取關注列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶粉絲列表
app.get('/api/users/:userId/followers', (req, res) => {
  try {
    const { userId } = req.params;
    
    const userFollowers = follows.filter(f => f.followingId === userId);
    const followerIds = userFollowers.map(f => f.followerId);
    
    const followerUsers = users
      .filter(u => followerIds.includes(u.id))
      .map(user => ({
        id: user.id,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }));

    res.json({
      users: followerUsers
    });
  } catch (error) {
    console.error('獲取粉絲列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取用戶資料
app.get('/api/users/:userId/profile', (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = users.find(u => u.id === userId);
    if (!user) {
      return res.status(404).json({ error: '用戶不存在' });
    }

    // 計算統計數據
    const postsCount = posts.filter(p => p.authorId === userId).length;
    const followersCount = follows.filter(f => f.followingId === userId).length;
    const followingCount = follows.filter(f => f.followerId === userId).length;

    res.json({
      id: user.id,
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
app.get('/api/messages/conversations', authenticateToken, (req, res) => {
  try {
    const userId = req.user.userId;
    
    const userConversations = conversations.filter(c => 
      c.participants.includes(userId)
    );

    res.json({
      conversations: userConversations
    });
  } catch (error) {
    console.error('獲取會話列表錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 獲取通知列表
app.get('/api/notifications', authenticateToken, (req, res) => {
  try {
    const userId = req.user.userId;
    
    const userNotifications = notifications.filter(n => n.userId === userId);

    res.json({
      notifications: userNotifications
    });
  } catch (error) {
    console.error('獲取通知錯誤:', error);
    res.status(500).json({ error: '服務器錯誤' });
  }
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 簡化後端服務器運行在 http://localhost:${PORT}`);
  console.log('📊 正在初始化測試數據...');
  
  // 初始化測試數據
  initializeTestData();
});

// 優雅關閉
process.on('SIGINT', () => {
  console.log('\n🛑 正在關閉服務器...');
  process.exit(0);
});
