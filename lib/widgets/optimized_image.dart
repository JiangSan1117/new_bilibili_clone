// lib/widgets/optimized_image.dart

import 'package:flutter/material.dart';
import 'dart:io';
import '../services/performance_service.dart';

class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String quality; // thumbnail, medium, high, original
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableCaching;
  final bool enableCompression;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.quality = 'medium',
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableCaching = true,
    this.enableCompression = true,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with AutomaticKeepAliveClientMixin {
  late ImageProvider _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    PerformanceService.startTimer('load_image_${widget.imageUrl.hashCode}');
    
    try {
      // 檢查緩存
      if (widget.enableCaching) {
        final cachedImage = ImageCacheManager.getCachedImage(widget.imageUrl);
        if (cachedImage != null) {
          _imageProvider = cachedImage;
          setState(() {
            _isLoading = false;
          });
          PerformanceService.stopTimer('load_image_${widget.imageUrl.hashCode}');
          return;
        }
      }

      // 創建圖片提供者
      if (widget.imageUrl.startsWith('http')) {
        _imageProvider = NetworkImage(widget.imageUrl);
      } else if (widget.imageUrl.startsWith('file://')) {
        _imageProvider = FileImage(File(widget.imageUrl.substring(7)));
      } else {
        _imageProvider = FileImage(File(widget.imageUrl));
      }

      // 緩存圖片
      if (widget.enableCaching) {
        ImageCacheManager.cacheImage(widget.imageUrl, _imageProvider);
      }

      setState(() {
        _isLoading = false;
      });
      
      PerformanceService.stopTimer('load_image_${widget.imageUrl.hashCode}');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      PerformanceService.stopTimer('load_image_${widget.imageUrl.hashCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget imageWidget;

    if (_hasError) {
      imageWidget = widget.errorWidget ?? _buildDefaultErrorWidget();
    } else if (_isLoading) {
      imageWidget = widget.placeholder ?? _buildDefaultPlaceholder();
    } else {
      imageWidget = Image(
        image: _imageProvider,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildDefaultErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return widget.placeholder ?? _buildLoadingPlaceholder(loadingProgress);
        },
      );
    }

    // 應用圓角
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ImageChunkEvent loadingProgress) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
            if (loadingProgress.expectedTotalBytes != null) ...[
              const SizedBox(height: 8),
              Text(
                '${(loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            '圖片載入失敗',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// 優化的頭像組件
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackText;
  final Color? backgroundColor;
  final Color? textColor;

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText = 'U',
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? OptimizedImage(
              imageUrl: imageUrl!,
              width: radius * 2,
              height: radius * 2,
              quality: 'thumbnail',
              borderRadius: BorderRadius.circular(radius),
              placeholder: _buildAvatarPlaceholder(),
              errorWidget: _buildAvatarFallback(),
            )
          : _buildAvatarFallback(),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Text(
      fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : 'U',
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontSize: radius * 0.6,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// 圖片預覽組件
class ImagePreview extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final bool showPageIndicator;

  const ImagePreview({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.showPageIndicator = true,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.showPageIndicator
            ? Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: OptimizedImage(
                    imageUrl: widget.imageUrls[index],
                    quality: 'high',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          if (widget.showPageIndicator && widget.imageUrls.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
