// lib/services/error_handler_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'network_service.dart';

// 錯誤類型枚舉
enum ErrorType {
  network,
  timeout,
  server,
  authentication,
  permission,
  storage,
  unknown,
}

// 錯誤信息模型
class ErrorInfo {
  final ErrorType type;
  final String message;
  final String? details;
  final DateTime timestamp;
  final bool canRetry;

  ErrorInfo({
    required this.type,
    required this.message,
    this.details,
    DateTime? timestamp,
    this.canRetry = false,
  }) : timestamp = timestamp ?? DateTime.now();

  String get displayMessage {
    switch (type) {
      case ErrorType.network:
        return '網絡連接異常，請檢查網絡設置';
      case ErrorType.timeout:
        return '請求超時，請稍後重試';
      case ErrorType.server:
        return '服務器錯誤，請稍後重試';
      case ErrorType.authentication:
        return '認證失敗，請重新登入';
      case ErrorType.permission:
        return '權限不足，請檢查應用權限';
      case ErrorType.storage:
        return '存儲空間不足或權限被拒';
      case ErrorType.unknown:
        return message.isNotEmpty ? message : '未知錯誤，請稍後重試';
    }
  }

  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.schedule;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.timeout:
        return Colors.amber;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.purple;
      case ErrorType.permission:
        return Colors.deepOrange;
      case ErrorType.storage:
        return Colors.brown;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }
}

class ErrorHandlerService {
  // 分析異常並返回錯誤信息
  static ErrorInfo analyzeException(dynamic exception) {
    if (exception is SocketException) {
      return ErrorInfo(
        type: ErrorType.network,
        message: '網絡連接失敗',
        details: exception.message,
        canRetry: true,
      );
    }
    
    if (exception is HttpException) {
      return ErrorInfo(
        type: ErrorType.server,
        message: 'HTTP錯誤: ${exception.message}',
        details: exception.toString(),
        canRetry: true,
      );
    }
    
    if (exception is TimeoutException) {
      return ErrorInfo(
        type: ErrorType.timeout,
        message: '請求超時',
        details: exception.toString(),
        canRetry: true,
      );
    }
    
    if (exception is FormatException) {
      return ErrorInfo(
        type: ErrorType.server,
        message: '數據格式錯誤',
        details: exception.message,
        canRetry: false,
      );
    }
    
    if (exception.toString().contains('permission')) {
      return ErrorInfo(
        type: ErrorType.permission,
        message: '權限被拒絕',
        details: exception.toString(),
        canRetry: false,
      );
    }
    
    if (exception.toString().contains('storage') || 
        exception.toString().contains('space')) {
      return ErrorInfo(
        type: ErrorType.storage,
        message: '存儲空間問題',
        details: exception.toString(),
        canRetry: false,
      );
    }

    return ErrorInfo(
      type: ErrorType.unknown,
      message: exception.toString(),
      details: exception.runtimeType.toString(),
      canRetry: true,
    );
  }

  // 顯示錯誤對話框
  static Future<void> showErrorDialog(
    BuildContext context,
    ErrorInfo errorInfo, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                errorInfo.icon,
                color: errorInfo.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('出現錯誤'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorInfo.displayMessage,
                style: const TextStyle(fontSize: 16),
              ),
              if (kDebugMode && errorInfo.details != null) ...[
                const SizedBox(height: 12),
                const Text(
                  '詳細信息 (Debug模式):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorInfo.details!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (errorInfo.canRetry && onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text(
                  '重試',
                  style: TextStyle(color: errorInfo.color),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  // 顯示錯誤SnackBar
  static void showErrorSnackBar(
    BuildContext context,
    ErrorInfo errorInfo, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              errorInfo.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(errorInfo.displayMessage),
            ),
          ],
        ),
        backgroundColor: errorInfo.color,
        duration: const Duration(seconds: 4),
        action: errorInfo.canRetry && onRetry != null
            ? SnackBarAction(
                label: '重試',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  // 顯示網絡錯誤提示
  static Future<void> showNetworkErrorDialog(BuildContext context) async {
    final isConnected = await NetworkService.isConnected();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('網絡連接問題'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConnected
                    ? '網絡已連接，但無法訪問服務器'
                    : '請檢查您的網絡連接',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (!isConnected) ...[
                const Text(
                  '建議檢查：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• WiFi或移動數據是否開啟'),
                const Text('• 網絡信號是否良好'),
                const Text('• 是否連接到正確的網絡'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  // 顯示離線模式提示
  static Future<void> showOfflineModeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.cloud_off,
                color: Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('離線模式'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '您目前處於離線模式',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '部分功能可能無法使用，但您可以：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 瀏覽已緩存的內容'),
              Text('• 查看離線數據'),
              Text('• 等待網絡恢復後自動同步'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('了解'),
            ),
          ],
        );
      },
    );
  }
}