// lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/real_api_service.dart';
import '../utils/firebase_diagnostics.dart';
import '../providers/auth_provider.dart';
import 'pages/subpages/registration_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isLoginMode = true; // true for login, false for register
  Map<String, dynamic>? _diagnostics;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runDiagnostics() async {
    final diagnostics = await FirebaseDiagnostics.runDiagnostics();
    setState(() {
      _diagnostics = diagnostics;
    });
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('請填寫所有欄位');
      return;
    }

    // 驗證電子郵件格式
    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('請輸入有效的電子郵件地址');
      return;
    }

    // 驗證密碼長度
    if (_passwordController.text.length < 6) {
      _showSnackBar('密碼至少需要6個字符');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        // 使用真實API登入
        final result = await RealApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (result['success'] == true) {
          _showSnackBar('登入成功！');
          // 更新AuthProvider狀態
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.loginSuccess();
          Navigator.of(context).pop(true); // 傳遞 true 表示登入成功
        } else {
          _showSnackBar('登入失敗: ${result['error'] ?? '未知錯誤'}');
        }
      } else {
        // 註冊模式：跳轉到基本資料填寫頁面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RegistrationProfilePage(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('錯誤: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithGoogle();
      _showSnackBar('Google 登入成功！');
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Google 登入失敗: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? '登入' : '註冊'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2A2A2A) 
            : Colors.white,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // Logo and title
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.share,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '想享',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoginMode ? '歡迎回來！' : '加入想享社群',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '電子郵件',
                hintText: '例如：test@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _emailController.text.isNotEmpty && !_isValidEmail(_emailController.text) 
                    ? '請輸入有效的電子郵件地址' 
                    : null,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: '密碼',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            // 註冊說明（僅在註冊模式下顯示）
            if (!_isLoginMode) ...[
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '註冊後將引導您完成基本資料填寫和身份證拍照驗證',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Login/Register button
            ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : Text(
                      _isLoginMode ? '登入' : '註冊',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Toggle login/register mode
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(
                _isLoginMode
                    ? '還沒有帳號？點此註冊'
                    : '已有帳號？點此登入',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            
            // 暫時隱藏 Google 登入功能
            // const SizedBox(height: 24),
            // 
            // // Divider
            // Row(
            //   children: [
            //     const Expanded(child: Divider()),
            //     Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16),
            //       child: Text(
            //         '或',
            //         style: TextStyle(color: Colors.grey.shade600),
            //       ),
            //     ),
            //     const Expanded(child: Divider()),
            //   ],
            // ),
            // 
            // const SizedBox(height: 24),
            // 
            // // Google sign in button
            // OutlinedButton.icon(
            //   onPressed: _isLoading ? null : _signInWithGoogle,
            //   icon: const Icon(Icons.login, color: Colors.red),
            //   label: const Text('使用 Google 登入'),
            //   style: OutlinedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
