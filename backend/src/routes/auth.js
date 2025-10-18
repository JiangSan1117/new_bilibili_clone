const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { validate } = require('../utils/validation');
const { 
  registerSchema, 
  loginSchema 
} = require('../utils/validation');
const {
  register,
  login,
  logout,
  getProfile,
  refreshToken,
  forgotPassword,
  resetPassword
} = require('../controllers/authController');

// 用戶註冊
router.post('/register', validate(registerSchema), register);

// 用戶登入
router.post('/login', validate(loginSchema), login);

// 用戶登出
router.post('/logout', authenticateToken, logout);

// 獲取當前用戶信息
router.get('/profile', authenticateToken, getProfile);

// 刷新令牌
router.post('/refresh', authenticateToken, refreshToken);

// 忘記密碼
router.post('/forgot-password', forgotPassword);

// 重置密碼
router.post('/reset-password', resetPassword);

module.exports = router;



