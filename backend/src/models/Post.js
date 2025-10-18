const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  // 基本資料
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  content: {
    type: String,
    required: true,
    trim: true,
    maxlength: 5000
  },
  
  // 分類資料
  category: {
    type: String,
    required: true,
    enum: ['飲食', '穿著', '居住', '交通', '教育', '娛樂']
  },
  mainTab: {
    type: String,
    required: true,
    enum: ['共享', '共同', '熱門', '分享', '交換']
  },
  type: {
    type: String,
    required: true,
    enum: ['二手', '食譜', '遊記', '教學', '指南', '地圖', '知識', '路線', '交換']
  },
  
  // 地理位置
  city: {
    type: String,
    required: true,
    trim: true
  },
  
  // 媒體文件
  images: [{
    type: String,
    validate: {
      validator: function(v) {
        return /\.(jpg|jpeg|png|gif|webp)$/i.test(v);
      },
      message: '圖片格式不支援'
    }
  }],
  videos: [{
    type: String,
    validate: {
      validator: function(v) {
        return /\.(mp4|mov|avi|mkv)$/i.test(v);
      },
      message: '視頻格式不支援'
    }
  }],
  
  // 作者資訊
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  authorName: {
    type: String,
    required: true
  },
  
  // 互動統計
  likes: {
    type: Number,
    default: 0
  },
  views: {
    type: Number,
    default: 0
  },
  comments: {
    type: Number,
    default: 0
  },
  shares: {
    type: Number,
    default: 0
  },
  
  // 狀態
  status: {
    type: String,
    enum: ['draft', 'published', 'archived', 'deleted'],
    default: 'published'
  },
  isPinned: {
    type: Boolean,
    default: false
  },
  
  // 標籤
  tags: [{
    type: String,
    trim: true
  }],
  
  // 地理位置（精確位置）
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [0, 0]
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 虛擬欄位：計算熱門度
postSchema.virtual('hotScore').get(function() {
  const now = new Date();
  const daysSinceCreation = (now - this.createdAt) / (1000 * 60 * 60 * 24);
  
  // 熱門度計算公式：點讚數 * 2 + 評論數 * 3 + 分享數 * 5 - 天數 * 0.1
  return (this.likes * 2 + this.comments * 3 + this.shares * 5) - (daysSinceCreation * 0.1);
});

// 索引
postSchema.index({ author: 1, createdAt: -1 });
postSchema.index({ category: 1, createdAt: -1 });
postSchema.index({ mainTab: 1, createdAt: -1 });
postSchema.index({ city: 1, createdAt: -1 });
postSchema.index({ status: 1, createdAt: -1 });
postSchema.index({ likes: -1, views: -1 });
postSchema.index({ location: '2dsphere' }); // 地理位置索引

// 文本搜索索引
postSchema.index({
  title: 'text',
  content: 'text',
  tags: 'text'
});

// 更新統計的中間件
postSchema.pre('save', function(next) {
  if (this.isNew) {
    // 新文章初始化統計
    this.likes = 0;
    this.views = 0;
    this.comments = 0;
    this.shares = 0;
  }
  next();
});

// 靜態方法：獲取熱門文章
postSchema.statics.getHotPosts = function(limit = 20, page = 1) {
  return this.find({ status: 'published' })
    .sort({ likes: -1, views: -1, createdAt: -1 })
    .populate('author', 'nickname avatar')
    .limit(limit * 1)
    .skip((page - 1) * limit);
};

// 靜態方法：搜索文章
postSchema.statics.searchPosts = function(query, options = {}) {
  const { category, mainTab, city, limit = 20, page = 1 } = options;
  
  let searchQuery = {
    status: 'published',
    $text: { $search: query }
  };
  
  if (category) searchQuery.category = category;
  if (mainTab) searchQuery.mainTab = mainTab;
  if (city) searchQuery.city = city;
  
  return this.find(searchQuery)
    .sort({ score: { $meta: 'textScore' }, createdAt: -1 })
    .populate('author', 'nickname avatar')
    .limit(limit * 1)
    .skip((page - 1) * limit);
};

module.exports = mongoose.model('Post', postSchema);



