// stable_server.js - 穩定的測試服務器

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 8080;

// 最寬鬆的CORS配置
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

app.use(express.json());

// 測試數據
const testPosts = [
  {
    id: 'post_1',
    title: '測試文章1',
    content: '這是測試文章內容',
    author: '測試用戶1',
    authorId: 'test_user_1',
    category: '測試',
    mainTab: '分享',
    images: ['https://picsum.photos/seed/test1/400'],
    videos: [],
    city: '台北市',
    type: '分享',
    likes: 10,
    comments: 2,
    views: 100,
    createdAt: new Date().toISOString()
  },
  {
    id: 'post_2', 
    title: '測試文章2',
    content: '這是另一篇測試文章',
    author: '測試用戶2',
    authorId: 'test_user_2',
    category: '測試',
    mainTab: '共享',
    images: ['https://picsum.photos/seed/test2/400'],
    videos: [],
    city: '高雄市',
    type: '共享',
    likes: 5,
    comments: 1,
    views: 50,
    createdAt: new Date().toISOString()
  },
  {
    id: 'post_3', 
    title: '測試用戶的文章',
    content: '這是測試用戶分享的內容',
    author: '測試用戶',
    authorId: 'test_user_2',
    category: '分享',
    mainTab: '分享',
    images: ['https://picsum.photos/seed/test3/400'],
    videos: [],
    city: '台北市',
    type: '分享',
    likes: 8,
    comments: 3,
    views: 75,
    createdAt: new Date().toISOString()
  }
];

const testUsers = [
  {
    id: 'test_user_1',
    email: 'test1@example.com',
    password: '123456',
    nickname: '測試用戶1',
    avatar: 'https://picsum.photos/seed/user1/100',
    levelNum: 1,
    isVerified: false
  },
  {
    id: 'test_user_2',
    email: 'test@example.com',
    password: '123456',
    nickname: '測試用戶',
    avatar: 'https://picsum.photos/seed/user2/100',
    levelNum: 2,
    isVerified: false
  },
  {
    id: 'test_user_3',
    email: 'test2@example.com',
    password: '123456',
    nickname: '測試用戶2',
    avatar: 'https://picsum.photos/seed/user3/100',
    levelNum: 3,
    isVerified: true
  },
  {
    id: 'test_user_4',
    email: 'test3@example.com',
    password: '123456',
    nickname: '測試用戶3',
    avatar: 'https://picsum.photos/seed/user4/100',
    levelNum: 4,
    isVerified: true
  },
  {
    id: 'test_user_5',
    email: 'test4@example.com',
    password: '123456',
    nickname: '測試用戶4',
    avatar: 'https://picsum.photos/seed/user5/100',
    levelNum: 5,
    isVerified: false
  },
  {
    id: 'test_user_6',
    email: 'test5@example.com',
    password: '123456',
    nickname: '攝影大叔',
    avatar: 'https://picsum.photos/seed/user6/100',
    levelNum: 6,
    isVerified: true
  },
  {
    id: 'test_user_7',
    email: 'test6@example.com',
    password: '123456',
    nickname: '貓咪日常',
    avatar: 'https://picsum.photos/seed/user7/100',
    levelNum: 7,
    isVerified: false
  },
  {
    id: 'test_user_8',
    email: 'test7@example.com',
    password: '123456',
    nickname: '旅行日記',
    avatar: 'https://picsum.photos/seed/user8/100',
    levelNum: 8,
    isVerified: true
  },
  {
    id: 'test_user_9',
    email: 'test8@example.com',
    password: '123456',
    nickname: '美食家',
    avatar: 'https://picsum.photos/seed/user9/100',
    levelNum: 9,
    isVerified: false
  },
  {
    id: 'test_user_10',
    email: 'test9@example.com',
    password: '123456',
    nickname: '設計師小李',
    avatar: 'https://picsum.photos/seed/user10/100',
    levelNum: 10,
    isVerified: true
  }
];

// API路由
app.get('/api/posts', (req, res) => {
  console.log('📡 收到文章請求:', req.query);
  res.json({
    posts: testPosts,
    total: testPosts.length,
    page: parseInt(req.query.page) || 1,
    limit: parseInt(req.query.limit) || 20
  });
});

app.post('/api/auth/login', (req, res) => {
  console.log('🔐 收到登入請求:', req.body);
  const { email, password } = req.body;
  
  const user = testUsers.find(u => u.email === email && u.password === password);
  
  if (user) {
    res.json({
      message: '登入成功',
      token: 'test-token-123456',
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        levelNum: user.levelNum,
        isVerified: user.isVerified
      }
    });
  } else {
    res.status(400).json({ error: '登入失敗' });
  }
});

app.get('/api/auth/profile', (req, res) => {
  console.log('👤 收到用戶資料請求');
  
  // 根據token返回對應用戶的資料
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  let currentUser = testUsers[1]; // 默認返回test@example.com用戶
  
  if (token === 'test-token-123456') {
    currentUser = testUsers[1]; // test@example.com
  }
  
  // 計算實際統計資料
  const userPosts = testPosts.filter(p => p.authorId === currentUser.id);
  const userFollowing = follows.filter(f => f.followerId === currentUser.id);
  const userFollowers = follows.filter(f => f.followingId === currentUser.id);
  
  res.json({
    id: currentUser.id,
    email: currentUser.email,
    nickname: currentUser.nickname,
    avatar: currentUser.avatar,
    levelNum: currentUser.levelNum,
    isVerified: currentUser.isVerified,
    posts: userPosts.length,
    collections: Math.floor(Math.random() * 10) + 1, // 隨機收藏數
    follows: userFollowing.length,
    friends: userFollowers.length
  });
});

app.post('/api/posts', (req, res) => {
  console.log('📝 收到發布文章請求:', req.body);
  const newPost = {
    id: `post_${Date.now()}`,
    title: req.body.title || '無標題',
    content: req.body.content || '',
    author: '測試用戶1',
    authorId: 'test_user_1',
    category: req.body.category || '分享',
    mainTab: req.body.mainTab || '分享',
    images: Array.isArray(req.body.images) ? req.body.images : [],
    videos: Array.isArray(req.body.videos) ? req.body.videos : [],
    city: req.body.city || '未知地區',
    type: req.body.type || '分享',
    likes: 0,
    comments: 0,
    views: 0,
    createdAt: new Date().toISOString()
  };
  
  console.log('📝 創建新文章:', newPost);
  testPosts.unshift(newPost);
  
  res.status(201).json({
    message: '文章發布成功',
    post: newPost
  });
});

app.get('/api/posts/search', (req, res) => {
  console.log('🔍 收到搜索請求:', req.query);
  const query = req.query.query;
  
  let filteredPosts = testPosts;
  if (query) {
    filteredPosts = testPosts.filter(post => 
      post.title.includes(query) || 
      post.content.includes(query) || 
      post.city.includes(query)
    );
  }
  
  res.json({
    posts: filteredPosts,
    total: filteredPosts.length,
    page: parseInt(req.query.page) || 1,
    limit: parseInt(req.query.limit) || 20
  });
});

// 點讚/取消點讚
app.post('/api/interactions/posts/:postId/like', (req, res) => {
  console.log('👍 收到點讚請求:', req.params.postId);
  const postId = req.params.postId;
  
  const post = testPosts.find(p => p.id === postId);
  if (post) {
    // 簡單的切換邏輯：如果當前是偶數就+1，奇數就-1
    if ((post.likes || 0) % 2 === 0) {
      post.likes = (post.likes || 0) + 1;
      res.json({ 
        message: '點讚成功', 
        isLiked: true,
        likeCount: post.likes 
      });
    } else {
      post.likes = Math.max(0, (post.likes || 0) - 1);
      res.json({ 
        message: '取消點讚', 
        isLiked: false,
        likeCount: post.likes 
      });
    }
  } else {
    res.status(404).json({ error: '文章不存在' });
  }
});

// 評論文章
app.post('/api/interactions/posts/:postId/comment', (req, res) => {
  console.log('💬 收到評論請求:', req.params.postId, req.body);
  const postId = req.params.postId;
  const { content, username } = req.body;
  
  const post = testPosts.find(p => p.id === postId);
  if (post) {
    post.comments = (post.comments || 0) + 1;
    
    // 創建新評論並添加到評論列表
    const newComment = {
      id: `comment_${Date.now()}`,
      content,
      username: username || '測試用戶',
      userAvatar: `https://picsum.photos/seed/${username?.hashCode || 'user'}/50`,
      createdAt: new Date().toISOString()
    };
    
    // 如果沒有評論數組，創建一個
    if (!post.commentsList) {
      post.commentsList = [];
    }
    post.commentsList.push(newComment);
    
    res.json({ 
      message: '評論成功', 
      comment: newComment
    });
  } else {
    res.status(404).json({ error: '文章不存在' });
  }
});

// 獲取文章評論
app.get('/api/interactions/posts/:postId/comments', (req, res) => {
  console.log('📝 收到評論列表請求:', req.params.postId);
  const postId = req.params.postId;
  const post = testPosts.find(p => p.id === postId);
  
  if (post) {
    // 返回該文章的實際評論列表，如果沒有則返回默認評論
    const comments = post.commentsList || [
      {
        id: 'comment_1',
        content: '這是測試評論1',
        username: '測試用戶1',
        userAvatar: 'https://picsum.photos/seed/user1/50',
        createdAt: '2025-01-17 10:30:00'
      },
      {
        id: 'comment_2',
        content: '這是測試評論2',
        username: '測試用戶2',
        userAvatar: 'https://picsum.photos/seed/user2/50',
        createdAt: '2025-01-17 11:15:00'
      }
    ];
    
    res.json({
      success: true,
      comments: comments
    });
  } else {
    res.status(404).json({ error: '文章不存在' });
  }
});

// 關注/取消關注用戶
app.post('/api/interactions/users/:targetUserId/follow', (req, res) => {
  console.log('👥 收到關注請求:', req.params.targetUserId);
  res.json({ 
    message: '關注成功', 
    isFollowing: true 
  });
});

// 獲取用戶關注列表
app.get('/api/users/:userId/following', (req, res) => {
  console.log('👥 收到關注列表請求:', req.params.userId);
  res.json({
    users: testUsers.map(user => ({
      id: user.id,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified
    }))
  });
});

// 獲取用戶粉絲列表
app.get('/api/users/:userId/followers', (req, res) => {
  console.log('👥 收到粉絲列表請求:', req.params.userId);
  res.json({
    users: testUsers.map(user => ({
      id: user.id,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified
    }))
  });
});

// 獲取用戶資料
app.get('/api/users/:userId/profile', (req, res) => {
  console.log('👤 收到用戶資料請求:', req.params.userId);
  const userId = req.params.userId;
  
  const user = testUsers.find(u => u.id === userId);
  if (user) {
    // 計算實際統計資料
    const userPosts = testPosts.filter(p => p.authorId === user.id);
    const userFollowing = follows.filter(f => f.followerId === user.id);
    const userFollowers = follows.filter(f => f.followingId === user.id);
    
    res.json({
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified,
      posts: userPosts.length,
      collections: Math.floor(Math.random() * 10) + 1, // 隨機收藏數
      follows: userFollowing.length,
      friends: userFollowers.length
    });
  } else {
    res.status(404).json({ error: '用戶不存在' });
  }
});

// 獲取通知列表
app.get('/api/notifications', (req, res) => {
  console.log('🔔 收到通知請求');
  res.json({
    notifications: [
      {
        id: 'notif_1',
        type: 'like',
        title: '有人點讚了你的文章',
        content: '測試用戶點讚了你的文章「一起搭車分攤油錢」',
        isRead: false,
        createdAt: new Date().toISOString()
      },
      {
        id: 'notif_2',
        type: 'comment',
        title: '有人評論了你的文章',
        content: '測試用戶評論了你的文章「測試文章1」',
        isRead: false,
        createdAt: new Date().toISOString()
      },
      {
        id: 'notif_3',
        type: 'follow',
        title: '有人關注了你',
        content: '測試用戶2關注了你',
        isRead: true,
        createdAt: new Date().toISOString()
      }
    ]
  });
});

// 標記通知為已讀
app.post('/api/notifications/:notificationId/read', (req, res) => {
  console.log('✅ 收到標記通知已讀請求:', req.params.notificationId);
  res.json({ message: '通知已標記為已讀' });
});

// 標記所有通知為已讀
app.post('/api/notifications/mark-all-read', (req, res) => {
  console.log('✅ 收到標記所有通知已讀請求');
  res.json({ 
    message: '所有通知已標記為已讀',
    success: true 
  });
});

// 刪除所有通知
app.delete('/api/notifications/delete-all', (req, res) => {
  console.log('🗑️ 收到刪除所有通知請求');
  res.json({ 
    message: '所有通知已刪除',
    success: true 
  });
});

// 分享功能
app.post('/api/interactions/posts/:postId/share', (req, res) => {
  console.log('📤 收到分享請求:', req.params.postId);
  const postId = req.params.postId;
  
  const post = testPosts.find(p => p.id === postId);
  if (post) {
    // 增加分享數
    post.shares = (post.shares || 0) + 1;
    res.json({ 
      message: '分享成功', 
      shareCount: post.shares,
      shareUrl: `https://xiangxiang.com/post/${postId}`
    });
  } else {
    res.status(404).json({ error: '文章不存在' });
  }
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 穩定服務器運行在 http://localhost:${PORT}`);
  console.log('📊 準備接收請求...');
  console.log('🔗 測試URL: http://127.0.0.1:8080/api/posts');
});
