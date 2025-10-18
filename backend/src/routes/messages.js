const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// 暫時的訊息控制器（將在後續創建）
const messageController = {
  getMessages: async (req, res) => {
    res.json({ message: '獲取訊息列表功能開發中' });
  },
  sendMessage: async (req, res) => {
    res.json({ message: '發送訊息功能開發中' });
  },
  getConversation: async (req, res) => {
    res.json({ message: '獲取對話功能開發中' });
  },
  markAsRead: async (req, res) => {
    res.json({ message: '標記已讀功能開發中' });
  },
  getNotifications: async (req, res) => {
    res.json({ message: '獲取通知列表功能開發中' });
  },
  markAllAsRead: async (req, res) => {
    res.json({ message: '全部標記已讀功能開發中' });
  }
};

// 獲取訊息列表
router.get('/', authenticateToken, messageController.getMessages);

// 發送訊息
router.post('/', authenticateToken, messageController.sendMessage);

// 獲取特定對話
router.get('/:id', authenticateToken, messageController.getConversation);

// 標記訊息為已讀
router.put('/:id/read', authenticateToken, messageController.markAsRead);

// 獲取通知列表
router.get('/notifications/list', authenticateToken, messageController.getNotifications);

// 全部標記已讀
router.put('/notifications/read-all', authenticateToken, messageController.markAllAsRead);

module.exports = router;



