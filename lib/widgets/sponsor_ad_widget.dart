// lib/widgets/sponsor_ad_widget.dart

import 'package:flutter/material.dart';

class SponsorAdWidget extends StatelessWidget {
  final String location;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SponsorAdWidget({
    super.key,
    required this.location,
    this.height = 60.0,
    this.backgroundColor,
    this.textColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant,
        // 移除邊框，改為全版面設計
      ),
      alignment: Alignment.center,
      child: Text(
        '贊助區廣告 ($location)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// 固定底部贊助區組件
class FixedBottomSponsorAd extends StatelessWidget {
  final String location;
  final double height;

  const FixedBottomSponsorAd({
    super.key,
    required this.location,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SponsorAdWidget(
        location: location,
        height: height,
      ),
    );
  }
}

// 頁面容器組件，包含上下贊助區
class PageWithSponsorAds extends StatelessWidget {
  final Widget child;
  final String topSponsorLocation;
  final String bottomSponsorLocation;
  final bool showTopSponsor;
  final bool showBottomSponsor;

  const PageWithSponsorAds({
    super.key,
    required this.child,
    required this.topSponsorLocation,
    required this.bottomSponsorLocation,
    this.showTopSponsor = true,
    this.showBottomSponsor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主要內容
          Column(
            children: [
              // 頂部贊助區
              if (showTopSponsor)
                SponsorAdWidget(location: topSponsorLocation),
              
              // 主要內容
              Expanded(child: child),
              
              // 為底部贊助區預留空間
              if (showBottomSponsor)
                SizedBox(height: 60), // 贊助區高度
            ],
          ),
          
          // 底部贊助區 - 固定在底部
          if (showBottomSponsor)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SponsorAdWidget(location: bottomSponsorLocation),
            ),
        ],
      ),
    );
  }
}
