// lib/services/performance_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class PerformanceService {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _performanceMetrics = {};
  
  // 啟動計時器
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
    if (kDebugMode) {
      debugPrint('⏱️ 啟動計時器: $name');
    }
  }

  // 停止計時器並記錄
  static int stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;
      
      // 記錄性能指標
      if (!_performanceMetrics.containsKey(name)) {
        _performanceMetrics[name] = [];
      }
      _performanceMetrics[name]!.add(duration);
      
      if (kDebugMode) {
        debugPrint('⏱️ 計時器 $name: ${duration}ms');
      }
      
      _timers.remove(name);
      return duration;
    }
    return 0;
  }

  // 獲取平均執行時間
  static double getAverageTime(String name) {
    final metrics = _performanceMetrics[name];
    if (metrics == null || metrics.isEmpty) return 0.0;
    
    return metrics.reduce((a, b) => a + b) / metrics.length;
  }

  // 獲取性能統計
  static Map<String, Map<String, dynamic>> getPerformanceStats() {
    final stats = <String, Map<String, dynamic>>{};
    
    for (final entry in _performanceMetrics.entries) {
      final metrics = entry.value;
      if (metrics.isNotEmpty) {
        metrics.sort();
        stats[entry.key] = {
          'count': metrics.length,
          'min': metrics.first,
          'max': metrics.last,
          'average': metrics.reduce((a, b) => a + b) / metrics.length,
          'median': metrics[metrics.length ~/ 2],
        };
      }
    }
    
    return stats;
  }

  // 清除性能數據
  static void clearPerformanceData() {
    _performanceMetrics.clear();
    _timers.clear();
  }

  // 內存使用情況
  static Future<Map<String, dynamic>> getMemoryUsage() async {
    try {
      // 這裡可以添加實際的內存監控邏輯
      return {
        'heap_size': 'N/A',
        'heap_used': 'N/A',
        'heap_free': 'N/A',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('獲取內存使用情況失敗: $e');
      return {};
    }
  }

  // 檢查應用性能
  static Future<Map<String, dynamic>> checkAppPerformance() async {
    final memoryUsage = await getMemoryUsage();
    final performanceStats = getPerformanceStats();
    
    return {
      'memory': memoryUsage,
      'performance': performanceStats,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// 性能優化工具類
class PerformanceOptimizer {
  // 圖片壓縮配置
  static const Map<String, int> imageQualitySettings = {
    'thumbnail': 70,
    'medium': 80,
    'high': 90,
    'original': 100,
  };

  // 獲取優化的圖片質量
  static int getOptimizedImageQuality(String context) {
    return imageQualitySettings[context] ?? 80;
  }

  // 計算圖片壓縮尺寸
  static Size calculateOptimalImageSize(Size originalSize, Size targetSize) {
    final aspectRatio = originalSize.width / originalSize.height;
    
    double newWidth = targetSize.width;
    double newHeight = targetSize.height;
    
    if (aspectRatio > targetSize.width / targetSize.height) {
      // 寬度受限
      newHeight = targetSize.width / aspectRatio;
    } else {
      // 高度受限
      newWidth = targetSize.height * aspectRatio;
    }
    
    return Size(newWidth, newHeight);
  }

  // 預加載關鍵資源
  static Future<void> preloadCriticalResources() async {
    PerformanceService.startTimer('preload_resources');
    
    try {
      // 預加載關鍵圖片
      await Future.wait([
        // 這裡可以添加關鍵圖片的預加載
      ]);
      
      if (kDebugMode) {
        debugPrint('✅ 關鍵資源預加載完成');
      }
    } catch (e) {
      debugPrint('❌ 資源預加載失敗: $e');
    } finally {
      PerformanceService.stopTimer('preload_resources');
    }
  }

  // 優化列表性能
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 使用AutomaticKeepAliveClientMixin來保持狀態
        return _OptimizedListItem(
          key: ValueKey(index),
          child: itemBuilder(context, index),
        );
      },
    );
  }

  // 優化GridView性能
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        crossAxisSpacing: crossAxisSpacing ?? 0.0,
        mainAxisSpacing: mainAxisSpacing ?? 0.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _OptimizedGridItem(
          key: ValueKey(index),
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

// 優化的列表項
class _OptimizedListItem extends StatefulWidget {
  final Widget child;

  const _OptimizedListItem({
    super.key,
    required this.child,
  });

  @override
  State<_OptimizedListItem> createState() => _OptimizedListItemState();
}

class _OptimizedListItemState extends State<_OptimizedListItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// 優化的網格項
class _OptimizedGridItem extends StatefulWidget {
  final Widget child;

  const _OptimizedGridItem({
    super.key,
    required this.child,
  });

  @override
  State<_OptimizedGridItem> createState() => _OptimizedGridItemState();
}

class _OptimizedGridItemState extends State<_OptimizedGridItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// 圖片緩存管理
class ImageCacheManager {
  static const int maxCacheSize = 100; // 最大緩存圖片數量
  static final Map<String, ImageProvider> _imageCache = {};
  
  // 獲取緩存的圖片
  static ImageProvider? getCachedImage(String url) {
    return _imageCache[url];
  }

  // 緩存圖片
  static void cacheImage(String url, ImageProvider imageProvider) {
    if (_imageCache.length >= maxCacheSize) {
      // 移除最舊的緩存
      final oldestKey = _imageCache.keys.first;
      _imageCache.remove(oldestKey);
    }
    
    _imageCache[url] = imageProvider;
  }

  // 清除圖片緩存
  static void clearImageCache() {
    _imageCache.clear();
    if (kDebugMode) {
      debugPrint('🗑️ 圖片緩存已清除');
    }
  }

  // 獲取緩存統計
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_images': _imageCache.length,
      'max_cache_size': maxCacheSize,
      'cache_usage': '${(_imageCache.length / maxCacheSize * 100).toStringAsFixed(1)}%',
    };
  }
}

// 懶加載管理器
class LazyLoadManager {
  static const int defaultPageSize = 20;
  static final Map<String, LazyLoadState> _lazyLoadStates = {};
  
  // 獲取懶加載狀態
  static LazyLoadState getLazyLoadState(String key) {
    return _lazyLoadStates[key] ?? LazyLoadState();
  }

  // 更新懶加載狀態
  static void updateLazyLoadState(String key, LazyLoadState state) {
    _lazyLoadStates[key] = state;
  }

  // 清除懶加載狀態
  static void clearLazyLoadState(String key) {
    _lazyLoadStates.remove(key);
  }
}

// 懶加載狀態
class LazyLoadState {
  final List<dynamic> items;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  LazyLoadState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  LazyLoadState copyWith({
    List<dynamic>? items,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return LazyLoadState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}
