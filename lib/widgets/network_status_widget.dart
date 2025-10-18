// lib/widgets/network_status_widget.dart

import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../services/error_handler_service.dart';

class NetworkStatusWidget extends StatefulWidget {
  final Widget child;
  final bool showOfflineIndicator;
  final VoidCallback? onRetry;

  const NetworkStatusWidget({
    super.key,
    required this.child,
    this.showOfflineIndicator = true,
    this.onRetry,
  });

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkStatus();
  }

  Future<void> _initializeNetworkStatus() async {
    final isConnected = await NetworkService.isConnected();
    setState(() {
      _currentStatus = isConnected 
          ? NetworkStatus.connected 
          : NetworkStatus.disconnected;
      _isVisible = !isConnected;
    });

    // 監聽網絡狀態變化
    NetworkService.networkStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
          _isVisible = status == NetworkStatus.disconnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOfflineIndicator && _isVisible)
          _buildOfflineIndicator(),
      ],
    );
  }

  Widget _buildOfflineIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '您目前處於離線模式',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.onRetry != null)
                GestureDetector(
                  onTap: widget.onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '重試',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 網絡狀態按鈕
class NetworkStatusButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const NetworkStatusButton({
    super.key,
    this.onPressed,
  });

  @override
  State<NetworkStatusButton> createState() => _NetworkStatusButtonState();
}

class _NetworkStatusButtonState extends State<NetworkStatusButton> {
  NetworkStatus _currentStatus = NetworkStatus.unknown;

  @override
  void initState() {
    super.initState();
    _initializeNetworkStatus();
  }

  Future<void> _initializeNetworkStatus() async {
    final isConnected = await NetworkService.isConnected();
    setState(() {
      _currentStatus = isConnected 
          ? NetworkStatus.connected 
          : NetworkStatus.disconnected;
    });

    // 監聽網絡狀態變化
    NetworkService.networkStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (_currentStatus == NetworkStatus.disconnected) {
          ErrorHandlerService.showNetworkErrorDialog(context);
        } else {
          widget.onPressed?.call();
        }
      },
      icon: Icon(
        _getNetworkIcon(),
        color: _getNetworkColor(),
      ),
      tooltip: _getNetworkTooltip(),
    );
  }

  IconData _getNetworkIcon() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.wifi_find;
    }
  }

  Color _getNetworkColor() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.unknown:
        return Colors.orange;
    }
  }

  String _getNetworkTooltip() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return '網絡已連接';
      case NetworkStatus.disconnected:
        return '網絡未連接';
      case NetworkStatus.unknown:
        return '網絡狀態未知';
    }
  }
}

// 錯誤重試按鈕
class ErrorRetryButton extends StatelessWidget {
  final VoidCallback onRetry;
  final String? errorMessage;
  final bool isLoading;

  const ErrorRetryButton({
    super.key,
    required this.onRetry,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? '出現錯誤',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onRetry,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(isLoading ? '重試中...' : '重試'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
