const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { isTestMode, getMockUser } = require('./testMode');

// JWT認證中間件
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
      return res.status(401).json({ 
        error: '訪問令牌缺失',
        code: 'TOKEN_MISSING'
      });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // 測試模式
    if (isTestMode()) {
      req.user = getMockUser();
      return next();
    }
    
    // 檢查用戶是否存在且活躍
    const user = await User.findById(decoded.userId).select('-password');
    if (!user || !user.isActive) {
      return res.status(401).json({ 
        error: '用戶不存在或已被停用',
        code: 'USER_INVALID'
      });
    }
    
    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(403).json({ 
        error: '無效的訪問令牌',
        code: 'TOKEN_INVALID'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: '訪問令牌已過期',
        code: 'TOKEN_EXPIRED'
      });
    }
    
    console.error('認證錯誤:', error);
    res.status(500).json({ 
      error: '認證服務錯誤',
      code: 'AUTH_ERROR'
    });
  }
};

// 可選認證中間件（不會因為沒有token而失敗）
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId).select('-password');
      if (user && user.isActive) {
        req.user = user;
      }
    }
    
    next();
  } catch (error) {
    // 忽略認證錯誤，繼續執行
    next();
  }
};

// 檢查用戶角色權限
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        error: '需要認證',
        code: 'AUTH_REQUIRED'
      });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: '權限不足',
        code: 'INSUFFICIENT_PERMISSION'
      });
    }
    
    next();
  };
};

// 檢查實名認證狀態
const requireVerification = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: '需要認證',
      code: 'AUTH_REQUIRED'
    });
  }
  
  if (req.user.verificationStatus !== 'verified') {
    return res.status(403).json({ 
      error: '需要完成實名認證',
      code: 'VERIFICATION_REQUIRED'
    });
  }
  
  next();
};

// 速率限制中間件（針對特定操作）
const createRateLimit = (windowMs, maxRequests) => {
  return rateLimit({
    windowMs,
    max: maxRequests,
    message: {
      error: '請求過於頻繁，請稍後再試',
      code: 'RATE_LIMIT_EXCEEDED'
    },
    standardHeaders: true,
    legacyHeaders: false,
  });
};

module.exports = {
  authenticateToken,
  optionalAuth,
  requireRole,
  requireVerification,
  createRateLimit
};
