// lib/services/retry_service.dart

import 'package:flutter/foundation.dart';
import 'dart:async';

// 重試配置
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool exponentialBackoff;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.exponentialBackoff = true,
  });
}

// 重試結果
class RetryResult<T> {
  final T? data;
  final bool success;
  final int attempts;
  final String? error;

  RetryResult({
    this.data,
    required this.success,
    required this.attempts,
    this.error,
  });
}

class RetryService {
  // 帶重試的異步操作
  static Future<RetryResult<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration delay = config.initialDelay;

    while (attempts < config.maxAttempts) {
      attempts++;
      
      try {
        final result = await operation();
        return RetryResult<T>(
          data: result,
          success: true,
          attempts: attempts,
        );
      } catch (error) {
        debugPrint('重試第 $attempts 次失敗: $error');
        
        // 檢查是否應該重試
        if (shouldRetry != null && !shouldRetry(error)) {
          return RetryResult<T>(
            success: false,
            attempts: attempts,
            error: error.toString(),
          );
        }

        // 如果是最後一次嘗試，返回錯誤
        if (attempts >= config.maxAttempts) {
          return RetryResult<T>(
            success: false,
            attempts: attempts,
            error: error.toString(),
          );
        }

        // 等待後重試
        await Future.delayed(delay);
        
        // 計算下次延遲時間
        if (config.exponentialBackoff) {
          delay = Duration(
            milliseconds: (delay.inMilliseconds * config.backoffMultiplier).round().clamp(
              0,
              config.maxDelay.inMilliseconds,
            ),
          );
        }
      }
    }

    return RetryResult<T>(
      success: false,
      attempts: attempts,
      error: '達到最大重試次數',
    );
  }

  // 帶重試的網絡請求
  static Future<RetryResult<T>> executeNetworkRequest<T>(
    Future<T> Function() request, {
    RetryConfig config = const RetryConfig(maxAttempts: 5),
  }) async {
    return executeWithRetry<T>(
      request,
      config: config,
      shouldRetry: (error) {
        // 網絡相關錯誤才重試
        final errorString = error.toString().toLowerCase();
        return errorString.contains('socket') ||
               errorString.contains('timeout') ||
               errorString.contains('connection') ||
               errorString.contains('network');
      },
    );
  }

  // 帶重試的文件操作
  static Future<RetryResult<T>> executeFileOperation<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(maxAttempts: 3),
  }) async {
    return executeWithRetry<T>(
      operation,
      config: config,
      shouldRetry: (error) {
        // 文件相關錯誤才重試
        final errorString = error.toString().toLowerCase();
        return errorString.contains('file') ||
               errorString.contains('io') ||
               errorString.contains('permission');
      },
    );
  }

  // 帶重試的數據庫操作
  static Future<RetryResult<T>> executeDatabaseOperation<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(maxAttempts: 3),
  }) async {
    return executeWithRetry<T>(
      operation,
      config: config,
      shouldRetry: (error) {
        // 數據庫相關錯誤才重試
        final errorString = error.toString().toLowerCase();
        return errorString.contains('database') ||
               errorString.contains('sql') ||
               errorString.contains('transaction');
      },
    );
  }

  // 簡化的重試方法
  static Future<T?> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        return await operation();
      } catch (error) {
        debugPrint('重試第 ${i + 1} 次失敗: $error');
        
        if (i == maxAttempts - 1) {
          rethrow; // 最後一次失敗，拋出異常
        }
        
        await Future.delayed(delay);
      }
    }
    return null;
  }

  // 帶回調的重試方法
  static Future<T?> retryWithCallback<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        return await operation();
      } catch (error) {
        debugPrint('重試第 ${i + 1} 次失敗: $error');
        
        onRetry?.call(i + 1, error);
        
        if (i == maxAttempts - 1) {
          rethrow; // 最後一次失敗，拋出異常
        }
        
        await Future.delayed(delay);
      }
    }
    return null;
  }

  // 條件重試
  static Future<T?> retryIf<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    required bool Function(dynamic error) shouldRetry,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        return await operation();
      } catch (error) {
        debugPrint('重試第 ${i + 1} 次失敗: $error');
        
        if (!shouldRetry(error) || i == maxAttempts - 1) {
          rethrow; // 不應該重試或最後一次失敗，拋出異常
        }
        
        await Future.delayed(delay);
      }
    }
    return null;
  }

  // 批量重試
  static Future<List<T>> retryBatch<T>(
    List<Future<T> Function()> operations, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    final results = <T>[];
    
    for (final operation in operations) {
      try {
        final result = await retry<T>(
          operation,
          maxAttempts: maxAttempts,
          delay: delay,
        );
        if (result != null) {
          results.add(result);
        }
      } catch (error) {
        debugPrint('批量操作失敗: $error');
        // 繼續執行下一個操作
      }
    }
    
    return results;
  }

  // 並行重試
  static Future<List<T>> retryBatchParallel<T>(
    List<Future<T> Function()> operations, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    final futures = operations.map((operation) => retry<T>(
      operation,
      maxAttempts: maxAttempts,
      delay: delay,
    ));
    
    final results = await Future.wait(futures);
    return results.where((result) => result != null).cast<T>().toList();
  }
}