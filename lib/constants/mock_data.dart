// lib/constants/mock_data.dart

const Map<String, dynamic> kMockUserData = {
  'nickname': '分享小天使',
  'id': 'ID: 123456',
  'level_num': 8, // 模擬會員等級
  'avatarUrl': 'https://picsum.photos/id/1005/200/200',
  'collections': 158,
  'follows': 99,
  'friends': 12,
  'posts': 45,
  'email': 'user@example.com',
  'phone': '0912-345-678',
  'location': '台北市',
  // 實名制相關字段
  'realName': '王小明',
  'idCardNumber': 'A123456789',
  'verificationStatus': 'verified',
  'membershipType': 'verified',
  'verificationDate': '2024-01-15T00:00:00.000Z',
  'verificationNotes': '身份驗證通過',
};

final List<Map<String, dynamic>> kMockPosts = [
  {
    'title': '今天在市集找到的古董相機！',
    'username': '小貓愛分享',
    'category': '電子產品',
    'mainTab': '交換',
    'likes': 480,
    'views': 12500,
    'city': '臺北市',
    'type': '二手'
  },
  {
    'title': '試做米其林三星甜點，結果大成功！',
    'username': '美食探險家',
    'category': '飲食',
    'mainTab': '分享',
    'likes': 120,
    'views': 8000,
    'city': '臺南市',
    'type': '食譜'
  },
  {
    'title': '三天兩夜環島路線規劃，分享我的避開人潮秘訣。',
    'username': '單車騎士',
    'category': '交通',
    'mainTab': '共享',
    'likes': 950,
    'views': 35000,
    'city': '全臺灣',
    'type': '遊記'
  },
  {
    'title': '自製手工皮革包教學，新手也能輕鬆完成。',
    'username': '手作達人Miya',
    'category': '穿著',
    'mainTab': '共同',
    'likes': 320,
    'views': 9200,
    'city': '新北市',
    'type': '教學'
  },
  // 增加更多 mock 數據以填充列表
  for (int i = 5; i < 20; i++)
    {
      'title': '關於 $i 月份的二手書籍交換清單',
      'username': '讀書人$i',
      'category': '教育',
      'mainTab': '交換',
      'likes': 50 + i,
      'views': 1000 + i * 10,
      'city': '台中市',
      'type': '二手'
    }
];

const List<String> kMessageInteractionTabs = ['回覆我的', '@我', '收到的讚', '系統通知'];
