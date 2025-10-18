// memory_server.js - 純內存數據庫服務器（無MongoDB依賴）

const express = require('express');
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

// 內存數據庫
const memoryDB = {
  users: [
    // 預設測試用戶
    {
      id: 'test_user_1',
      email: 'test@example.com',
      password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
      nickname: '測試用戶',
      avatar: 'https://picsum.photos/seed/test/100',
      levelNum: 5,
      isVerified: true,
      createdAt: new Date()
    }
  ],
  posts: [
    {
      id: 'post_1',
      title: '測試文章1',
      content: '這是測試文章內容',
      author: '測試用戶',
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
      shares: 5,
      tags: [],
      createdAt: new Date()
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
      shares: 2,
      tags: [],
      createdAt: new Date()
    }
  ],
  follows: [],
  comments: [
    {
      id: 'comment_1',
      post: 'post_1',
      author: 'test_user_1',
      content: '這是測試評論1',
      username: '測試用戶',
      userAvatar: 'https://picsum.photos/seed/user1/50',
      createdAt: new Date()
    },
    {
      id: 'comment_2',
      post: 'post_1',
      author: 'test_user_2',
      content: '這是測試評論2',
      username: '測試用戶2',
      userAvatar: 'https://picsum.photos/seed/user2/50',
      createdAt: new Date()
    }
  ],
  notifications: [
    {
      id: 'notif_1',
      user: 'test_user_1',
      type: 'like',
      title: '有人點讚了你的文章',
      content: '測試用戶2點讚了你的文章「測試文章1」',
      isRead: false,
      relatedUser: {
        nickname: '測試用戶2',
        avatar: 'https://picsum.photos/seed/user2/50'
      },
      relatedPost: {
        title: '測試文章1'
      },
      createdAt: new Date()
    },
    {
      id: 'notif_2',
      user: 'test_user_1',
      type: 'comment',
      title: '有人評論了你的文章',
      content: '測試用戶2評論了你的文章「測試文章1」',
      isRead: true,
      relatedUser: {
        nickname: '測試用戶2',
        avatar: 'https://picsum.photos/seed/user2/50'
      },
      relatedPost: {
        title: '測試文章1'
      },
      createdAt: new Date()
    }
  ],
  messages: [
    {
      id: 'msg_1',
      sender: 'test_user_2',
      receiver: 'test_user_1',
      content: '你好！看到你的文章很有趣，想了解更多細節。',
      isRead: false,
      senderName: '美食達人',
      senderAvatar: 'https://picsum.photos/seed/chef/100',
      createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000) // 2小時前
    },
    {
      id: 'msg_2',
      sender: 'test_user_1',
      receiver: 'test_user_2',
      content: '謝謝！有什麼想問的都可以問我。',
      isRead: true,
      senderName: '測試用戶1',
      senderAvatar: 'https://picsum.photos/seed/user1/100',
      createdAt: new Date(Date.now() - 1.5 * 60 * 60 * 1000) // 1.5小時前
    },
    {
      id: 'msg_3',
      sender: 'test_user_3',
      receiver: 'test_user_1',
      content: '請問那個相機的型號是什麼？我想交換。',
      isRead: false,
      senderName: '旅遊愛好者',
      senderAvatar: 'https://picsum.photos/seed/travel/100',
      createdAt: new Date(Date.now() - 30 * 60 * 1000) // 30分鐘前
    },
    {
      id: 'msg_4',
      sender: 'test_user_4',
      receiver: 'test_user_1',
      content: '你的食譜太棒了！下次試試看。',
      isRead: true,
      senderName: '科技達人',
      senderAvatar: 'https://picsum.photos/seed/tech/100',
      createdAt: new Date(Date.now() - 4 * 60 * 60 * 1000) // 4小時前
    }
  ]
};

// JWT密鑰
const JWT_SECRET = 'your-secret-key';

// 中間件：驗證JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: '需要登入' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = memoryDB.users.find(u => u.id === decoded.userId);
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
    const existingUser = memoryDB.users.find(u => u.email === email);
    if (existingUser) {
      return res.status(400).json({ error: '用戶已存在' });
    }

    // 加密密碼
    const hashedPassword = await bcrypt.hash(password, 10);

    // 創建用戶
    const user = {
      id: Date.now().toString(),
      email,
      password: hashedPassword,
      nickname,
      avatar: `https://picsum.photos/seed/${nickname}/100`,
      levelNum: 1,
      isVerified: false,
      createdAt: new Date()
    };
    
    memoryDB.users.push(user);
    
    // 生成JWT
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
    const user = memoryDB.users.find(u => u.email === email);
    if (!user) {
      return res.status(400).json({ error: '用戶不存在' });
    }

    // 驗證密碼
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(400).json({ error: '密碼錯誤' });
    }

    // 生成JWT
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
    const postsCount = memoryDB.posts.filter(p => p.authorId === user.id).length;
    const followersCount = memoryDB.follows.filter(f => f.following === user.id).length;
    const followingCount = memoryDB.follows.filter(f => f.follower === user.id).length;
    
    res.json({
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar,
      levelNum: user.levelNum,
      isVerified: user.isVerified,
      posts: postsCount,
      followers: followersCount,
      following: followingCount,
      collections: 0, // 暫時設為0
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

    const posts = memoryDB.posts
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(skip, skip + limit);

    const total = memoryDB.posts.length;

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

    memoryDB.posts.unshift(post); // 添加到開頭

    res.status(201).json({
      message: '文章發布成功',
      post
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
    const post = memoryDB.posts.find(p => p.id === postId);
    
    if (!post) {
      return res.status(404).json({ error: '文章不存在' });
    }

    // 簡單的點讚邏輯
    post.likes += 1;

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

    const comment = {
      id: Date.now().toString(),
      post: postId,
      author: req.user.id,
      content,
      username: req.user.nickname,
      userAvatar: req.user.avatar,
      createdAt: new Date()
    };

    memoryDB.comments.unshift(comment);

    // 更新文章評論數
    const post = memoryDB.posts.find(p => p.id === postId);
    if (post) {
      post.comments += 1;
    }

    res.json({
      message: '評論成功',
      comment
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
  } catch (error) {
    console.error('獲取評論錯誤:', error);
    res.status(500).json({ error: '獲取評論失敗' });
  }
});

// 關注/取消關注用戶
app.post('/api/interactions/users/:targetUserId/follow', authenticateToken, async (req, res) => {
  try {
    const targetUserId = req.params.targetUserId;
    const followerId = req.user.id;

    if (followerId === targetUserId) {
      return res.status(400).json({ error: '不能關注自己' });
    }

    // 檢查是否已經關注
    const existingFollowIndex = memoryDB.follows.findIndex(f => f.follower === followerId && f.following === targetUserId);
    
    if (existingFollowIndex !== -1) {
      // 取消關注
      memoryDB.follows.splice(existingFollowIndex, 1);
      res.json({
        message: '取消關注成功',
        isFollowing: false
      });
    } else {
      // 關注
      const follow = {
        id: Date.now().toString(),
        follower: followerId,
        following: targetUserId,
        createdAt: new Date()
      };

      memoryDB.follows.push(follow);

      // 創建通知
      const notification = {
        id: Date.now().toString(),
        user: targetUserId,
        type: 'follow',
        title: '有人關注了你',
        content: `${req.user.nickname}關注了你`,
        isRead: false,
        relatedUser: {
          nickname: req.user.nickname,
          avatar: req.user.avatar
        },
        createdAt: new Date()
      };
      memoryDB.notifications.push(notification);

      res.json({
        message: '關注成功',
        isFollowing: true
      });
    }
  } catch (error) {
    console.error('關注錯誤:', error);
    res.status(500).json({ error: '關注失敗' });
  }
});

// 檢查關注狀態
app.get('/api/users/:targetUserId/follow-status', authenticateToken, async (req, res) => {
  try {
    const targetUserId = req.params.targetUserId;
    const followerId = req.user.id;

    const isFollowing = memoryDB.follows.some(f => f.follower === followerId && f.following === targetUserId);

    res.json({
      isFollowing
    });
  } catch (error) {
    console.error('檢查關注狀態錯誤:', error);
    res.status(500).json({ error: '檢查關注狀態失敗' });
  }
});

// 獲取用戶關注列表
app.get('/api/users/:userId/following', async (req, res) => {
  try {
    const userId = req.params.userId;
    const following = memoryDB.follows.filter(f => f.follower === userId);

    res.json({
      users: following.map(follow => {
        const user = memoryDB.users.find(u => u.id === follow.following);
        return {
          id: user?.id || follow.following,
          nickname: user?.nickname || '未知用戶',
          avatar: user?.avatar || 'https://picsum.photos/seed/default/100',
          levelNum: user?.levelNum || 1,
          isVerified: user?.isVerified || false
        };
      })
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
    const followers = memoryDB.follows.filter(f => f.following === userId);

    res.json({
      users: followers.map(follow => {
        const user = memoryDB.users.find(u => u.id === follow.follower);
        return {
          id: user?.id || follow.follower,
          nickname: user?.nickname || '未知用戶',
          avatar: user?.avatar || 'https://picsum.photos/seed/default/100',
          levelNum: user?.levelNum || 1,
          isVerified: user?.isVerified || false
        };
      })
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
  } catch (error) {
    console.error('搜索錯誤:', error);
    res.status(500).json({ error: '搜索失敗' });
  }
});

// 分享文章
app.post('/api/interactions/posts/:postId/share', async (req, res) => {
  try {
    const postId = req.params.postId;
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
  } catch (error) {
    console.error('分享錯誤:', error);
    res.status(500).json({ error: '分享失敗' });
  }
});

// 獲取通知
app.get('/api/notifications', authenticateToken, async (req, res) => {
  try {
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
  } catch (error) {
    console.error('獲取通知錯誤:', error);
    res.status(500).json({ error: '獲取通知失敗' });
  }
});

// 標記所有通知為已讀
app.post('/api/notifications/mark-all-read', authenticateToken, async (req, res) => {
  try {
    memoryDB.notifications
      .filter(n => n.user === req.user.id)
      .forEach(n => n.isRead = true);
    
    res.json({ message: '所有通知已標記為已讀', success: true });
  } catch (error) {
    console.error('標記所有通知錯誤:', error);
    res.status(500).json({ error: '標記所有通知失敗' });
  }
});

// 刪除所有通知
app.delete('/api/notifications/delete-all', authenticateToken, async (req, res) => {
  try {
    memoryDB.notifications = memoryDB.notifications.filter(n => n.user !== req.user.id);
    
    res.json({ message: '所有通知已刪除', success: true });
  } catch (error) {
    console.error('刪除所有通知錯誤:', error);
    res.status(500).json({ error: '刪除所有通知失敗' });
  }
});

// ===== 訊息系統 API =====

// 獲取對話列表
app.get('/api/messages/conversations', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    // 獲取與當前用戶相關的所有訊息
    const userMessages = memoryDB.messages.filter(m => 
      m.sender === userId || m.receiver === userId
    );
    
    // 按對話對象分組
    const conversations = {};
    userMessages.forEach(message => {
      const otherUserId = message.sender === userId ? message.receiver : message.sender;
      const otherUserName = message.sender === userId ? '對方' : message.senderName || '未知用戶';
      const otherUserAvatar = message.sender === userId ? 'https://picsum.photos/seed/default/100' : message.senderAvatar || 'https://picsum.photos/seed/default/100';
      
      if (!conversations[otherUserId]) {
        conversations[otherUserId] = {
          id: otherUserId,
          participantId: otherUserId,
          participantName: otherUserName,
          participantAvatar: otherUserAvatar,
          lastMessage: message.content,
          lastMessageTime: message.createdAt,
          unreadCount: 0,
          isUnread: false
        };
      }
      
      // 更新最新訊息
      if (new Date(message.createdAt) > new Date(conversations[otherUserId].lastMessageTime)) {
        conversations[otherUserId].lastMessage = message.content;
        conversations[otherUserId].lastMessageTime = message.createdAt;
      }
      
      // 計算未讀數量（對方發送的訊息）
      if (message.receiver === userId && !message.isRead) {
        conversations[otherUserId].unreadCount++;
        conversations[otherUserId].isUnread = true;
      }
    });
    
    const conversationList = Object.values(conversations).sort((a, b) => 
      new Date(b.lastMessageTime) - new Date(a.lastMessageTime)
    );
    
    res.json({
      success: true,
      conversations: conversationList
    });
  } catch (error) {
    console.error('獲取對話列表錯誤:', error);
    res.status(500).json({ error: '獲取對話列表失敗' });
  }
});

// 創建新對話
app.post('/api/messages/conversations', authenticateToken, async (req, res) => {
  try {
    const { participantId } = req.body;
    
    if (!participantId) {
      return res.status(400).json({ error: '需要指定對話參與者' });
    }
    
    // 檢查對話是否已存在
    const existingConversation = memoryDB.messages.find(m => 
      (m.sender === req.user.id && m.receiver === participantId) ||
      (m.sender === participantId && m.receiver === req.user.id)
    );
    
    if (existingConversation) {
      return res.status(400).json({ error: '對話已存在' });
    }
    
    res.json({
      success: true,
      conversationId: `conv_${req.user.id}_${participantId}`,
      message: '對話創建成功'
    });
  } catch (error) {
    console.error('創建對話錯誤:', error);
    res.status(500).json({ error: '創建對話失敗' });
  }
});

// 獲取對話訊息
app.get('/api/messages/conversations/:conversationId/messages', authenticateToken, async (req, res) => {
  try {
    const conversationId = req.params.conversationId;
    const userId = req.user.id;
    
    // 解析對話ID獲取參與者
    const participants = conversationId.replace('conv_', '').split('_');
    const otherUserId = participants.find(id => id !== userId);
    
    if (!otherUserId) {
      return res.status(400).json({ error: '無效的對話ID' });
    }
    
    // 獲取該對話的所有訊息
    const messages = memoryDB.messages.filter(m => 
      ((m.sender === userId && m.receiver === otherUserId) ||
       (m.sender === otherUserId && m.receiver === userId))
    ).sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
    
    // 標記訊息為已讀
    messages.forEach(message => {
      if (message.receiver === userId) {
        message.isRead = true;
      }
    });
    
    res.json({
      success: true,
      messages: messages.map(message => ({
        id: message.id,
        sender: message.sender,
        receiver: message.receiver,
        content: message.content,
        isRead: message.isRead,
        createdAt: message.createdAt
      }))
    });
  } catch (error) {
    console.error('獲取對話訊息錯誤:', error);
    res.status(500).json({ error: '獲取對話訊息失敗' });
  }
});

// 發送訊息
app.post('/api/messages/conversations/:conversationId/messages', authenticateToken, async (req, res) => {
  try {
    const conversationId = req.params.conversationId;
    const { content } = req.body;
    const userId = req.user.id;
    
    if (!content || content.trim().isEmpty) {
      return res.status(400).json({ error: '訊息內容不能為空' });
    }
    
    // 解析對話ID獲取接收者
    const participants = conversationId.replace('conv_', '').split('_');
    const receiverId = participants.find(id => id !== userId);
    
    if (!receiverId) {
      return res.status(400).json({ error: '無效的對話ID' });
    }
    
    // 創建新訊息
    const message = {
      id: Date.now().toString(),
      sender: userId,
      receiver: receiverId,
      content: content.trim(),
      isRead: false,
      createdAt: new Date()
    };
    
    memoryDB.messages.push(message);
    
    // 創建通知
    const notification = {
      id: Date.now().toString(),
      user: receiverId,
      type: 'message',
      title: '收到新訊息',
      content: `${req.user.nickname}發送了訊息: ${content.substring(0, 20)}${content.length > 20 ? '...' : ''}`,
      isRead: false,
      relatedUser: {
        nickname: req.user.nickname,
        avatar: req.user.avatar
      },
      createdAt: new Date()
    };
    memoryDB.notifications.push(notification);
    
    res.json({
      success: true,
      message: {
        id: message.id,
        sender: message.sender,
        receiver: message.receiver,
        content: message.content,
        isRead: message.isRead,
        createdAt: message.createdAt
      }
    });
  } catch (error) {
    console.error('發送訊息錯誤:', error);
    res.status(500).json({ error: '發送訊息失敗' });
  }
});

// ===== 搜索系統 API =====

// 搜索文章
app.get('/api/search/posts', async (req, res) => {
  try {
    const { q: query, category, page = 1, limit = 20 } = req.query;
    
    if (!query || query.trim().isEmpty) {
      return res.status(400).json({ error: '搜索關鍵字不能為空' });
    }
    
    const searchQuery = query.trim().toLowerCase();
    let filteredPosts = memoryDB.posts;
    
    // 按關鍵字搜索
    filteredPosts = filteredPosts.filter(post => 
      post.title.toLowerCase().includes(searchQuery) ||
      post.content.toLowerCase().includes(searchQuery) ||
      post.author.toLowerCase().includes(searchQuery) ||
      post.category.toLowerCase().includes(searchQuery) ||
      post.city.toLowerCase().includes(searchQuery)
    );
    
    // 按分類過濾
    if (category && category !== 'all') {
      filteredPosts = filteredPosts.filter(post => 
        post.category === category
      );
    }
    
    // 排序（按創建時間降序）
    filteredPosts.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    
    // 分頁
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedPosts = filteredPosts.slice(startIndex, endIndex);
    
    res.json({
      success: true,
      posts: paginatedPosts,
      total: filteredPosts.length,
      page: parseInt(page),
      limit: parseInt(limit),
      query: searchQuery
    });
  } catch (error) {
    console.error('搜索文章錯誤:', error);
    res.status(500).json({ error: '搜索失敗' });
  }
});

// 搜索用戶
app.get('/api/search/users', async (req, res) => {
  try {
    const { q: query, page = 1, limit = 20 } = req.query;
    
    if (!query || query.trim().isEmpty) {
      return res.status(400).json({ error: '搜索關鍵字不能為空' });
    }
    
    const searchQuery = query.trim().toLowerCase();
    let filteredUsers = memoryDB.users;
    
    // 按關鍵字搜索
    filteredUsers = filteredUsers.filter(user => 
      user.nickname.toLowerCase().includes(searchQuery) ||
      user.email.toLowerCase().includes(searchQuery)
    );
    
    // 排序（按創建時間降序）
    filteredUsers.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    
    // 分頁
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedUsers = filteredUsers.slice(startIndex, endIndex);
    
    res.json({
      success: true,
      users: paginatedUsers,
      total: filteredUsers.length,
      page: parseInt(page),
      limit: parseInt(limit),
      query: searchQuery
    });
  } catch (error) {
    console.error('搜索用戶錯誤:', error);
    res.status(500).json({ error: '搜索失敗' });
  }
});

// 獲取熱門搜索關鍵字
app.get('/api/search/trending', async (req, res) => {
  try {
    // 模擬熱門搜索關鍵字
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

// 獲取搜索建議
app.get('/api/search/suggestions', async (req, res) => {
  try {
    const { q: query } = req.query;
    
    if (!query || query.trim().isEmpty) {
      return res.json({
        success: true,
        suggestions: []
      });
    }
    
    const searchQuery = query.trim().toLowerCase();
    
    // 從文章標題和分類中提取建議
    const suggestions = new Set();
    
    memoryDB.posts.forEach(post => {
      if (post.title.toLowerCase().includes(searchQuery)) {
        suggestions.add(post.title);
      }
      if (post.category.toLowerCase().includes(searchQuery)) {
        suggestions.add(post.category);
      }
    });
    
    memoryDB.users.forEach(user => {
      if (user.nickname.toLowerCase().includes(searchQuery)) {
        suggestions.add(user.nickname);
      }
    });
    
    const suggestionList = Array.from(suggestions).slice(0, 10);
    
    res.json({
      success: true,
      suggestions: suggestionList
    });
  } catch (error) {
    console.error('獲取搜索建議錯誤:', error);
    res.status(500).json({ error: '獲取搜索建議失敗' });
  }
});

// 啟動服務器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 內存數據庫服務器運行在 http://0.0.0.0:${PORT}`);
  console.log('📊 使用純內存數據庫（重啟後數據會丟失）');
  console.log('👤 預設測試帳號: test@example.com / 123456');
});

module.exports = app;
