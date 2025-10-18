const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { isTestMode, getMockUser } = require('../middleware/testMode');

// 生成JWT令牌
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// 用戶註冊
const register = async (req, res) => {
  try {
    const { email, password, nickname, realName, idCardNumber } = req.body;
    
    // 測試模式
    if (isTestMode()) {
      const token = generateToken('507f1f77bcf86cd799439011');
      const mockUser = getMockUser();
      
      return res.status(201).json({
        message: '註冊成功 (測試模式)',
        token,
        user: {
          id: mockUser._id,
          email: email,
          nickname: nickname,
          avatar: mockUser.avatar,
          verificationStatus: 'verified',
          membershipType: 'verified',
          levelNum: mockUser.levelNum
        }
      });
    }
    
    // 檢查電子郵件是否已存在
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        error: '該電子郵件已被註冊',
        code: 'EMAIL_EXISTS'
      });
    }
    
    // 檢查暱稱是否已存在
    const existingNickname = await User.findOne({ nickname });
    if (existingNickname) {
      return res.status(400).json({
        error: '該暱稱已被使用',
        code: 'NICKNAME_EXISTS'
      });
    }
    
    // 創建新用戶
    const user = new User({
      email,
      password,
      nickname,
      realName,
      idCardNumber,
      verificationStatus: 'pending',
      membershipType: 'free'
    });
    
    await user.save();
    
    // 生成令牌
    const token = generateToken(user._id);
    
    // 更新最後登入時間
    user.lastLoginAt = new Date();
    await user.save();
    
    res.status(201).json({
      message: '註冊成功',
      token,
      user: {
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        verificationStatus: user.verificationStatus,
        membershipType: user.membershipType,
        levelNum: user.levelNum
      }
    });
    
  } catch (error) {
    console.error('註冊錯誤:', error);
    res.status(500).json({
      error: '註冊失敗',
      message: '請稍後再試'
    });
  }
};

// 用戶登入
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // 測試模式
    if (isTestMode()) {
      const token = generateToken('507f1f77bcf86cd799439011');
      const mockUser = getMockUser();
      
      return res.json({
        message: '登入成功 (測試模式)',
        token,
        user: {
          id: mockUser._id,
          email: email,
          nickname: mockUser.nickname,
          avatar: mockUser.avatar,
          verificationStatus: mockUser.verificationStatus,
          membershipType: mockUser.membershipType,
          levelNum: mockUser.levelNum,
          posts: mockUser.posts,
          followers: mockUser.followers,
          following: mockUser.following,
          likes: mockUser.likes
        }
      });
    }
    
    // 查找用戶
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        error: '電子郵件或密碼錯誤',
        code: 'INVALID_CREDENTIALS'
      });
    }
    
    // 檢查用戶是否被停用
    if (!user.isActive) {
      return res.status(401).json({
        error: '帳戶已被停用',
        code: 'ACCOUNT_DISABLED'
      });
    }
    
    // 驗證密碼
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        error: '電子郵件或密碼錯誤',
        code: 'INVALID_CREDENTIALS'
      });
    }
    
    // 生成令牌
    const token = generateToken(user._id);
    
    // 更新最後登入時間
    user.lastLoginAt = new Date();
    await user.save();
    
    res.json({
      message: '登入成功',
      token,
      user: {
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        verificationStatus: user.verificationStatus,
        membershipType: user.membershipType,
        levelNum: user.levelNum,
        posts: user.posts,
        followers: user.followers,
        following: user.following,
        likes: user.likes
      }
    });
    
  } catch (error) {
    console.error('登入錯誤:', error);
    res.status(500).json({
      error: '登入失敗',
      message: '請稍後再試'
    });
  }
};

// 用戶登出
const logout = async (req, res) => {
  try {
    // 由於使用JWT，登出主要是客戶端刪除token
    // 這裡可以實現token黑名單機制（可選）
    res.json({
      message: '登出成功'
    });
  } catch (error) {
    console.error('登出錯誤:', error);
    res.status(500).json({
      error: '登出失敗',
      message: '請稍後再試'
    });
  }
};

// 獲取當前用戶信息
const getProfile = async (req, res) => {
  try {
    // 測試模式
    if (isTestMode()) {
      const mockUser = getMockUser();
      return res.json({
        user: {
          id: mockUser._id,
          email: 'test@example.com',
          nickname: mockUser.nickname,
          avatar: mockUser.avatar,
          realName: mockUser.realName,
          verificationStatus: mockUser.verificationStatus,
          membershipType: mockUser.membershipType,
          levelNum: mockUser.levelNum,
          posts: mockUser.posts,
          followers: mockUser.followers,
          following: mockUser.following,
          likes: mockUser.likes,
          phone: mockUser.phone,
          location: mockUser.location,
          createdAt: mockUser.createdAt,
          lastLoginAt: mockUser.lastLoginAt
        }
      });
    }
    
    const user = await User.findById(req.user._id)
      .select('-password -idCardNumber');
    
    if (!user) {
      return res.status(404).json({
        error: '用戶不存在',
        code: 'USER_NOT_FOUND'
      });
    }
    
    res.json({
      user: {
        id: user._id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        realName: user.realName,
        verificationStatus: user.verificationStatus,
        membershipType: user.membershipType,
        levelNum: user.levelNum,
        posts: user.posts,
        followers: user.followers,
        following: user.following,
        likes: user.likes,
        phone: user.phone,
        location: user.location,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt
      }
    });
  } catch (error) {
    console.error('獲取用戶信息錯誤:', error);
    res.status(500).json({
      error: '獲取用戶信息失敗',
      message: '請稍後再試'
    });
  }
};

// 刷新令牌
const refreshToken = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user || !user.isActive) {
      return res.status(401).json({
        error: '用戶無效',
        code: 'USER_INVALID'
      });
    }
    
    const token = generateToken(user._id);
    
    res.json({
      message: '令牌刷新成功',
      token
    });
  } catch (error) {
    console.error('刷新令牌錯誤:', error);
    res.status(500).json({
      error: '刷新令牌失敗',
      message: '請稍後再試'
    });
  }
};

// 忘記密碼
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    
    const user = await User.findOne({ email });
    if (!user) {
      // 為了安全，不透露用戶是否存在
      return res.json({
        message: '如果該電子郵件存在，我們已發送密碼重置鏈接'
      });
    }
    
    // 這裡應該發送密碼重置郵件
    // 實際實現需要郵件服務（如SendGrid、AWS SES等）
    console.log(`密碼重置請求 - 用戶: ${email}`);
    
    res.json({
      message: '如果該電子郵件存在，我們已發送密碼重置鏈接'
    });
  } catch (error) {
    console.error('忘記密碼錯誤:', error);
    res.status(500).json({
      error: '請求失敗',
      message: '請稍後再試'
    });
  }
};

// 重置密碼
const resetPassword = async (req, res) => {
  try {
    const { token, newPassword } = req.body;
    
    // 這裡應該驗證重置令牌
    // 實際實現需要存儲重置令牌到數據庫
    
    res.json({
      message: '密碼重置功能需要實現郵件服務'
    });
  } catch (error) {
    console.error('重置密碼錯誤:', error);
    res.status(500).json({
      error: '重置失敗',
      message: '請稍後再試'
    });
  }
};

module.exports = {
  register,
  login,
  logout,
  getProfile,
  refreshToken,
  forgotPassword,
  resetPassword
};
