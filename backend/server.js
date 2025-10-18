const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 安全中間件
app.use(helmet());
app.use(compression());

// 速率限制
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分鐘
  max: 100, // 限制每個IP 15分鐘內最多100個請求
  message: '請求過於頻繁，請稍後再試'
});
app.use('/api/', limiter);

// CORS配置 - 允許所有本地開發
app.use(cors({
  origin: function (origin, callback) {
    // 允許所有本地開發端口和file://協議
    if (!origin || 
        origin.includes('localhost') || 
        origin.includes('127.0.0.1') ||
        origin.startsWith('file://')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  preflightContinue: false,
  optionsSuccessStatus: 204
}));

// 日誌中間件
app.use(morgan('combined'));

// 解析中間件
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 靜態文件服務
app.use('/uploads', express.static('uploads'));

// 數據庫連接
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/xiangxiang', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB連接成功'))
.catch(err => {
  console.warn('⚠️ MongoDB連接失敗，使用模擬模式:', err.message);
  console.log('💡 提示：安裝MongoDB或使用MongoDB Atlas進行完整功能測試');
});

// 路由
app.use('/api/auth', require('./src/routes/auth'));
app.use('/api/users', require('./src/routes/users'));
app.use('/api/posts', require('./src/routes/posts'));
app.use('/api/interactions', require('./src/routes/interactions'));
app.use('/api/messages', require('./src/routes/messages'));

// 健康檢查
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API文檔
app.get('/api/docs', (req, res) => {
  res.json({
    message: '想享APP API文檔',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      posts: '/api/posts',
      interactions: '/api/interactions',
      messages: '/api/messages'
    }
  });
});

// 404處理
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'API端點不存在',
    path: req.originalUrl 
  });
});

// 錯誤處理中間件
app.use((err, req, res, next) => {
  console.error('❌ 服務器錯誤:', err);
  
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: '數據驗證失敗',
      details: Object.values(err.errors).map(e => e.message)
    });
  }
  
  if (err.name === 'CastError') {
    return res.status(400).json({
      error: '無效的數據格式'
    });
  }
  
  res.status(500).json({
    error: '服務器內部錯誤',
    message: process.env.NODE_ENV === 'development' ? err.message : '請聯繫技術支持'
  });
});

// 啟動服務器
app.listen(PORT, () => {
  console.log(`🚀 想享APP後端服務啟動成功`);
  console.log(`📍 服務地址: http://localhost:${PORT}`);
  console.log(`📚 API文檔: http://localhost:${PORT}/api/docs`);
  console.log(`💚 健康檢查: http://localhost:${PORT}/health`);
});

module.exports = app;
