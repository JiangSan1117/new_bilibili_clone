// lib/pages/subpages/security_notifications_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityNotificationsPage extends StatefulWidget {
  const SecurityNotificationsPage({super.key});

  @override
  State<SecurityNotificationsPage> createState() => _SecurityNotificationsPageState();
}

class _SecurityNotificationsPageState extends State<SecurityNotificationsPage> {
  bool _loginAlerts = true;
  bool _passwordChanges = true;
  bool _deviceLogins = true;
  bool _suspiciousActivity = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginAlerts = prefs.getBool('security_login_alerts') ?? true;
      _passwordChanges = prefs.getBool('security_password_changes') ?? true;
      _deviceLogins = prefs.getBool('security_device_logins') ?? true;
      _suspiciousActivity = prefs.getBool('security_suspicious_activity') ?? true;
      _emailNotifications = prefs.getBool('security_email_notifications') ?? true;
      _pushNotifications = prefs.getBool('security_push_notifications') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_login_alerts', _loginAlerts);
    await prefs.setBool('security_password_changes', _passwordChanges);
    await prefs.setBool('security_device_logins', _deviceLogins);
    await prefs.setBool('security_suspicious_activity', _suspiciousActivity);
    await prefs.setBool('security_email_notifications', _emailNotifications);
    await prefs.setBool('security_push_notifications', _pushNotifications);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('安全通知設定已保存')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('安全通知'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 通知方式
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
                    Icon(Icons.notifications, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '通知方式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  title: '推播通知',
                  subtitle: '在設備上接收即時通知',
                  value: _pushNotifications,
                  onChanged: (value) => setState(() => _pushNotifications = value),
                ),
                _buildSwitchTile(
                  title: '電子郵件通知',
                  subtitle: '透過電子郵件接收通知',
                  value: _emailNotifications,
                  onChanged: (value) => setState(() => _emailNotifications = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 安全事件通知
          Text(
            '安全事件通知',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: '登入提醒',
            subtitle: '當有新設備登入您的帳號時通知',
            value: _loginAlerts,
            onChanged: (value) => setState(() => _loginAlerts = value),
            icon: Icons.login,
          ),
          
          _buildSwitchTile(
            title: '密碼變更',
            subtitle: '當您的密碼被修改時通知',
            value: _passwordChanges,
            onChanged: (value) => setState(() => _passwordChanges = value),
            icon: Icons.lock,
          ),
          
          _buildSwitchTile(
            title: '設備登入',
            subtitle: '當您的帳號在新設備上登入時通知',
            value: _deviceLogins,
            onChanged: (value) => setState(() => _deviceLogins = value),
            icon: Icons.devices,
          ),
          
          _buildSwitchTile(
            title: '可疑活動',
            subtitle: '當偵測到可疑登入活動時通知',
            value: _suspiciousActivity,
            onChanged: (value) => setState(() => _suspiciousActivity = value),
            icon: Icons.warning,
          ),
          
          const SizedBox(height: 32),
          
          // 測試通知按鈕
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('測試通知已發送'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('發送測試通知'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
