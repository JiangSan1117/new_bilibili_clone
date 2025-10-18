const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { validate, validateQuery } = require('../utils/validation');
const { updateProfileSchema } = require('../utils/validation');

// 暫時的用戶控制器（將在後續創建）
const userController = {
  updateProfile: async (req, res) => {
    res.json({ message: '用戶資料更新功能開發中' });
  },
  uploadAvatar: async (req, res) => {
    res.json({ message: '頭像上傳功能開發中' });
  },
  getUserById: async (req, res) => {
    res.json({ message: '獲取用戶信息功能開發中' });
  }
};

// 更新用戶資料
router.put('/profile', authenticateToken, validate(updateProfileSchema), userController.updateProfile);

// 上傳頭像
router.post('/avatar', authenticateToken, userController.uploadAvatar);

// 獲取其他用戶信息
router.get('/:id', authenticateToken, userController.getUserById);

module.exports = router;



