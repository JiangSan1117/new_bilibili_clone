// lib/pages/subpages/accessibility_settings_page.dart

import 'package:flutter/material.dart';
import '../../services/accessibility_service.dart';
import '../../widgets/sponsor_ad_widget.dart';

class AccessibilitySettingsPage extends StatefulWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  State<AccessibilitySettingsPage> createState() => _AccessibilitySettingsPageState();
}

class _AccessibilitySettingsPageState extends State<AccessibilitySettingsPage> {
  late AccessibilitySettings _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _settings = AccessibilityService.currentSettings;
  }

  Future<void> _updateSettings() async {
    setState(() => _isLoading = true);
    
    try {
      await AccessibilityService.saveSettings(_settings);
      if (mounted) {
        _showSnackBar('設置已保存');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('保存失敗: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('無障礙設置'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _updateSettings,
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
          // 頂部贊助區
          const SponsorAdWidget(location: '無障礙設置頁面頂部贊助區'),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 字體大小設置
                  _buildFontScaleSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 視覺設置
                  _buildVisualSettingsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 交互設置
                  _buildInteractionSettingsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 色盲設置
                  _buildColorBlindnessSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 無障礙建議
                  _buildAccessibilitySuggestionsSection(),
                ],
              ),
            ),
          ),
          
          // 底部贊助區
          const SponsorAdWidget(location: '無障礙設置頁面底部贊助區'),
        ],
      ),
    );
  }

  Widget _buildFontScaleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            '字體大小',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              const Text('小'),
              Expanded(
                child: Slider(
                  value: _settings.fontScale,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(_settings.fontScale * 100).round()}%',
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(fontScale: value);
                    });
                  },
                ),
              ),
              const Text('大'),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Center(
            child: Text(
              '當前字體大小: ${(_settings.fontScale * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            '視覺設置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('高對比度模式'),
            subtitle: const Text('增強文字和背景的對比度'),
            value: _settings.highContrast,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(highContrast: value);
              });
            },
            secondary: Icon(
              Icons.contrast,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          SwitchListTile(
            title: const Text('屏幕閱讀器支持'),
            subtitle: const Text('為視障用戶提供語音導航'),
            value: _settings.screenReaderEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(screenReaderEnabled: value);
              });
            },
            secondary: Icon(
              Icons.hearing,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            '交互設置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('減少動畫'),
            subtitle: const Text('減少或關閉動畫效果'),
            value: _settings.reducedMotion,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(reducedMotion: value);
              });
            },
            secondary: Icon(
              Icons.motion_photos_off,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBlindnessSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            '色盲支持',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<ColorBlindnessType>(
            value: _settings.colorBlindnessType,
            decoration: const InputDecoration(
              labelText: '色盲類型',
              border: OutlineInputBorder(),
            ),
            items: ColorBlindnessType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getColorBlindnessTypeName(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings = _settings.copyWith(colorBlindnessType: value);
                });
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // 顏色預覽
          _buildColorPreview(),
        ],
      ),
    );
  }

  String _getColorBlindnessTypeName(ColorBlindnessType type) {
    switch (type) {
      case ColorBlindnessType.none:
        return '無色盲';
      case ColorBlindnessType.protanopia:
        return '紅色盲';
      case ColorBlindnessType.deuteranopia:
        return '綠色盲';
      case ColorBlindnessType.tritanopia:
        return '藍色盲';
    }
  }

  Widget _buildColorPreview() {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '顏色預覽:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final adjustedColor = AccessibilityService.getColorBlindFriendlyColor(
              color,
              _settings.colorBlindnessType,
            );
            
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: adjustedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccessibilitySuggestionsSection() {
    final suggestions = AccessibilityService.getAccessibilitySuggestions();
    
    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '您的無障礙設置已優化',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              Text(
                '無障礙建議',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
