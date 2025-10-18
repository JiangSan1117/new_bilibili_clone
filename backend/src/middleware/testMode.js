// 測試模式中間件 - 當沒有MongoDB時提供模擬功能

const isTestMode = () => {
  return process.env.NODE_ENV === 'development' && process.env.MONGODB_URI === 'mongodb://localhost:27017/xiangxiang';
};

const testModeResponse = (req, res, next) => {
  if (isTestMode()) {
    req.testMode = true;
  }
  next();
};

const getMockUser = () => ({
  _id: '507f1f77bcf86cd799439011',
  email: 'test@example.com',
  nickname: '測試用戶',
  avatar: null,
  realName: '王小明',
  verificationStatus: 'verified',
  membershipType: 'verified',
  levelNum: 5,
  posts: 10,
  followers: 25,
  following: 15,
  likes: 100,
  phone: '0912-345-678',
  location: '台北市',
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date()
});

const getMockPosts = () => [
  {
    _id: '507f1f77bcf86cd799439012',
    title: '測試文章1 - 今天在市集找到的古董相機！',
    content: '這是一個測試文章的內容...',
    category: '電子產品',
    mainTab: '交換',
    type: '二手',
    city: '臺北市',
    images: ['https://picsum.photos/400/300?random=1'],
    videos: [],
    author: '507f1f77bcf86cd799439011',
    authorName: '測試用戶',
    likes: 48,
    views: 1250,
    comments: 5,
    shares: 2,
    status: 'published',
    isPinned: false,
    tags: ['相機', '古董', '市集'],
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '507f1f77bcf86cd799439013',
    title: '測試文章2 - 試做米其林三星甜點',
    content: '甜點製作過程分享...',
    category: '飲食',
    mainTab: '分享',
    type: '食譜',
    city: '臺南市',
    images: ['https://picsum.photos/400/300?random=2'],
    videos: [],
    author: '507f1f77bcf86cd799439011',
    authorName: '測試用戶',
    likes: 12,
    views: 800,
    comments: 3,
    shares: 1,
    status: 'published',
    isPinned: false,
    tags: ['甜點', '米其林', '食譜'],
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

const getMockMessages = () => [
  {
    _id: '507f1f77bcf86cd799439014',
    sender: '小貓愛分享',
    message: '謝謝你分享的古董相機資訊，超讚的！',
    time: '1分鐘前',
    isUnread: true,
    unreadCount: 2
  },
  {
    _id: '507f1f77bcf86cd799439015',
    sender: '攝影新手',
    message: '我想交換你的鏡頭，請問型號是？',
    time: '5分鐘前',
    isUnread: true,
    unreadCount: 1
  }
];

module.exports = {
  isTestMode,
  testModeResponse,
  getMockUser,
  getMockPosts,
  getMockMessages
};
