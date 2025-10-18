// test_simple_server.js - 最簡單的測試服務器

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 8080;

// 最簡單的CORS配置
app.use(cors());
app.use(express.json());

// 測試數據
const testPosts = [
  {
    id: 'post_1',
    title: '測試文章1',
    content: '這是測試文章內容',
    author: '測試用戶1',
    category: '測試',
    likes: 10,
    comments: 2,
    views: 100
  },
  {
    id: 'post_2', 
    title: '測試文章2',
    content: '這是另一篇測試文章',
    author: '測試用戶2',
    category: '測試',
    likes: 5,
    comments: 1,
    views: 50
  }
];

const testUsers = [
  {
    id: 'user_1',
    email: 'test1@example.com',
    password: '123456',
    nickname: '測試用戶1'
  }
];

// 簡單的API路由
app.get('/api/posts', (req, res) => {
  console.log('📡 收到文章請求');
  res.json({
    posts: testPosts,
    total: testPosts.length
  });
});

app.post('/api/auth/login', (req, res) => {
  console.log('🔐 收到登入請求:', req.body);
  const { email, password } = req.body;
  
  const user = testUsers.find(u => u.email === email && u.password === password);
  
  if (user) {
    res.json({
      message: '登入成功',
      token: 'test-token-123',
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname
      }
    });
  } else {
    res.status(400).json({ error: '登入失敗' });
  }
});

app.get('/api/auth/profile', (req, res) => {
  console.log('👤 收到用戶資料請求');
  res.json({
    id: 'user_1',
    email: 'test1@example.com',
    nickname: '測試用戶1',
    avatar: '',
    levelNum: 1,
    isVerified: false,
    posts: 2,
    collections: 0,
    follows: 0,
    friends: 0
  });
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 測試服務器運行在 http://localhost:${PORT}`);
  console.log('📊 準備接收請求...');
});
