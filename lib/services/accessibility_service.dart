// lib/services/accessibility_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 無障礙設置模型
class AccessibilitySettings {
  final double fontScale;
  final bool highContrast;
  final bool screenReaderEnabled;
  final bool reducedMotion;
  final ColorBlindnessType colorBlindnessType;

  AccessibilitySettings({
    this.fontScale = 1.0,
    this.highContrast = false,
    this.screenReaderEnabled = false,
    this.reducedMotion = false,
    this.colorBlindnessType = ColorBlindnessType.none,
  });

  factory AccessibilitySettings.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettings(
      fontScale: map['fontScale']?.toDouble() ?? 1.0,
      highContrast: map['highContrast'] ?? false,
      screenReaderEnabled: map['screenReaderEnabled'] ?? false,
      reducedMotion: map['reducedMotion'] ?? false,
      colorBlindnessType: ColorBlindnessType.values.firstWhere(
        (type) => type.name == map['colorBlindnessType'],
        orElse: () => ColorBlindnessType.none,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontScale': fontScale,
      'highContrast': highContrast,
      'screenReaderEnabled': screenReaderEnabled,
      'reducedMotion': reducedMotion,
      'colorBlindnessType': colorBlindnessType.name,
    };
  }

  AccessibilitySettings copyWith({
    double? fontScale,
    bool? highContrast,
    bool? screenReaderEnabled,
    bool? reducedMotion,
    ColorBlindnessType? colorBlindnessType,
  }) {
    return AccessibilitySettings(
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      colorBlindnessType: colorBlindnessType ?? this.colorBlindnessType,
    );
  }
}

// 色盲類型
enum ColorBlindnessType {
  none,
  protanopia, // 紅色盲
  deuteranopia, // 綠色盲
  tritanopia, // 藍色盲
}

class AccessibilityService {
  static const String _fontScaleKey = 'accessibility_font_scale';
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _screenReaderKey = 'accessibility_screen_reader';
  static const String _reducedMotionKey = 'accessibility_reduced_motion';
  static const String _colorBlindnessKey = 'accessibility_color_blindness';

  // 當前設置
  static AccessibilitySettings _currentSettings = AccessibilitySettings();

  // 獲取當前設置
  static AccessibilitySettings get currentSettings => _currentSettings;

  // 初始化無障礙服務
  static Future<void> initialize() async {
    await _loadSettings();
  }

  // 加載設置
  static Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('accessibility_settings');
      
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
        _currentSettings = AccessibilitySettings.fromMap(settingsMap);
      }
    } catch (e) {
      debugPrint('載入無障礙設置失敗: $e');
    }
  }

  // 保存設置
  static Future<void> saveSettings(AccessibilitySettings settings) async {
    try {
      _currentSettings = settings;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessibility_settings', jsonEncode(settings.toMap()));
      
      if (kDebugMode) {
        debugPrint('無障礙設置已保存');
      }
    } catch (e) {
      debugPrint('保存無障礙設置失敗: $e');
    }
  }

  // 更新字體大小
  static Future<void> updateFontScale(double scale) async {
    final newSettings = _currentSettings.copyWith(fontScale: scale);
    await saveSettings(newSettings);
  }

  // 切換高對比度
  static Future<void> toggleHighContrast() async {
    final newSettings = _currentSettings.copyWith(highContrast: !_currentSettings.highContrast);
    await saveSettings(newSettings);
  }

  // 切換屏幕閱讀器
  static Future<void> toggleScreenReader() async {
    final newSettings = _currentSettings.copyWith(screenReaderEnabled: !_currentSettings.screenReaderEnabled);
    await saveSettings(newSettings);
  }

  // 切換減少動畫
  static Future<void> toggleReducedMotion() async {
    final newSettings = _currentSettings.copyWith(reducedMotion: !_currentSettings.reducedMotion);
    await saveSettings(newSettings);
  }

  // 設置色盲類型
  static Future<void> setColorBlindnessType(ColorBlindnessType type) async {
    final newSettings = _currentSettings.copyWith(colorBlindnessType: type);
    await saveSettings(newSettings);
  }

  // 獲取色盲友好的顏色
  static Color getColorBlindFriendlyColor(Color originalColor, ColorBlindnessType type) {
    switch (type) {
      case ColorBlindnessType.none:
        return originalColor;
      case ColorBlindnessType.protanopia:
        // 紅色盲：減少紅色分量
        return Color.fromARGB(
          originalColor.alpha,
          (originalColor.red * 0.7).round(),
          originalColor.green,
          originalColor.blue,
        );
      case ColorBlindnessType.deuteranopia:
        // 綠色盲：減少綠色分量
        return Color.fromARGB(
          originalColor.alpha,
          originalColor.red,
          (originalColor.green * 0.7).round(),
          originalColor.blue,
        );
      case ColorBlindnessType.tritanopia:
        // 藍色盲：減少藍色分量
        return Color.fromARGB(
          originalColor.alpha,
          originalColor.red,
          originalColor.green,
          (originalColor.blue * 0.7).round(),
        );
    }
  }

  // 創建無障礙主題
  static ThemeData createAccessibleTheme(ThemeData baseTheme) {
    final settings = _currentSettings;
    
    ThemeData accessibleTheme = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontSizeFactor: settings.fontScale),
    );

    // 高對比度調整
    if (settings.highContrast) {
      accessibleTheme = accessibleTheme.copyWith(
        brightness: Brightness.light,
        colorScheme: accessibleTheme.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      );
    }

    // 色盲友好調整
    if (settings.colorBlindnessType != ColorBlindnessType.none) {
      accessibleTheme = accessibleTheme.copyWith(
        colorScheme: accessibleTheme.colorScheme.copyWith(
          primary: getColorBlindFriendlyColor(
            accessibleTheme.colorScheme.primary,
            settings.colorBlindnessType,
          ),
          secondary: getColorBlindFriendlyColor(
            accessibleTheme.colorScheme.secondary,
            settings.colorBlindnessType,
          ),
        ),
      );
    }

    return accessibleTheme;
  }

  // 創建語義化按鈕
  static Widget createSemanticButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  // 創建語義化圖片
  static Widget createSemanticImage({
    required Widget image,
    required String semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      image: true,
      child: image,
    );
  }

  // 創建語義化文本
  static Widget createSemanticText({
    required String text,
    TextStyle? style,
    String? semanticLabel,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      excludeSemantics: excludeSemantics,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  // 創建語義化列表項
  static Widget createSemanticListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    String? semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      excludeSemantics: excludeSemantics,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  // 檢查是否支持屏幕閱讀器
  static bool isScreenReaderEnabled() {
    return _currentSettings.screenReaderEnabled;
  }

  // 檢查是否啟用減少動畫
  static bool isReducedMotionEnabled() {
    return _currentSettings.reducedMotion;
  }

  // 獲取動畫持續時間
  static Duration getAnimationDuration(Duration defaultDuration) {
    if (isReducedMotionEnabled()) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  // 創建語義化手勢檢測器
  static Widget createSemanticGestureDetector({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      excludeSemantics: excludeSemantics,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }

  // 創建語義化容器
  static Widget createSemanticContainer({
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  // 語義化公告
  static void announceToScreenReader(String message, BuildContext context) {
    if (isScreenReaderEnabled()) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  // 獲取無障礙建議
  static List<String> getAccessibilitySuggestions() {
    final suggestions = <String>[];
    
    if (_currentSettings.fontScale < 1.2) {
      suggestions.add('建議增加字體大小以提高可讀性');
    }
    
    if (!_currentSettings.highContrast) {
      suggestions.add('建議啟用高對比度模式');
    }
    
    if (!_currentSettings.screenReaderEnabled) {
      suggestions.add('建議啟用屏幕閱讀器支持');
    }
    
    if (!_currentSettings.reducedMotion) {
      suggestions.add('建議啟用減少動畫模式');
    }
    
    return suggestions;
  }
}