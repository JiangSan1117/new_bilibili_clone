const express = require('express');
const router = express.Router();
const { authenticateToken, optionalAuth } = require('../middleware/auth');
const { validate, validateQuery } = require('../utils/validation');
const { createPostSchema, searchSchema } = require('../utils/validation');

// 暫時的文章控制器（將在後續創建）
const postController = {
  createPost: async (req, res) => {
    res.json({ message: '文章創建功能開發中' });
  },
  getPosts: async (req, res) => {
    res.json({ message: '獲取文章列表功能開發中' });
  },
  getPostById: async (req, res) => {
    res.json({ message: '獲取單篇文章功能開發中' });
  },
  updatePost: async (req, res) => {
    res.json({ message: '文章更新功能開發中' });
  },
  deletePost: async (req, res) => {
    res.json({ message: '文章刪除功能開發中' });
  },
  searchPosts: async (req, res) => {
    res.json({ message: '文章搜索功能開發中' });
  },
  getPostsByCategory: async (req, res) => {
    res.json({ message: '按分類獲取文章功能開發中' });
  }
};

// 創建文章
router.post('/', authenticateToken, validate(createPostSchema), postController.createPost);

// 獲取文章列表
router.get('/', optionalAuth, postController.getPosts);

// 搜索文章
router.get('/search', optionalAuth, validateQuery(searchSchema), postController.searchPosts);

// 按分類獲取文章
router.get('/category/:category', optionalAuth, postController.getPostsByCategory);

// 獲取單篇文章
router.get('/:id', optionalAuth, postController.getPostById);

// 更新文章
router.put('/:id', authenticateToken, postController.updatePost);

// 刪除文章
router.delete('/:id', authenticateToken, postController.deletePost);

module.exports = router;



