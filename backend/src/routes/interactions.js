const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { validate } = require('../utils/validation');
const { commentSchema } = require('../utils/validation');

// 暫時的互動控制器（將在後續創建）
const interactionController = {
  toggleLike: async (req, res) => {
    res.json({ message: '點讚功能開發中' });
  },
  addComment: async (req, res) => {
    res.json({ message: '評論功能開發中' });
  },
  getComments: async (req, res) => {
    res.json({ message: '獲取評論列表功能開發中' });
  },
  toggleFollow: async (req, res) => {
    res.json({ message: '關注功能開發中' });
  },
  sharePost: async (req, res) => {
    res.json({ message: '分享功能開發中' });
  }
};

// 點讚/取消點讚文章
router.post('/posts/:id/like', authenticateToken, interactionController.toggleLike);

// 評論文章
router.post('/posts/:id/comment', authenticateToken, validate(commentSchema), interactionController.addComment);

// 獲取文章評論
router.get('/posts/:id/comments', interactionController.getComments);

// 關注/取消關注用戶
router.post('/users/:id/follow', authenticateToken, interactionController.toggleFollow);

// 分享文章
router.post('/posts/:id/share', authenticateToken, interactionController.sharePost);

module.exports = router;



