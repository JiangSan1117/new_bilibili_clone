// lib/models/user_model.dart

enum VerificationStatus {
  unverified,    // 未驗證
  pending,       // 審核中
  verified,      // 已驗證
  rejected,      // 被拒絕
}

enum MembershipType {
  free,          // 免費會員
  verified,      // 實名會員
  premium,       // 高級會員
  vip,          // VIP會員
}

class User {
  final String id;
  final String nickname;
  final String avatarUrl;
  final int levelNum;
  final int collections;
  final int follows;
  final int friends;
  final int posts;
  final String? email;
  final String? phone;
  final String? location;
  
  // 實名制相關字段
  final String? realName;           // 真實姓名
  final String? idCardNumber;       // 身份證號碼（加密存儲）
  final VerificationStatus verificationStatus; // 驗證狀態
  final MembershipType membershipType;         // 會員類型
  final DateTime? verificationDate;            // 驗證日期
  final String? verificationNotes;             // 驗證備註

  User({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    required this.levelNum,
    required this.collections,
    required this.follows,
    required this.friends,
    required this.posts,
    this.email,
    this.phone,
    this.location,
    this.realName,
    this.idCardNumber,
    this.verificationStatus = VerificationStatus.unverified,
    this.membershipType = MembershipType.free,
    this.verificationDate,
    this.verificationNotes,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      nickname: map['nickname'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      levelNum: map['level_num'] ?? map['levelNum'] ?? 1,
      collections: map['collections'] ?? 0,
      follows: map['follows'] ?? 0,
      friends: map['friends'] ?? 0,
      posts: map['posts'] ?? 0,
      email: map['email'],
      phone: map['phone'],
      location: map['location'],
      realName: map['realName'],
      idCardNumber: map['idCardNumber'],
      verificationStatus: _parseVerificationStatus(map['verificationStatus']),
      membershipType: _parseMembershipType(map['membershipType']),
      verificationDate: map['verificationDate'] != null 
          ? DateTime.parse(map['verificationDate']) 
          : null,
      verificationNotes: map['verificationNotes'],
    );
  }

  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status) {
      case 'unverified': return VerificationStatus.unverified;
      case 'pending': return VerificationStatus.pending;
      case 'verified': return VerificationStatus.verified;
      case 'rejected': return VerificationStatus.rejected;
      default: return VerificationStatus.unverified;
    }
  }

  static MembershipType _parseMembershipType(String? type) {
    switch (type) {
      case 'free': return MembershipType.free;
      case 'verified': return MembershipType.verified;
      case 'premium': return MembershipType.premium;
      case 'vip': return MembershipType.vip;
      default: return MembershipType.free;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'level_num': levelNum,
      'collections': collections,
      'follows': follows,
      'friends': friends,
      'posts': posts,
      'email': email,
      'phone': phone,
      'location': location,
      'realName': realName,
      'idCardNumber': idCardNumber,
      'verificationStatus': verificationStatus.name,
      'membershipType': membershipType.name,
      'verificationDate': verificationDate?.toIso8601String(),
      'verificationNotes': verificationNotes,
    };
  }

  User copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    int? levelNum,
    int? collections,
    int? follows,
    int? friends,
    int? posts,
    String? email,
    String? phone,
    String? location,
    String? realName,
    String? idCardNumber,
    VerificationStatus? verificationStatus,
    MembershipType? membershipType,
    DateTime? verificationDate,
    String? verificationNotes,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      levelNum: levelNum ?? this.levelNum,
      collections: collections ?? this.collections,
      follows: follows ?? this.follows,
      friends: friends ?? this.friends,
      posts: posts ?? this.posts,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      realName: realName ?? this.realName,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      membershipType: membershipType ?? this.membershipType,
      verificationDate: verificationDate ?? this.verificationDate,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }

  String get displayId => 'ID: $id';

  @override
  String toString() {
    return 'User(nickname: $nickname, level: $levelNum)';
  }
}
