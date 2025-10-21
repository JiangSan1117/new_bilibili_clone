// lib/pages/subpages/registration_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../services/verification_service.dart';
import '../../services/real_api_service.dart';

class RegistrationProfilePage extends StatefulWidget {
  final String email;
  final String password;
  
  const RegistrationProfilePage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RegistrationProfilePage> createState() => _RegistrationProfilePageState();
}

class _RegistrationProfilePageState extends State<RegistrationProfilePage> {
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  File? _idCardFrontImage;
  File? _idCardBackImage;
  File? _avatarImage;
  
  bool _isLoading = false;
  bool _agreeToTerms = false;
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void dispose() {
    _realNameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      _showSnackBar('需要相機權限才能拍照身份證', isError: true);
    }
  }

  Future<void> _takeIdCardPhoto(bool isFront) async {
    await _requestCameraPermission();
    
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo != null) {
        setState(() {
          if (isFront) {
            _idCardFrontImage = File(photo.path);
          } else {
            _idCardBackImage = File(photo.path);
          }
        });
        _showSnackBar('${isFront ? '正面' : '背面'}身份證拍照成功', isError: false);
      }
    } catch (e) {
      _showSnackBar('拍照失敗，請重試', isError: true);
    }
  }

  Future<void> _takeAvatarPhoto() async {
    await _requestCameraPermission();
    
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (photo != null) {
        setState(() {
          _avatarImage = File(photo.path);
        });
        _showSnackBar('頭像拍照成功', isError: false);
      }
    } catch (e) {
      _showSnackBar('拍照失敗，請重試', isError: true);
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // 基本資料
        if (_realNameController.text.trim().isEmpty) {
          _showSnackBar('請輸入真實姓名', isError: true);
          return false;
        }
        if (_nicknameController.text.trim().isEmpty) {
          _showSnackBar('請輸入暱稱', isError: true);
          return false;
        }
        if (_phoneController.text.trim().isEmpty) {
          _showSnackBar('請輸入電話號碼', isError: true);
          return false;
        }
        if (_locationController.text.trim().isEmpty) {
          _showSnackBar('請輸入所在地區', isError: true);
          return false;
        }
        return true;
        
      case 1: // 身份證
        if (_idCardController.text.trim().isEmpty) {
          _showSnackBar('請輸入身份證號碼', isError: true);
          return false;
        }
        if (!VerificationService.validateIdCard(_idCardController.text.trim())) {
          _showSnackBar('身份證號碼格式不正確', isError: true);
          return false;
        }
        if (_idCardFrontImage == null) {
          _showSnackBar('請拍照身份證正面', isError: true);
          return false;
        }
        if (_idCardBackImage == null) {
          _showSnackBar('請拍照身份證背面', isError: true);
          return false;
        }
        return true;
        
      case 2: // 確認
        if (!_agreeToTerms) {
          _showSnackBar('請同意實名制條款', isError: true);
          return false;
        }
        return true;
        
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        _completeRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 使用真實API註冊用戶
      final result = await RealApiService.register(
        email: widget.email,
        password: widget.password,
        nickname: _nicknameController.text.trim(),
        realName: _realNameController.text.trim(),
        idCardNumber: _idCardController.text.trim(),
      );
      
      if (result['success'] == true) {
        // 註冊成功 - 自動登入
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('註冊成功！自動登入中...'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 自動登入
        final loginResult = await RealApiService.login(
          email: widget.email,
          password: widget.password,
        );
        
        if (loginResult['success'] == true) {
          // 登入成功，返回兩層到主頁面
          Navigator.of(context).pop(); // 退出註冊頁面
          Navigator.of(context).pop(); // 退出登入頁面
        } else {
          // 登入失敗，返回登入頁面讓用戶手動登入
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('註冊失敗: ${result['error'] ?? '未知錯誤'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('註冊失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepTitle() {
    final titles = ['基本資料', '身份證驗證', '確認註冊'];
    return Text(
      titles[_currentStep],
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildIdCardStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 頭像拍照
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _takeAvatarPhoto,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                  child: _avatarImage != null
                      ? ClipOval(
                          child: Image.file(
                            _avatarImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 30),
                            const SizedBox(height: 4),
                            Text(
                              '拍照頭像',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '點擊拍照頭像',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 基本資料表單
        _buildTextField(
          controller: _realNameController,
          label: '真實姓名',
          hint: '請輸入您的真實姓名',
          icon: Icons.person,
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _nicknameController,
          label: '暱稱',
          hint: '請輸入您的暱稱',
          icon: Icons.badge,
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _phoneController,
          label: '電話號碼',
          hint: '請輸入您的電話號碼',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _locationController,
          label: '所在地區',
          hint: '請輸入您的所在地區',
          icon: Icons.location_on,
        ),
      ],
    );
  }

  Widget _buildIdCardStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 身份證號碼輸入
        _buildTextField(
          controller: _idCardController,
          label: '身份證號碼',
          hint: '請輸入身份證號碼',
          icon: Icons.credit_card,
          inputFormatters: [
            UpperCaseTextFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            LengthLimitingTextInputFormatter(10),
          ],
          maxLength: 10,
        ),
        
        const SizedBox(height: 24),
        
        // 身份證拍照區域
        Text(
          '身份證拍照',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            // 正面
            Expanded(
              child: _buildIdCardPhotoCard(
                title: '身份證正面',
                subtitle: '請拍攝身份證正面',
                image: _idCardFrontImage,
                onTap: () => _takeIdCardPhoto(true),
                isFront: true,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 背面
            Expanded(
              child: _buildIdCardPhotoCard(
                title: '身份證背面',
                subtitle: '請拍攝身份證背面',
                image: _idCardBackImage,
                onTap: () => _takeIdCardPhoto(false),
                isFront: false,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 拍照說明
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '請確保身份證清晰可見，光線充足，避免反光和陰影',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 資料確認
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '註冊資料確認',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildConfirmItem('真實姓名', _realNameController.text.trim()),
              _buildConfirmItem('暱稱', _nicknameController.text.trim()),
              _buildConfirmItem('電子郵件', widget.email),
              _buildConfirmItem('電話號碼', _phoneController.text.trim()),
              _buildConfirmItem('所在地區', _locationController.text.trim()),
              _buildConfirmItem('身份證號碼', _idCardController.text.trim()),
              _buildConfirmItem('身份證正面', _idCardFrontImage != null ? '已拍照' : '未拍照'),
              _buildConfirmItem('身份證背面', _idCardBackImage != null ? '已拍照' : '未拍照'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
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
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      children: [
                        const TextSpan(text: '我同意'),
                        TextSpan(
                          text: '《實名制條款》',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '《隱私政策》',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: '，並確認提供的信息真實有效'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildIdCardPhotoCard({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
    required bool isFront,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? Colors.green : Colors.grey.shade300,
            width: 2,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '點擊拍照',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: image != null ? Colors.green : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                image != null ? '已拍照' : title,
                style: TextStyle(
                  fontSize: 10,
                  color: image != null ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('註冊 ($_currentStep/$_totalSteps)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _isLoading ? null : _previousStep,
              child: const Text('上一步'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 步驟指示器
          _buildStepIndicator(),
          
          // 內容區域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepTitle(),
                  
                  const SizedBox(height: 24),
                  
                  _buildStepContent(),
                ],
              ),
            ),
          ),
          
          // 底部按鈕
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _currentStep == _totalSteps - 1 ? '完成註冊' : '下一步',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
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
