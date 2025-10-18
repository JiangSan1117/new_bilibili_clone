const mongoose = require('mongoose');

const interactionSchema = new mongoose.Schema({
  // 互動者
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // 目標對象
  targetType: {
    type: String,
    enum: ['post', 'user', 'comment'],
    required: true
  },
  targetId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  
  // 互動類型
  actionType: {
    type: String,
    enum: ['like', 'comment', 'follow', 'share', 'report'],
    required: true
  },
  
  // 互動內容
  content: {
    type: String,
    maxlength: 1000,
    default: ''
  },
  
  // 額外資料
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  
  // 狀態
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// 複合索引：確保用戶對同一目標只能有一種互動類型
interactionSchema.index({ 
  user: 1, 
  targetType: 1, 
  targetId: 1, 
  actionType: 1 
}, { unique: true });

// 索引：快速查找用戶的互動記錄
interactionSchema.index({ user: 1, createdAt: -1 });
interactionSchema.index({ targetType: 1, targetId: 1, actionType: 1 });

// 靜態方法：點讚/取消點讚
interactionSchema.statics.toggleLike = async function(userId, targetType, targetId) {
  const existing = await this.findOne({
    user: userId,
    targetType,
    targetId,
    actionType: 'like'
  });
  
  if (existing) {
    // 取消點讚
    await existing.deleteOne();
    return { action: 'unliked', interaction: null };
  } else {
    // 新增點讚
    const interaction = await this.create({
      user: userId,
      targetType,
      targetId,
      actionType: 'like'
    });
    return { action: 'liked', interaction };
  }
};

// 靜態方法：關注/取消關注
interactionSchema.statics.toggleFollow = async function(userId, targetUserId) {
  const existing = await this.findOne({
    user: userId,
    targetType: 'user',
    targetId: targetUserId,
    actionType: 'follow'
  });
  
  if (existing) {
    // 取消關注
    await existing.deleteOne();
    return { action: 'unfollowed', interaction: null };
  } else {
    // 新增關注
    const interaction = await this.create({
      user: userId,
      targetType: 'user',
      targetId: targetUserId,
      actionType: 'follow'
    });
    return { action: 'followed', interaction };
  }
};

// 靜態方法：添加評論
interactionSchema.statics.addComment = async function(userId, targetType, targetId, content) {
  const interaction = await this.create({
    user: userId,
    targetType,
    targetId,
    actionType: 'comment',
    content
  });
  
  // 填充用戶信息
  await interaction.populate('user', 'nickname avatar');
  return interaction;
};

// 靜態方法：獲取目標的互動統計
interactionSchema.statics.getStats = async function(targetType, targetId) {
  const stats = await this.aggregate([
    {
      $match: {
        targetType,
        targetId,
        isActive: true
      }
    },
    {
      $group: {
        _id: '$actionType',
        count: { $sum: 1 }
      }
    }
  ]);
  
  const result = {
    likes: 0,
    comments: 0,
    shares: 0,
    follows: 0
  };
  
  stats.forEach(stat => {
    result[stat._id + 's'] = stat.count;
  });
  
  return result;
};

module.exports = mongoose.model('Interaction', interactionSchema);



