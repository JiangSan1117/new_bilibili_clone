const http = require('http');
const fs = require('fs');
const path = require('path');

// 全局文章列表
let posts = [
  {
    id: 'post_1',
    title: '分享一個很棒的美食推薦',
    content: '今天發現了一家很棒的餐廳，推薦給大家...',
    author: '測試用戶1',
    category: '飲食',
    type: '分享',
    city: '台北市',
    createdAt: new Date(Date.now() - 3600000).toISOString(),
    likes: 25,
    comments: 8,
    views: 150
  },
  {
    id: 'post_2',
    title: '台北旅遊景點分享',
    content: '周末去了台北幾個景點，風景很美...',
    author: '測試用戶1',
    category: '娛樂',
    type: '共享',
    city: '台北市',
    createdAt: new Date(Date.now() - 7200000).toISOString(),
    likes: 18,
    comments: 5,
    views: 200
  },
  {
    id: 'post_3',
    title: '推薦好用的手機App',
    content: '最近發現幾個很實用的App，分享給大家...',
    author: '測試用戶1',
    category: '教育',
    type: '分享',
    city: '新北市',
    createdAt: new Date(Date.now() - 10800000).toISOString(),
    likes: 32,
    comments: 12,
    views: 300
  }
];

// 互動功能數據
let likes = {}; // { postId: [userId1, userId2, ...] }
let comments = {}; // { postId: [{ id, userId, content, createdAt, ... }] }
let follows = {}; // { userId: [followingUserId1, followingUserId2, ...] }

// 訊息系統數據
let conversations = {}; // { conversationId: { id, participants, lastMessage, updatedAt } }
let messages = {}; // { conversationId: [{ id, senderId, content, createdAt, read }] }
let notifications = {}; // { userId: [{ id, type, content, createdAt, read, data }] }

// 初始化10個帳號的相互關注關係
const initializeFollows = () => {
  const userIds = [
    'test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_5',
    'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10'
  ];
  
  // 為每個用戶創建關注列表
  userIds.forEach(userId => {
    if (!follows[userId]) {
      follows[userId] = [];
    }
  });
  
  // 創建相互關注關係（每個用戶關注其他所有用戶，除了自己）
  const followRelations = [
    // test_user_1 關注 2, 3, 4, 5, 6, 7, 8, 9, 10
    ['test_user_1', ['test_user_2', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_2 關注 1, 3, 4, 5, 6, 7, 8, 9, 10
    ['test_user_2', ['test_user_1', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_3 關注 1, 2, 4, 5, 6, 7, 8, 9, 10
    ['test_user_3', ['test_user_1', 'test_user_2', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_4 關注 1, 2, 3, 5, 6, 7, 8, 9, 10
    ['test_user_4', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_5 關注 1, 2, 3, 4, 6, 7, 8, 9, 10
    ['test_user_5', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_6 關注 1, 2, 3, 4, 5, 7, 8, 9, 10
    ['test_user_6', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_7', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_7 關注 1, 2, 3, 4, 5, 6, 8, 9, 10
    ['test_user_7', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_8', 'test_user_9', 'test_user_10']],
    // test_user_8 關注 1, 2, 3, 4, 5, 6, 7, 9, 10
    ['test_user_8', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_9', 'test_user_10']],
    // test_user_9 關注 1, 2, 3, 4, 5, 6, 7, 8, 10
    ['test_user_9', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_10']],
    // test_user_10 關注 1, 2, 3, 4, 5, 6, 7, 8, 9
    ['test_user_10', ['test_user_1', 'test_user_2', 'test_user_3', 'test_user_4', 'test_user_5', 'test_user_6', 'test_user_7', 'test_user_8', 'test_user_9']]
  ];
  
  followRelations.forEach(([userId, followingList]) => {
    follows[userId] = followingList;
    console.log(`初始化關注關係: ${userId} 關注 ${followingList.join(', ')}`);
  });
};

// 啟動時初始化關注關係
initializeFollows();

const server = http.createServer((req, res) => {
  // 記錄所有請求
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url} from ${req.headers.origin || 'unknown'}`);
  
  // 設置CORS標頭
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Max-Age', '86400');
  
  if (req.method === 'OPTIONS') {
    console.log('處理OPTIONS請求');
    res.writeHead(200);
    res.end();
    return;
  }

  // API路由
  if (req.url === '/api/auth/register' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        console.log('收到註冊請求體:', body);
        const data = JSON.parse(body);
        console.log('解析後的註冊請求:', data);
        
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          message: '註冊成功 (簡單HTTP服務器)',
          token: 'test_token_12345',
          user: {
            id: 'test_user_id',
            email: data.email,
            nickname: data.nickname
          }
        }));
      } catch (error) {
        console.error('註冊請求處理錯誤:', error);
        console.error('請求體:', body);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤: ' + error.message }));
      }
    });
  } else if (req.url === '/api/auth/login' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const { email, password } = data;
        
        console.log('收到登入請求:', { email, password });
        
        // 測試帳號數據
        const testAccounts = [
          {
            email: 'test@example.com',
            password: '123456',
            id: 'test_user_1',
            nickname: '測試用戶1',
            levelNum: 3,
            verificationStatus: 'unverified'
          },
          {
            email: 'test2@example.com',
            password: '123456',
            id: 'test_user_2',
            nickname: '美食達人',
            levelNum: 5,
            verificationStatus: 'verified'
          },
          {
            email: 'test3@example.com',
            password: '123456',
            id: 'test_user_3',
            nickname: '旅遊愛好者',
            levelNum: 4,
            verificationStatus: 'unverified'
          },
          {
            email: 'test4@example.com',
            password: '123456',
            id: 'test_user_4',
            nickname: '科技達人',
            levelNum: 6,
            verificationStatus: 'verified'
          },
          {
            email: 'test5@example.com',
            password: '123456',
            id: 'test_user_5',
            nickname: '手作達人',
            levelNum: 4,
            verificationStatus: 'unverified'
          },
          {
            email: 'test6@example.com',
            password: '123456',
            id: 'test_user_6',
            nickname: '攝影師',
            levelNum: 5,
            verificationStatus: 'verified'
          },
          {
            email: 'test7@example.com',
            password: '123456',
            id: 'test_user_7',
            nickname: '健身教練',
            levelNum: 3,
            verificationStatus: 'unverified'
          },
          {
            email: 'test8@example.com',
            password: '123456',
            id: 'test_user_8',
            nickname: '音樂人',
            levelNum: 4,
            verificationStatus: 'unverified'
          },
          {
            email: 'test9@example.com',
            password: '123456',
            id: 'test_user_9',
            nickname: '設計師',
            levelNum: 5,
            verificationStatus: 'verified'
          },
          {
            email: 'test10@example.com',
            password: '123456',
            id: 'test_user_10',
            nickname: '學生小助手',
            levelNum: 2,
            verificationStatus: 'unverified'
          }
        ];
        
        // 查找匹配的帳號
        const account = testAccounts.find(acc => acc.email === email && acc.password === password);
        
        if (account) {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            message: '登入成功 (簡單HTTP服務器)',
            token: `test_token_${account.id}`,
            user: {
              id: account.id,
              email: email,
              nickname: account.nickname
            }
          }));
        } else {
          res.writeHead(401, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: '電子郵件或密碼錯誤' }));
        }
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
  } else if (req.url === '/api/auth/profile' && req.method === 'GET') {
    // 獲取用戶資料
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ 
        success: false,
        error: '訪問令牌缺失' 
      }));
      return;
    }
    
    console.log('收到獲取用戶資料請求，token:', token);
    
    // 測試帳號數據（與登入API保持一致）
    const testAccounts = [
      {
        token: 'test_token_test_user_1',
        id: 'test_user_1',
        email: 'test@example.com',
        nickname: '測試用戶1',
        levelNum: 3,
        verificationStatus: 'unverified',
        realName: '王小明',
        idCardNumber: 'A123456789',
        phone: '0912345678',
        location: '台北市',
        posts: 5
      },
      {
        token: 'test_token_test_user_2',
        id: 'test_user_2',
        email: 'test2@example.com',
        nickname: '美食達人',
        levelNum: 5,
        verificationStatus: 'verified',
        realName: '李美食',
        idCardNumber: 'B234567890',
        phone: '0923456789',
        location: '台中市',
        posts: 12
      },
      {
        token: 'test_token_test_user_3',
        id: 'test_user_3',
        email: 'test3@example.com',
        nickname: '旅遊愛好者',
        levelNum: 4,
        verificationStatus: 'unverified',
        realName: '陳旅遊',
        idCardNumber: 'C345678901',
        phone: '0934567890',
        location: '高雄市',
        posts: 8
      },
      {
        token: 'test_token_test_user_4',
        id: 'test_user_4',
        email: 'test4@example.com',
        nickname: '科技達人',
        levelNum: 6,
        verificationStatus: 'verified',
        realName: '張科技',
        idCardNumber: 'D456789012',
        phone: '0945678901',
        location: '新竹市',
        posts: 15
      },
      {
        token: 'test_token_test_user_5',
        id: 'test_user_5',
        email: 'test5@example.com',
        nickname: '手作達人',
        levelNum: 4,
        verificationStatus: 'unverified',
        realName: '林手作',
        idCardNumber: 'E567890123',
        phone: '0956789012',
        location: '台南市',
        posts: 7
      },
      {
        token: 'test_token_test_user_6',
        id: 'test_user_6',
        email: 'test6@example.com',
        nickname: '攝影師',
        levelNum: 5,
        verificationStatus: 'verified',
        realName: '黃攝影',
        idCardNumber: 'F678901234',
        phone: '0967890123',
        location: '桃園市',
        posts: 20
      },
      {
        token: 'test_token_test_user_7',
        id: 'test_user_7',
        email: 'test7@example.com',
        nickname: '健身教練',
        levelNum: 3,
        verificationStatus: 'unverified',
        realName: '吳健身',
        idCardNumber: 'G789012345',
        phone: '0978901234',
        location: '基隆市',
        posts: 6
      },
      {
        token: 'test_token_test_user_8',
        id: 'test_user_8',
        email: 'test8@example.com',
        nickname: '音樂人',
        levelNum: 4,
        verificationStatus: 'unverified',
        realName: '鄭音樂',
        idCardNumber: 'H890123456',
        phone: '0989012345',
        location: '宜蘭縣',
        posts: 9
      },
      {
        token: 'test_token_test_user_9',
        id: 'test_user_9',
        email: 'test9@example.com',
        nickname: '設計師',
        levelNum: 5,
        verificationStatus: 'verified',
        realName: '謝設計',
        idCardNumber: 'I901234567',
        phone: '0990123456',
        location: '花蓮縣',
        posts: 11
      },
      {
        token: 'test_token_test_user_10',
        id: 'test_user_10',
        email: 'test10@example.com',
        nickname: '學生小助手',
        levelNum: 2,
        verificationStatus: 'unverified',
        realName: '蔡學生',
        idCardNumber: 'J012345678',
        phone: '0901234567',
        location: '屏東縣',
        posts: 3
      }
    ];
    
    // 查找匹配的帳號
    const account = testAccounts.find(acc => acc.token === token);
    
    if (account) {
      // 計算真實的關注和粉絲數量
      const followingCount = (follows[account.id] || []).length;
      const followersCount = Object.values(follows).filter(followingList => 
        followingList.includes(account.id)
      ).length;
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: true,
        user: {
          id: account.id,
          email: account.email,
          nickname: account.nickname,
          avatar: null,
          realName: account.realName,
          idCardNumber: account.idCardNumber,
          verificationStatus: account.verificationStatus,
          membershipType: account.verificationStatus === 'verified' ? 'verified' : 'free',
          levelNum: account.levelNum,
          collections: 0, // 收藏數量
          follows: followingCount, // 使用真實的關注數量
          friends: followingCount, // 好友數量與關注數量相同
          posts: posts.filter(post => 
            post.author === account.nickname || 
            post.author === '測試用戶' // 兼容新發布的文章
          ).length, // 使用真實的發布文章數量
          phone: account.phone,
          location: account.location,
          verificationDate: account.verificationStatus === 'verified' ? new Date().toISOString() : null,
          verificationNotes: account.verificationStatus === 'verified' ? '已通過實名認證' : ''
        }
      }));
    } else {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ 
        success: false,
        error: '無效的訪問令牌' 
      }));
    }
  } else if (req.url === '/api/posts' && req.method === 'POST') {
    // 創建文章
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        console.log('收到發布文章請求:', data);
        
        // 創建新文章
        const newPost = {
          id: 'post_' + Date.now(),
          title: data.title,
          content: data.content,
          author: '測試用戶', // 固定作者名稱
          category: data.category || '未分類',
          type: data.type || '共享',
          city: data.city || '未知地區',
          createdAt: new Date().toISOString(),
          likes: 0,
          comments: 0,
          views: 0
        };
        
        // 將新文章添加到全局列表的開頭
        posts.unshift(newPost);
        
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          message: '文章發布成功',
          post: newPost
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
  } else if (req.url.startsWith('/api/posts') && req.method === 'GET') {
    // 檢查是否是搜索請求
    if (req.url.includes('/search')) {
      // 解析搜索參數
      const url = new URL(req.url, `http://${req.headers.host}`);
      const query = url.searchParams.get('query') || '';
      const category = url.searchParams.get('category') || '';
      const page = parseInt(url.searchParams.get('page')) || 1;
      const limit = parseInt(url.searchParams.get('limit')) || 20;
      
      console.log('收到搜索請求:', { query, category, page, limit });
      
      // 執行搜索
      let searchResults = posts;
      
      if (query) {
        searchResults = posts.filter(post => 
          post.title.toLowerCase().includes(query.toLowerCase()) ||
          post.content.toLowerCase().includes(query.toLowerCase()) ||
          post.author.toLowerCase().includes(query.toLowerCase()) ||
          post.category.toLowerCase().includes(query.toLowerCase())
        );
      }
      
      if (category) {
        searchResults = searchResults.filter(post => 
          post.category === category
        );
      }
      
      // 分頁
      const startIndex = (page - 1) * limit;
      const endIndex = startIndex + limit;
      const paginatedResults = searchResults.slice(startIndex, endIndex);
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: true,
        posts: paginatedResults,
        total: searchResults.length,
        page: page,
        limit: limit,
        query: query,
        category: category
      }));
    } else {
      // 獲取文章列表
      console.log('返回文章列表，共', posts.length, '篇文章');
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        posts: posts,
        total: posts.length
      }));
    }
  // 互動功能API
  } else if (req.url.startsWith('/api/interactions/posts/') && req.url.includes('/like') && req.method === 'POST') {
    // 點讚/取消點讚文章
    const postId = req.url.split('/')[4];
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const userId = data.userId || 'current_user';
        
        if (!likes[postId]) {
          likes[postId] = [];
        }
        
        const likeIndex = likes[postId].indexOf(userId);
        if (likeIndex > -1) {
          // 取消點讚
          likes[postId].splice(likeIndex, 1);
          console.log(`用戶 ${userId} 取消點讚文章 ${postId}`);
        } else {
          // 點讚
          likes[postId].push(userId);
          console.log(`用戶 ${userId} 點讚文章 ${postId}`);
        }
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          isLiked: likes[postId].includes(userId),
          likeCount: likes[postId].length
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  } else if (req.url.startsWith('/api/interactions/posts/') && req.url.includes('/comment') && req.method === 'POST') {
    // 評論文章
    const postId = req.url.split('/')[4];
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const userId = data.userId || 'current_user';
        const content = data.content;
        
        if (!comments[postId]) {
          comments[postId] = [];
        }
        
        const comment = {
          id: `comment_${Date.now()}`,
          userId: userId,
          username: data.username || '用戶',
          content: content,
          createdAt: new Date().toISOString(),
          likes: 0
        };
        
        comments[postId].push(comment);
        console.log(`用戶 ${userId} 評論文章 ${postId}: ${content}`);
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          comment: comment,
          commentCount: comments[postId].length
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  } else if (req.url.startsWith('/api/interactions/posts/') && req.url.includes('/comments') && req.method === 'GET') {
    // 獲取文章評論
    const postId = req.url.split('/')[4];
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      comments: comments[postId] || [],
      total: comments[postId] ? comments[postId].length : 0
    }));
    
  } else if (req.url.startsWith('/api/interactions/users/') && req.url.includes('/follow') && req.method === 'POST') {
    // 關注/取消關注用戶
    const targetUserId = req.url.split('/')[4];
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const userId = data.userId || 'current_user';
        
        if (!follows[userId]) {
          follows[userId] = [];
        }
        
        const followIndex = follows[userId].indexOf(targetUserId);
        if (followIndex > -1) {
          // 取消關注
          follows[userId].splice(followIndex, 1);
          console.log(`用戶 ${userId} 取消關注用戶 ${targetUserId}`);
        } else {
          // 關注
          follows[userId].push(targetUserId);
          console.log(`用戶 ${userId} 關注用戶 ${targetUserId}`);
        }
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          isFollowing: follows[userId].includes(targetUserId),
          followingCount: follows[userId].length
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  // 訊息系統API
  } else if (req.url.startsWith('/api/messages/conversations') && req.method === 'GET') {
    // 獲取用戶的對話列表
    const url = new URL(req.url, `http://${req.headers.host}`);
    const userId = url.searchParams.get('userId') || 'current_user';
    
    // 找到包含該用戶的所有對話
    const userConversations = Object.values(conversations).filter(conv => 
      conv.participants.includes(userId)
    );
    
    // 按最後更新時間排序
    userConversations.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      conversations: userConversations
    }));
    
  } else if (req.url.startsWith('/api/messages/conversations') && req.method === 'POST') {
    // 創建新對話
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const participants = data.participants || [];
        
        if (participants.length < 2) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: '對話需要至少2個參與者' }));
          return;
        }
        
        // 檢查是否已存在相同的對話
        const existingConv = Object.values(conversations).find(conv => 
          conv.participants.length === participants.length &&
          conv.participants.every(p => participants.includes(p))
        );
        
        if (existingConv) {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: true,
            conversation: existingConv,
            isNew: false
          }));
          return;
        }
        
        const conversationId = `conv_${Date.now()}`;
        const conversation = {
          id: conversationId,
          participants: participants,
          lastMessage: null,
          updatedAt: new Date().toISOString()
        };
        
        conversations[conversationId] = conversation;
        messages[conversationId] = [];
        
        console.log(`創建新對話: ${conversationId}, 參與者: ${participants.join(', ')}`);
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          conversation: conversation,
          isNew: true
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  } else if (req.url.startsWith('/api/messages/conversations/') && req.url.includes('/messages') && req.method === 'GET') {
    // 獲取對話中的訊息
    const conversationId = req.url.split('/')[4];
    const url = new URL(req.url, `http://${req.headers.host}`);
    const page = parseInt(url.searchParams.get('page')) || 1;
    const limit = parseInt(url.searchParams.get('limit')) || 50;
    
    const conversationMessages = messages[conversationId] || [];
    
    // 按時間排序（最新的在前）
    conversationMessages.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    
    // 分頁
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedMessages = conversationMessages.slice(startIndex, endIndex);
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      messages: paginatedMessages,
      total: conversationMessages.length,
      page: page,
      limit: limit
    }));
    
  } else if (req.url.startsWith('/api/messages/conversations/') && req.url.includes('/messages') && req.method === 'POST') {
    // 發送訊息
    const conversationId = req.url.split('/')[4];
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const senderId = data.senderId || 'current_user';
        const content = data.content;
        
        if (!conversations[conversationId]) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: '對話不存在' }));
          return;
        }
        
        const message = {
          id: `msg_${Date.now()}`,
          conversationId: conversationId,
          senderId: senderId,
          senderName: data.senderName || '用戶',
          content: content,
          createdAt: new Date().toISOString(),
          read: false
        };
        
        messages[conversationId].push(message);
        
        // 更新對話的最後訊息
        conversations[conversationId].lastMessage = {
          content: content,
          senderId: senderId,
          createdAt: message.createdAt
        };
        conversations[conversationId].updatedAt = message.createdAt;
        
        console.log(`用戶 ${senderId} 在對話 ${conversationId} 中發送訊息: ${content}`);
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          message: message
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  } else if (req.url.startsWith('/api/notifications') && req.method === 'GET') {
    // 獲取用戶通知
    const url = new URL(req.url, `http://${req.headers.host}`);
    const userId = url.searchParams.get('userId') || 'current_user';
    
    const userNotifications = notifications[userId] || [];
    
    // 按時間排序（最新的在前）
    userNotifications.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      notifications: userNotifications
    }));
    
  } else if (req.url.startsWith('/api/notifications/') && req.url.includes('/read') && req.method === 'POST') {
    // 標記通知為已讀
    const notificationId = req.url.split('/')[3];
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const userId = data.userId || 'current_user';
        
        // 找到並標記通知為已讀
        const userNotifications = notifications[userId] || [];
        const notification = userNotifications.find(n => n.id === notificationId);
        
        if (notification) {
          notification.read = true;
          console.log(`用戶 ${userId} 標記通知 ${notificationId} 為已讀`);
        }
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  // 用戶關注和好友API
  } else if (req.url.startsWith('/api/users/') && req.url.includes('/follow') && req.method === 'POST') {
    // 關注/取消關注用戶
    const targetUserId = req.url.split('/')[3];
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const userId = data.userId || 'current_user';
        
        if (!follows[userId]) {
          follows[userId] = [];
        }
        
        const followIndex = follows[userId].indexOf(targetUserId);
        if (followIndex > -1) {
          // 取消關注
          follows[userId].splice(followIndex, 1);
          console.log(`用戶 ${userId} 取消關注用戶 ${targetUserId}`);
        } else {
          // 關注
          follows[userId].push(targetUserId);
          console.log(`用戶 ${userId} 關注用戶 ${targetUserId}`);
        }
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          isFollowing: follows[userId].includes(targetUserId),
          followingCount: follows[userId].length
        }));
      } catch (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '服務器錯誤' }));
      }
    });
    
  } else if (req.url.startsWith('/api/users/') && req.url.includes('/followers') && req.method === 'GET') {
    // 獲取用戶的關注者列表
    const userId = req.url.split('/')[3];
    
    // 用戶資料映射
    const userDataMap = {
      'test_user_1': { nickname: '測試用戶1', levelNum: 3 },
      'test_user_2': { nickname: '美食達人', levelNum: 5 },
      'test_user_3': { nickname: '旅遊愛好者', levelNum: 4 },
      'test_user_4': { nickname: '科技達人', levelNum: 6 },
      'test_user_5': { nickname: '手作達人', levelNum: 4 },
      'test_user_6': { nickname: '攝影師', levelNum: 5 },
      'test_user_7': { nickname: '健身教練', levelNum: 3 },
      'test_user_8': { nickname: '音樂人', levelNum: 4 },
      'test_user_9': { nickname: '設計師', levelNum: 5 },
      'test_user_10': { nickname: '學生小助手', levelNum: 2 }
    };
    
    const followers = [];
    for (const [followerId, followingList] of Object.entries(follows)) {
      if (followingList.includes(userId)) {
        const userData = userDataMap[followerId] || { nickname: `用戶${followerId.split('_').pop()}`, levelNum: 1 };
        followers.push({
          id: followerId,
          nickname: userData.nickname,
          avatar: 'https://via.placeholder.com/150',
          levelNum: userData.levelNum,
          isFollowing: false // 當前用戶是否關注了這個用戶
        });
      }
    }
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      users: followers,
      total: followers.length
    }));
    
  } else if (req.url.startsWith('/api/users/') && req.url.includes('/following') && req.method === 'GET') {
    // 獲取用戶的關注列表
    const userId = req.url.split('/')[3];
    
    // 用戶資料映射
    const userDataMap = {
      'test_user_1': { nickname: '測試用戶1', levelNum: 3 },
      'test_user_2': { nickname: '美食達人', levelNum: 5 },
      'test_user_3': { nickname: '旅遊愛好者', levelNum: 4 },
      'test_user_4': { nickname: '科技達人', levelNum: 6 },
      'test_user_5': { nickname: '手作達人', levelNum: 4 },
      'test_user_6': { nickname: '攝影師', levelNum: 5 },
      'test_user_7': { nickname: '健身教練', levelNum: 3 },
      'test_user_8': { nickname: '音樂人', levelNum: 4 },
      'test_user_9': { nickname: '設計師', levelNum: 5 },
      'test_user_10': { nickname: '學生小助手', levelNum: 2 }
    };
    
    const following = (follows[userId] || []).map(followingId => {
      const userData = userDataMap[followingId] || { nickname: `用戶${followingId.split('_').pop()}`, levelNum: 1 };
      return {
        id: followingId,
        nickname: userData.nickname,
        avatar: 'https://via.placeholder.com/150',
        levelNum: userData.levelNum,
        isFollowing: true
      };
    });
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      users: following,
      total: following.length
    }));
    
  } else if (req.url.startsWith('/api/users/') && req.url.includes('/profile') && req.method === 'GET') {
    // 獲取用戶公開資料
    const userId = req.url.split('/')[3];
    
    // 基礎用戶資料
    const baseUserProfiles = {
      'test_user_1': { nickname: '測試用戶1', levelNum: 3, posts: 5, isVerified: false },
      'test_user_2': { nickname: '美食達人', levelNum: 5, posts: 12, isVerified: true },
      'test_user_3': { nickname: '旅遊愛好者', levelNum: 4, posts: 8, isVerified: false },
      'test_user_4': { nickname: '科技達人', levelNum: 6, posts: 15, isVerified: true },
      'test_user_5': { nickname: '手作達人', levelNum: 4, posts: 7, isVerified: false },
      'test_user_6': { nickname: '攝影師', levelNum: 5, posts: 20, isVerified: true },
      'test_user_7': { nickname: '健身教練', levelNum: 3, posts: 6, isVerified: false },
      'test_user_8': { nickname: '音樂人', levelNum: 4, posts: 9, isVerified: false },
      'test_user_9': { nickname: '設計師', levelNum: 5, posts: 11, isVerified: true },
      'test_user_10': { nickname: '學生小助手', levelNum: 2, posts: 3, isVerified: false }
    };
    
    const baseProfile = baseUserProfiles[userId];
    if (baseProfile) {
      // 計算真實的關注和粉絲數量
      const followingCount = (follows[userId] || []).length;
      const followersCount = Object.values(follows).filter(followingList => 
        followingList.includes(userId)
      ).length;
      
      // 計算真實的發布文章數量
      const userPostsCount = posts.filter(post => 
        post.author === baseProfile.nickname || 
        post.author === '測試用戶' // 兼容新發布的文章
      ).length;
      
      const profile = {
        ...baseProfile,
        posts: userPostsCount, // 使用真實的發布文章數量
        following: followingCount,
        followers: followersCount
      };
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: true,
        user: profile
      }));
    } else {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: '用戶不存在' }));
    }
    
  } else if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'OK', 
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    }));
  } else if (req.url === '/online_test.html') {
    // 提供測試頁面
    const htmlContent = `
<!DOCTYPE html>
<html>
<head>
    <title>Flutter API 在線測試</title>
    <meta charset="utf-8">
</head>
<body>
    <h1>Flutter API 在線測試</h1>
    <p>服務器運行在: http://localhost:8080</p>
    
    <button onclick="testRegister()">測試註冊API</button>
    <button onclick="testLogin()">測試登入API</button>
    <button onclick="testHealth()">測試健康檢查</button>
    
    <div id="result"></div>

    <script>
        async function testRegister() {
            const resultDiv = document.getElementById('result');
            resultDiv.innerHTML = '<p>測試註冊API中...</p>';
            
            try {
                const response = await fetch('/api/auth/register', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        email: 'test@example.com',
                        password: '123456',
                        nickname: '測試用戶',
                        realName: '王小明',
                        idCardNumber: 'A123456789'
                    })
                });
                
                const data = await response.json();
                resultDiv.innerHTML = \`<h3>✅ 註冊API測試成功！</h3><p>狀態碼: \${response.status}</p><pre>\${JSON.stringify(data, null, 2)}</pre>\`;
            } catch (error) {
                resultDiv.innerHTML = \`<h3>❌ 註冊API測試失敗</h3><p>錯誤: \${error.message}</p>\`;
            }
        }

        async function testLogin() {
            const resultDiv = document.getElementById('result');
            resultDiv.innerHTML = '<p>測試登入API中...</p>';
            
            try {
                const response = await fetch('/api/auth/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        email: 'test@example.com',
                        password: '123456'
                    })
                });
                
                const data = await response.json();
                resultDiv.innerHTML = \`<h3>✅ 登入API測試成功！</h3><p>狀態碼: \${response.status}</p><pre>\${JSON.stringify(data, null, 2)}</pre>\`;
            } catch (error) {
                resultDiv.innerHTML = \`<h3>❌ 登入API測試失敗</h3><p>錯誤: \${error.message}</p>\`;
            }
        }

        async function testHealth() {
            const resultDiv = document.getElementById('result');
            resultDiv.innerHTML = '<p>測試健康檢查中...</p>';
            
            try {
                const response = await fetch('/health');
                const data = await response.json();
                resultDiv.innerHTML = \`<h3>✅ 健康檢查成功！</h3><p>狀態碼: \${response.status}</p><pre>\${JSON.stringify(data, null, 2)}</pre>\`;
            } catch (error) {
                resultDiv.innerHTML = \`<h3>❌ 健康檢查失敗</h3><p>錯誤: \${error.message}</p>\`;
            }
        }
    </script>
</body>
</html>`;
    
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(htmlContent);
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

const PORT = 8080;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 簡單HTTP服務器運行在端口 ${PORT}`);
  console.log(`📍 服務地址: http://localhost:${PORT}`);
  console.log(`📍 網絡地址: http://0.0.0.0:${PORT}`);
  console.log(`💚 健康檢查: http://localhost:${PORT}/health`);
  console.log(`🧪 測試註冊: http://localhost:${PORT}/api/auth/register`);
});
