const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // 基本資料
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, '請輸入有效的電子郵件地址']
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  nickname: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 20
  },
  avatar: {
    type: String,
    default: null
  },
  
  // 實名制資料
  realName: {
    type: String,
    required: true,
    trim: true
  },
  idCardNumber: {
    type: String,
    required: true,
    trim: true,
    match: [/^[A-Z][12]\d{8}$/, '請輸入有效的台灣身份證號碼']
  },
  verificationStatus: {
    type: String,
    enum: ['pending', 'verified', 'rejected'],
    default: 'pending'
  },
  membershipType: {
    type: String,
    enum: ['free', 'verified'],
    default: 'free'
  },
  verificationDate: {
    type: Date,
    default: null
  },
  verificationNotes: {
    type: String,
    default: ''
  },
  
  // 統計資料
  levelNum: {
    type: Number,
    default: 1,
    min: 1,
    max: 10
  },
  posts: {
    type: Number,
    default: 0
  },
  followers: {
    type: Number,
    default: 0
  },
  following: {
    type: Number,
    default: 0
  },
  likes: {
    type: Number,
    default: 0
  },
  
  // 聯絡資訊
  phone: {
    type: String,
    default: ''
  },
  location: {
    type: String,
    default: ''
  },
  
  // 系統欄位
  isActive: {
    type: Boolean,
    default: true
  },
  lastLoginAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true,
  toJSON: { 
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.idCardNumber;
      return ret;
    }
  }
});

// 密碼加密中間件
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// 密碼驗證方法
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// 更新統計資料
userSchema.methods.updateStats = function() {
  return this.save();
};

// 索引
userSchema.index({ email: 1 });
userSchema.index({ nickname: 1 });
userSchema.index({ verificationStatus: 1 });

module.exports = mongoose.model('User', userSchema);



