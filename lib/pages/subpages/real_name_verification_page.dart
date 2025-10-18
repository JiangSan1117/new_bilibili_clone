// lib/pages/subpages/real_name_verification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../../services/data_service.dart';
import '../../services/verification_service.dart';

class RealNameVerificationPage extends StatefulWidget {
  const RealNameVerificationPage({super.key});

  @override
  State<RealNameVerificationPage> createState() => _RealNameVerificationPageState();
}

class _RealNameVerificationPageState extends State<RealNameVerificationPage> {
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  
  User? _currentUser;
  bool _isSubmitting = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await DataService.getCurrentUser();
      setState(() {
        _currentUser = user;
        if (user?.realName != null) {
          _realNameController.text = user!.realName!;
        }
      });
    } catch (e) {
      debugPrint('載入用戶數據失敗: $e');
    }
  }

  bool _validateIdCard(String idCard) {
    return VerificationService.validateIdCard(idCard);
  }

  Future<void> _submitVerification() async {
    if (_realNameController.text.trim().isEmpty) {
      _showSnackBar('請輸入真實姓名', isError: true);
      return;
    }
    
    if (_idCardController.text.trim().isEmpty) {
      _showSnackBar('請輸入身份證號碼', isError: true);
      return;
    }
    
    if (!_validateIdCard(_idCardController.text.trim())) {
      _showSnackBar('身份證號碼格式不正確', isError: true);
      return;
    }
    
    if (!_agreeToTerms) {
      _showSnackBar('請同意實名制條款', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 使用驗證服務提交申請
      final result = await VerificationService.submitVerification(
        userId: _currentUser?.id ?? '',
        realName: _realNameController.text.trim(),
        idCardNumber: _idCardController.text.trim(),
      );
      
      if (result.success) {
        // 更新用戶信息
        if (_currentUser != null) {
          final updatedUser = _currentUser!.copyWith(
            realName: _realNameController.text.trim(),
            idCardNumber: VerificationService.encryptIdCard(_idCardController.text.trim()),
            verificationStatus: result.status,
            membershipType: result.status == VerificationStatus.verified 
                ? MembershipType.verified 
                : _currentUser!.membershipType,
            verificationDate: result.status == VerificationStatus.verified 
                ? DateTime.now() 
                : _currentUser!.verificationDate,
            verificationNotes: result.message,
          );
          
          await DataService.updateUser(updatedUser);
        }
        
        _showSnackBar(result.message, isError: false);
        
        // 返回上一頁
        Navigator.of(context).pop();
      } else {
        _showSnackBar(result.message, isError: true);
      }
      
    } catch (e) {
      _showSnackBar('提交失敗，請稍後再試', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_currentUser == null) return const SizedBox();
    
    final status = _currentUser!.verificationStatus;
    final membership = _currentUser!.membershipType;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case VerificationStatus.unverified:
        statusColor = Colors.grey;
        statusText = '未驗證';
        statusIcon = Icons.person_off;
        break;
      case VerificationStatus.pending:
        statusColor = Colors.orange;
        statusText = '審核中';
        statusIcon = Icons.pending;
        break;
      case VerificationStatus.verified:
        statusColor = Colors.green;
        statusText = '已驗證';
        statusIcon = Icons.verified_user;
        break;
      case VerificationStatus.rejected:
        statusColor = Colors.red;
        statusText = '被拒絕';
        statusIcon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '驗證狀態：$statusText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '會員類型：${_getMembershipTypeText(membership)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_currentUser!.verificationDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '驗證日期：${_formatDate(_currentUser!.verificationDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMembershipTypeText(MembershipType type) {
    switch (type) {
      case MembershipType.free: return '免費會員';
      case MembershipType.verified: return '實名會員';
      case MembershipType.premium: return '高級會員';
      case MembershipType.vip: return 'VIP會員';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('實名認證'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_currentUser?.verificationStatus == VerificationStatus.unverified)
            TextButton(
              onPressed: _isSubmitting ? null : _submitVerification,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '提交',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 狀態卡片
            _buildStatusCard(),
            
            const SizedBox(height: 24),
            
            // 說明信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '實名認證說明',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 實名認證後可享受更多會員權益\n'
                          '• 請確保信息真實有效\n'
                          '• 審核時間約1-3個工作日\n'
                          '• 您的個人信息將受到嚴格保護',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 表單區域
            if (_currentUser?.verificationStatus == VerificationStatus.unverified) ...[
              Text(
                '認證信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 真實姓名
              TextField(
                controller: _realNameController,
                decoration: InputDecoration(
                  labelText: '真實姓名',
                  hintText: '請輸入您的真實姓名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 身份證號碼
              TextField(
                controller: _idCardController,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: '身份證號碼',
                  hintText: '請輸入身份證號碼',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                maxLength: 10,
              ),
              
              const SizedBox(height: 16),
              
              // 同意條款
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreeToTerms = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: Text(
                          '我同意《實名制條款》和《隱私政策》，並確認提供的信息真實有效',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 提交按鈕
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitVerification,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user),
                  label: Text(_isSubmitting ? '提交中...' : '提交認證'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (_currentUser?.verificationStatus == VerificationStatus.pending) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.pending,
                      size: 48,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '審核中',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '您的實名認證申請正在審核中，請耐心等待。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else if (_currentUser?.verificationStatus == VerificationStatus.verified) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 48,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '認證成功',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '恭喜！您已成功完成實名認證，可享受更多會員權益。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else if (_currentUser?.verificationStatus == VerificationStatus.rejected) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 48,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '認證被拒絕',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '您的實名認證申請被拒絕，請檢查信息是否正確或聯繫客服。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentUser?.verificationNotes != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '拒絕原因：${_currentUser!.verificationNotes}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 自定義文本格式化器，自動轉換為大寫
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
