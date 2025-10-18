// lib/pages/subpages/personal_settings_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/real_api_service.dart';
import '../../providers/auth_provider.dart';
import '../../login_page.dart';
import 'basic_info_page.dart';
import 'device_management_page.dart';
import 'security_notifications_page.dart';

class PersonalSettingsPage extends StatefulWidget {
  const PersonalSettingsPage({super.key});

  @override
  State<PersonalSettingsPage> createState() => _PersonalSettingsPageState();
}

class _PersonalSettingsPageState extends State<PersonalSettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = '繁體中文';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? '繁體中文';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
    
    _showSnackBar('設定已保存');
  }

  Future<void> _logout() async {
    final confirmed = await _showLogoutDialog();
    if (confirmed) {
      try {
        // 使用AuthProvider登出
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        
        _showSnackBar('已登出');
        
        // 返回主頁面
        Navigator.of(context).pop();
      } catch (e) {
        _showSnackBar('登出失敗: ${e.toString()}');
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密碼'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '當前密碼',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密碼',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '確認新密碼',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (oldPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                _showSnackBar('請填寫所有欄位');
                return;
              }
              
              if (newPasswordController.text != confirmPasswordController.text) {
                _showSnackBar('新密碼與確認密碼不一致');
                return;
              }
              
              if (newPasswordController.text.length < 6) {
                _showSnackBar('新密碼至少需要6個字符');
                return;
              }

              try {
                // 這裡應該調用實際的修改密碼API
                await Future.delayed(const Duration(seconds: 1)); // 模擬API調用
                Navigator.of(context).pop();
                _showSnackBar('密碼修改成功');
              } catch (e) {
                _showSnackBar('密碼修改失敗: ${e.toString()}');
              }
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAccountSecurityDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帳號安全'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('帳號安全設定：'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.green),
              title: const Text('帳號已驗證'),
              subtitle: const Text('您的帳號已通過電子郵件驗證'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.blue),
              title: const Text('登入設備'),
              subtitle: const Text('查看和管理您的登入設備'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeviceManagementPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('安全通知'),
              subtitle: const Text('接收帳號安全相關通知'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SecurityNotificationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除快取'),
        content: const Text('確定要清除應用程式的快取資料嗎？這可能會影響應用程式的載入速度。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確認'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 模擬清除快取操作
        await Future.delayed(const Duration(seconds: 1));
        _showSnackBar('快取清除成功');
      } catch (e) {
        _showSnackBar('快取清除失敗: ${e.toString()}');
      }
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('您確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確認'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map<DropdownMenuItem<String>>((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
              title: const Text('個人設定'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '請先登入',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '登入後即可使用個人設定',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      
                      // 如果登入成功，刷新頁面狀態
                      if (result == true) {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        authProvider.loginSuccess();
                        print('🔧 個人設定: 登入成功，刷新狀態');
                        // 延遲一下讓狀態完全更新
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('前往登入'),
                  ),
                ],
              ),
            ),
          );
        }

        // 已登入，顯示設定內容
        return Scaffold(
      appBar: AppBar(
        title: const Text('個人設定'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              '保存',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // 基本資料 - 移到最上面
                _buildActionTile(
                  title: '基本資料',
                  subtitle: '查看和編輯個人資料',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const BasicInfoPage()),
                    );
                  },
                  icon: Icons.person,
                ),
                
                
                // 通知設定
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '通知設定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildSwitchTile(
                  title: '推播通知',
                  subtitle: '接收新訊息和互動通知',
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                  icon: Icons.notifications,
                ),
                
                const Divider(height: 1),
                
                // 顯示設定
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '顯示設定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const Divider(height: 1),
                
                // 語言設定
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '語言設定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildDropdownTile(
                  title: '應用程式語言',
                  subtitle: '選擇您的偏好語言',
                  value: _selectedLanguage,
                  options: const ['繁體中文', '简体中文', 'English', '日本語'],
                  onChanged: (value) => setState(() => _selectedLanguage = value),
                  icon: Icons.language,
                ),
                
                const Divider(height: 1),
                
                // 帳號管理
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '帳號管理',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildActionTile(
                  title: '修改密碼',
                  subtitle: '更改您的登入密碼',
                  onTap: _showChangePasswordDialog,
                  icon: Icons.lock,
                ),
                _buildActionTile(
                  title: '帳號安全',
                  subtitle: '管理您的帳號安全設定',
                  onTap: _showAccountSecurityDialog,
                  icon: Icons.security,
                ),
                     _buildActionTile(
                       title: '清除快取',
                       subtitle: '清除應用程式快取資料',
                       onTap: _clearCache,
                       icon: Icons.clear_all,
                     ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // 登出按鈕固定在底部
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '登出',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
