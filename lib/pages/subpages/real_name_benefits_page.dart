// lib/pages/subpages/real_name_benefits_page.dart

import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/data_service.dart';
import '../../services/verification_service.dart';
import 'real_name_verification_page.dart';

class RealNameBenefitsPage extends StatefulWidget {
  const RealNameBenefitsPage({super.key});

  @override
  State<RealNameBenefitsPage> createState() => _RealNameBenefitsPageState();
}

class _RealNameBenefitsPageState extends State<RealNameBenefitsPage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await DataService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      debugPrint('載入用戶數據失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('實名制會員權益'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 會員狀態卡片
          _buildMembershipStatusCard(),
          
          const SizedBox(height: 24),
          
          // 免費會員權益（僅作為參考，實際不允許）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_off, color: Colors.grey.shade600, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '免費會員（已停用）',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '本平台已全面實施實名制，所有用戶都必須完成身份驗證才能使用服務。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 實名會員權益
          _buildBenefitsCard(
            '實名會員',
            Colors.blue,
            Icons.verified_user,
            VerificationService.getMembershipBenefits(MembershipType.verified),
          ),
          
          const SizedBox(height: 16),
          
          // 高級會員權益
          _buildBenefitsCard(
            '高級會員',
            Colors.purple,
            Icons.star,
            VerificationService.getMembershipBenefits(MembershipType.premium),
          ),
          
          const SizedBox(height: 16),
          
          // VIP會員權益
          _buildBenefitsCard(
            'VIP會員',
            Colors.amber,
            Icons.diamond,
            VerificationService.getMembershipBenefits(MembershipType.vip),
          ),
          
          const SizedBox(height: 24),
          
          // 實名制說明（所有用戶都必須實名）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '重要提醒',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '本平台已全面實施強制實名制，所有用戶都必須在註冊時提供真實身份信息並通過驗證。未完成實名認證的用戶將無法使用任何服務功能。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 實名制說明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '實名制說明',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• 實名制有助於建立更安全、可信的社區環境\n'
                  '• 您的個人信息將受到嚴格保護，僅用於身份驗證\n'
                  '• 實名會員享有更多權益和優先服務\n'
                  '• 我們承諾不會將您的信息用於其他用途',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMembershipStatusCard() {
    if (_currentUser == null) return const SizedBox();
    
    final membership = _currentUser!.membershipType;
    final status = _currentUser!.verificationStatus;
    
    Color cardColor;
    String membershipText;
    IconData membershipIcon;
    
    switch (membership) {
      case MembershipType.free:
        cardColor = Colors.grey;
        membershipText = '免費會員';
        membershipIcon = Icons.person;
        break;
      case MembershipType.verified:
        cardColor = Colors.blue;
        membershipText = '實名會員';
        membershipIcon = Icons.verified_user;
        break;
      case MembershipType.premium:
        cardColor = Colors.purple;
        membershipText = '高級會員';
        membershipIcon = Icons.star;
        break;
      case MembershipType.vip:
        cardColor = Colors.amber;
        membershipText = 'VIP會員';
        membershipIcon = Icons.diamond;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.8), cardColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              membershipIcon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membershipText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (_currentUser!.realName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '真實姓名：${_currentUser!.realName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status == VerificationStatus.verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '已認證',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.unverified: return '未實名認證';
      case VerificationStatus.pending: return '審核中';
      case VerificationStatus.verified: return '已實名認證';
      case VerificationStatus.rejected: return '認證被拒絕';
    }
  }

  Widget _buildBenefitsCard(String title, Color color, IconData icon, List<String> benefits) {
    final isCurrentMembership = _currentUser?.membershipType.name == title.toLowerCase().replaceAll(' ', '_');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentMembership ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentMembership ? color : Colors.grey.shade300,
          width: isCurrentMembership ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (isCurrentMembership) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '當前',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // 導航到實名認證頁面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RealNameVerificationPage(),
            ),
          );
        },
        icon: const Icon(Icons.upgrade),
        label: const Text('立即升級為實名會員'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
