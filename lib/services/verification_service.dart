// lib/services/verification_service.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class VerificationService {
  static const String _encryptionKey = 'your_secret_key_here'; // 實際應用中應該從安全存儲獲取
  
  /// 驗證身份證號碼格式
  static bool validateIdCard(String idCard) {
    if (idCard.length != 10) return false;
    
    // 台灣身份證號碼驗證
    RegExp regex = RegExp(r'^[A-Z][0-9]{9}$');
    if (!regex.hasMatch(idCard)) return false;
    
    // 更詳細的驗證邏輯
    return _validateTaiwanIdCard(idCard);
  }
  
  /// 台灣身份證號碼詳細驗證
  static bool _validateTaiwanIdCard(String idCard) {
    // 台灣身份證號碼驗證算法
    const Map<String, int> letterValues = {
      'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15,
      'G': 16, 'H': 17, 'I': 34, 'J': 18, 'K': 19, 'L': 20,
      'M': 21, 'N': 22, 'O': 35, 'P': 23, 'Q': 24, 'R': 25,
      'S': 26, 'T': 27, 'U': 28, 'V': 29, 'W': 32, 'X': 30,
      'Y': 31, 'Z': 33
    };
    
    String letter = idCard[0];
    String numbers = idCard.substring(1);
    
    if (!letterValues.containsKey(letter)) return false;
    
    int letterValue = letterValues[letter]!;
    int sum = (letterValue ~/ 10) + (letterValue % 10) * 9;
    
    for (int i = 0; i < 8; i++) {
      sum += int.parse(numbers[i]) * (8 - i);
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(numbers[8]);
  }
  
  /// 加密身份證號碼
  static String encryptIdCard(String idCard) {
    if (kDebugMode) {
      // 在調試模式下不加密，便於測試
      return idCard;
    }
    
    var key = utf8.encode(_encryptionKey);
    var bytes = utf8.encode(idCard);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
  
  /// 解密身份證號碼
  static String decryptIdCard(String encryptedIdCard) {
    if (kDebugMode) {
      // 在調試模式下直接返回
      return encryptedIdCard;
    }
    
    // 實際應用中需要實現解密邏輯
    // 這裡簡化處理
    return encryptedIdCard;
  }
  
  /// 提交實名認證申請
  static Future<VerificationResult> submitVerification({
    required String userId,
    required String realName,
    required String idCardNumber,
  }) async {
    try {
      // 模擬API調用
      await Future.delayed(const Duration(seconds: 2));
      
      // 驗證身份證號碼
      if (!validateIdCard(idCardNumber)) {
        return VerificationResult(
          success: false,
          message: '身份證號碼格式不正確',
          status: VerificationStatus.rejected,
        );
      }
      
      // 模擬審核過程（實際應用中會調用後端API）
      bool isApproved = await _simulateVerificationProcess(realName, idCardNumber);
      
      // 強制實名制：所有註冊用戶都必須通過實名認證
      if (isApproved) {
        return VerificationResult(
          success: true,
          message: '實名認證申請已通過',
          status: VerificationStatus.verified,
        );
      } else {
        return VerificationResult(
          success: false,
          message: '實名認證申請被拒絕，請檢查身份證號碼是否正確',
          status: VerificationStatus.rejected,
        );
      }
      
    } catch (e) {
      return VerificationResult(
        success: false,
        message: '提交失敗，請稍後再試',
        status: VerificationStatus.unverified,
      );
    }
  }
  
  /// 模擬審核過程
  static Future<bool> _simulateVerificationProcess(String realName, String idCardNumber) async {
    // 模擬審核邏輯
    // 實際應用中這裡會調用政府身份驗證API或其他第三方服務
    
    // 簡單的模擬：如果身份證號碼以 'A' 開頭且長度正確，則通過
    return idCardNumber.startsWith('A') && idCardNumber.length == 10;
  }
  
  /// 獲取實名認證狀態
  static Future<VerificationStatus> getVerificationStatus(String userId) async {
    try {
      // 模擬API調用
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 實際應用中會從後端獲取狀態
      return VerificationStatus.verified;
    } catch (e) {
      return VerificationStatus.unverified;
    }
  }
  
  /// 獲取會員類型
  static Future<MembershipType> getMembershipType(String userId) async {
    try {
      // 模擬API調用
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 實際應用中會根據用戶的認證狀態和付費情況確定會員類型
      return MembershipType.verified;
    } catch (e) {
      return MembershipType.free;
    }
  }
  
  /// 檢查是否需要實名認證（強制實名制：所有用戶都需要）
  static bool requiresVerification(MembershipType membershipType) {
    switch (membershipType) {
      case MembershipType.free:
        return true; // 免費會員必須實名認證
      case MembershipType.verified:
      case MembershipType.premium:
      case MembershipType.vip:
        return false; // 已認證用戶不需要再次認證
    }
  }
  
  /// 獲取會員權益列表
  static List<String> getMembershipBenefits(MembershipType membershipType) {
    switch (membershipType) {
      case MembershipType.free:
        return [
          '基本文章瀏覽',
          '每日3篇發布限制',
          '基本搜索功能',
          '社區互動',
        ];
      case MembershipType.verified:
        return [
          '無限制文章發布',
          '高級搜索功能',
          '優先客服支持',
          '專屬標識顯示',
          '參與投票活動',
          '創建和管理群組',
        ];
      case MembershipType.premium:
        return [
          '實名會員所有權益',
          '無廣告瀏覽體驗',
          '高級數據分析',
          '優先內容推薦',
          '專屬主題和界面',
          '月度報告服務',
        ];
      case MembershipType.vip:
        return [
          '高級會員所有權益',
          '一對一專屬客服',
          '個性化定制服務',
          '線下活動邀請',
          '特殊徽章和稱號',
          '年度禮品贈送',
        ];
    }
  }
}

/// 實名認證結果
class VerificationResult {
  final bool success;
  final String message;
  final VerificationStatus status;
  final String? verificationId;
  final DateTime? submittedAt;
  
  VerificationResult({
    required this.success,
    required this.message,
    required this.status,
    this.verificationId,
    this.submittedAt,
  });
}
