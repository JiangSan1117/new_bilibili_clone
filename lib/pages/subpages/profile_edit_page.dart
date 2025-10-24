// lib/pages/subpages/profile_edit_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../services/real_api_service.dart';
import '../../models/user_model.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedAvatarPath;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await RealApiService.getCurrentUser();
      
      if (result['success'] == true && result['user'] != null) {
        final userData = result['user'];
        final user = User(
          id: userData['id'] ?? '',
          nickname: userData['nickname'] ?? '用戶',
          avatarUrl: userData['avatar'] ?? 'https://via.placeholder.com/150',
          levelNum: userData['levelNum'] ?? 1,
          collections: userData['collections'] ?? 0,
          follows: userData['follows'] ?? 0,
          friends: userData['friends'] ?? 0,
          posts: userData['posts'] ?? 0,
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          location: userData['location'] ?? '',
          realName: userData['realName'] ?? '',
          idCardNumber: userData['idCardNumber'] ?? '',
          verificationStatus: userData['verificationStatus'] == 'verified'
              ? VerificationStatus.verified
              : VerificationStatus.unverified,
          membershipType: userData['membershipType'] == 'verified'
              ? MembershipType.verified
              : MembershipType.free,
          verificationDate: userData['verificationDate'] != null
              ? DateTime.parse(userData['verificationDate'])
              : null,
          verificationNotes: userData['verificationNotes'] ?? '',
        );
        
        setState(() {
          _currentUser = user;
          _nicknameController.text = user.nickname;
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phone ?? '';
          _locationController.text = user.location ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('載入用戶資料失敗: ${result['error'] ?? '未知錯誤'}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('載入用戶資料失敗: ${e.toString()}');
    }
  }

  Future<void> _pickAvatar() async {
    try {
      // 先檢查權限
      final status = await Permission.photos.status;
      
      if (status.isDenied) {
        final requestStatus = await Permission.photos.request();
        if (requestStatus.isDenied) {
          _showPermissionDeniedDialog();
          return;
        }
      }
      
      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
        return;
      }
      
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedAvatarPath = pickedFile.path;
        });
        _showSnackBar('頭像已選擇，點擊保存即可更新');
      }
    } catch (e) {
      _showSnackBar('選擇圖片時發生錯誤: ${e.toString()}');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('權限被拒'),
        content: const Text('請在設定中授予應用程式照片權限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('前往設定'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) {
      _showSnackBar('請輸入暱稱');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 更新用戶資料
      final result = await RealApiService.updateUserProfile(
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        // avatar: _selectedAvatarPath, // TODO: 實現頭像上傳功能
      );

      if (result['success'] == true) {
        _showSnackBar('個人資料更新成功！');
        
        // 刷新用戶數據
        await _loadUserData();
        
        // 返回上一頁
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showSnackBar(result['error'] ?? '更新失敗');
      }
    } catch (e) {
      _showSnackBar('更新失敗: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : (_currentUser?.avatarUrl != null && _currentUser!.avatarUrl.isNotEmpty
                        ? NetworkImage(_currentUser!.avatarUrl) as ImageProvider
                        : null),
                child: _selectedImage == null && _currentUser?.avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '點擊相機圖標更換頭像',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯個人資料'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: Text(
                    '保存',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // 頭像區域
                  _buildAvatarSection(),
                  
                  const SizedBox(height: 32),
                  
                  // 表單區域
                  _buildFormField(
                    label: '暱稱',
                    controller: _nicknameController,
                    icon: Icons.person,
                    hintText: '請輸入您的暱稱',
                  ),
                  
                  _buildFormField(
                    label: '電子郵件',
                    controller: _emailController,
                    icon: Icons.email,
                    hintText: '請輸入您的電子郵件',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  _buildFormField(
                    label: '電話號碼',
                    controller: _phoneController,
                    icon: Icons.phone,
                    hintText: '請輸入您的電話號碼',
                    keyboardType: TextInputType.phone,
                  ),
                  
                  _buildFormField(
                    label: '所在地',
                    controller: _locationController,
                    icon: Icons.location_on,
                    hintText: '請輸入您的所在地',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 保存按鈕
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '保存變更',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
