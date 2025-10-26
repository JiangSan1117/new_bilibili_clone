// lib/pages/subpages/basic_info_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/mock_data.dart';
import '../../services/real_api_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'profile_edit_page.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 檢查登入狀態
      final hasToken = await RealApiService.hasToken();

      if (hasToken) {
        // 如果有令牌，獲取用戶資料
        final result = await RealApiService.getCurrentUser();

        if (result['success'] == true && result['user'] != null) {
          final userData = result['user'];
          print('📥 BasicInfoPage._loadUserData: 收到用戶資料: $userData');
          print('📞 BasicInfoPage._loadUserData: 原始數據 - 電話: ${userData['phone']}, 地區: ${userData['location']}');
          
          // 🔧 修復：使用 User.fromMap 確保所有字段正確映射
          final user = User.fromMap(userData);

          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
          
          print('✅ BasicInfoPage._loadUserData: 用戶數據加載完成 - 電話: ${user.phone}, 地區: ${user.location}');
        } else {
          // 令牌無效，清除用戶資料
          setState(() {
            _currentUser = null;
            _isLoading = false;
          });
          print('❌ BasicInfoPage._loadUserData: 加載用戶數據失敗: ${result['error']}');
        }
      } else {
        // 沒有令牌，用戶未登入
        setState(() {
          _currentUser = null;
          _isLoading = false;
        });
        print('⚠️ BasicInfoPage._loadUserData: 用戶未登入');
      }
    } catch (e) {
      // 如果發生錯誤，清除用戶資料
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
      print('❌ BasicInfoPage._loadUserData: 加載用戶數據異常: $e');
    }
  }

  // 添加顯示 SnackBar 的方法
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 新增：合併用戶數據的方法
  User _mergeUserData(User currentUser, Map<String, dynamic> updatedData) {
    print('🔄 _mergeUserData: 開始合併用戶數據');
    print('🔄 當前用戶 - phone: ${currentUser.phone}, location: ${currentUser.location}');
    print('🔄 更新數據 - phone: ${updatedData['phone']}, location: ${updatedData['location']}');
    
    return User(
      id: currentUser.id,
      nickname: updatedData['nickname'] ?? currentUser.nickname,
      email: updatedData['email'] ?? currentUser.email,
      phone: updatedData['phone'] ?? currentUser.phone ?? '',
      location: updatedData['location'] ?? currentUser.location ?? '',
      avatarUrl: updatedData['avatar'] ?? updatedData['avatarUrl'] ?? currentUser.avatarUrl,
      levelNum: updatedData['levelNum'] ?? currentUser.levelNum,
      collections: updatedData['collections'] ?? currentUser.collections,
      follows: updatedData['follows'] ?? currentUser.follows,
      friends: updatedData['friends'] ?? currentUser.friends,
      posts: updatedData['posts'] ?? currentUser.posts,
      realName: updatedData['realName'] ?? currentUser.realName,
      idCardNumber: updatedData['idCardNumber'] ?? currentUser.idCardNumber,
      verificationStatus: (updatedData['isVerified'] == true || 
                          updatedData['verificationStatus'] == 'verified')
          ? VerificationStatus.verified
          : currentUser.verificationStatus,
      membershipType: (updatedData['membershipType'] == 'verified')
          ? MembershipType.verified
          : currentUser.membershipType,
      verificationDate: currentUser.verificationDate,
      verificationNotes: currentUser.verificationNotes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 如果未登入，顯示登入提示
        if (!authProvider.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('基本資料'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '請先登入',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '登入後即可查看基本資料',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // 已登入，顯示資料內容
        return Scaffold(
          appBar: AppBar(
            title: const Text('基本資料'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  print('🔄 BasicInfoPage: 手動刷新資料');
                  _loadUserData();
                },
                tooltip: '刷新資料',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context),
          bottomNavigationBar: _buildBottomEditButton(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final user = _currentUser ?? User.fromMap(kMockUserData);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頭像和基本信息
          _buildAvatarSection(user),
          const SizedBox(height: 20),
          
          // 基本信息
          _buildInfoSection(context, user),
          
          const SizedBox(height: 20),
          
          // 統計資料
          _buildStatsSection(context, user),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(User user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(user.avatarUrl ?? 'https://via.placeholder.com/150'),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            user.nickname,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${user.id.replaceAll('test_user_', '').replaceAll('ID:', '')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildInfoItem('電子郵件', user.email?.isNotEmpty == true ? user.email! : '未提供'),
        _buildInfoItem('電話號碼', user.phone?.isNotEmpty == true ? user.phone! : '未提供'),
        _buildInfoItem('所在地區', user.location?.isNotEmpty == true ? user.location! : '未提供'),
        
        _buildDivider(),
        
        _buildInfoItem('真實姓名', user.realName ?? '未提供'),
        _buildInfoItem('身分證號碼', user.idCardNumber ?? '未提供'),
        _buildInfoItem('認證狀態', user.verificationStatus.toString().split('.').last),
        _buildInfoItem('會員類型', user.membershipType.toString().split('.').last),
        _buildInfoItem('認證日期', user.verificationDate?.toLocal().toString().split(' ')[0] ?? '未提供'),
        _buildInfoItem('認證備註', user.verificationNotes ?? '無'),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildStatsSection(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '統計資料',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('發布', user.posts.toString()),
            _buildStatItem('收藏', user.collections.toString()),
            _buildStatItem('關注', user.follows.toString()),
            _buildStatItem('好友', user.friends.toString()),
          ],
        ),
        
        const SizedBox(height: 12),
        
        _buildInfoItem('會員等級', user.levelNum.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // 修復底部編輯按鈕
  Widget _buildBottomEditButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          print('🔄 BasicInfoPage: 打開編輯頁面');
          
          // 導航到編輯頁面並等待返回的用戶數據
          final updatedUser = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileEditPage()),
          );
          
          // 如果返回了更新後的用戶數據，立即更新界面
          if (updatedUser != null && updatedUser is Map<String, dynamic>) {
            print('🔄 BasicInfoPage: 收到更新後的用戶數據: $updatedUser');
            print('🔄 BasicInfoPage: 更新數據中的 phone=${updatedUser['phone']}, location=${updatedUser['location']}');
            
            // 🔧 修復：使用 _mergeUserData 合併數據
            if (_currentUser != null) {
              setState(() {
                _currentUser = _mergeUserData(_currentUser!, updatedUser);
                print('📥 BasicInfoPage: 更新後的用戶資料 - 電話: ${_currentUser!.phone}, 地區: ${_currentUser!.location}');
              });
            } else {
              // 如果當前用戶為空，直接創建新的用戶對象
              setState(() {
                _currentUser = User.fromMap(updatedUser);
                print('📥 BasicInfoPage: 創建新用戶對象 - 電話: ${_currentUser!.phone}, 地區: ${_currentUser!.location}');
              });
            }
            
            _showSnackBar('資料更新成功！');
            
            // 🔧 重要修復：移除立即重新加載，避免覆蓋正確的數據
            // 如果需要從服務器刷新，請使用右上角的刷新按鈕
            // _loadUserData(); // 註釋掉這行，避免覆蓋剛更新的正確數據
          } else {
            print('⚠️ BasicInfoPage: 未收到有效更新數據');
            // 如果沒有返回數據，仍然重新加載以確保數據同步
            _loadUserData();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '編輯資料',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}