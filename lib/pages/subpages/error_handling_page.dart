// lib/pages/subpages/error_handling_page.dart

import 'package:flutter/material.dart';
import '../../services/error_handler_service.dart';
import '../../services/network_service.dart';
import '../../services/offline_service.dart';
import '../../services/retry_service.dart';
import '../../widgets/sponsor_ad_widget.dart';

class ErrorHandlingPage extends StatefulWidget {
  const ErrorHandlingPage({super.key});

  @override
  State<ErrorHandlingPage> createState() => _ErrorHandlingPageState();
}

class _ErrorHandlingPageState extends State<ErrorHandlingPage> {
  bool _isLoading = false;
  Map<String, int> _offlineStats = {};

  @override
  void initState() {
    super.initState();
    _loadOfflineStats();
  }

  Future<void> _loadOfflineStats() async {
    try {
      final stats = await OfflineService.getOfflineDataStats();
      setState(() {
        _offlineStats = stats;
      });
    } catch (e) {
      debugPrint('載入離線統計失敗: $e');
    }
  }

  Future<void> _testNetworkConnection() async {
    setState(() => _isLoading = true);
    
    try {
      final isConnected = await NetworkService.isConnected();
      final hasInternet = await NetworkService.hasInternetConnection();
      final networkType = await NetworkService.getNetworkType();
      
      if (mounted) {
        _showNetworkTestDialog(isConnected, hasInternet, networkType);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('網絡測試失敗: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSync() async {
    setState(() => _isLoading = true);
    
    try {
      await OfflineService.performSync();
      await _loadOfflineStats();
      
      if (mounted) {
        _showSnackBar('同步完成');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('同步失敗: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearOfflineData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除離線數據'),
        content: const Text('確定要清除所有離線數據嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await OfflineService.clearAllOfflineData();
        await _loadOfflineStats();
        
        if (mounted) {
          _showSnackBar('離線數據已清除');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('清除失敗: ${e.toString()}');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNetworkTestDialog(bool isConnected, bool hasInternet, String networkType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('網絡測試結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestResult('設備連接', isConnected ? '已連接' : '未連接', isConnected),
            _buildTestResult('互聯網訪問', hasInternet ? '可用' : '不可用', hasInternet),
            _buildTestResult('網絡類型', networkType, true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResult(String label, String value, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$label: $value'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
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
        title: const Text('錯誤處理與網絡'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // 頂部贊助區
          const SponsorAdWidget(location: '錯誤處理頁面頂部贊助區'),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 網絡狀態測試
                  _buildNetworkTestSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 離線數據管理
                  _buildOfflineDataSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 錯誤處理測試
                  _buildErrorHandlingTestSection(),
                ],
              ),
            ),
          ),
          
          // 底部贊助區
          const SponsorAdWidget(location: '錯誤處理頁面底部贊助區'),
        ],
      ),
    );
  }

  Widget _buildNetworkTestSection() {
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
            '網絡狀態測試',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _testNetworkConnection,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.wifi),
            label: const Text('測試網絡連接'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineDataSection() {
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
            '離線數據管理',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_offlineStats.isNotEmpty) ...[
            Text(
              '離線數據統計:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ..._offlineStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${entry.key}: ${entry.value} 條',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _performSync,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('同步數據'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _clearOfflineData,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('清除數據'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHandlingTestSection() {
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
            '錯誤處理測試',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _testNetworkError(),
                child: const Text('網絡錯誤'),
              ),
              ElevatedButton(
                onPressed: () => _testServerError(),
                child: const Text('服務器錯誤'),
              ),
              ElevatedButton(
                onPressed: () => _testPermissionError(),
                child: const Text('權限錯誤'),
              ),
              ElevatedButton(
                onPressed: () => _testRetryMechanism(),
                child: const Text('重試機制'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _testNetworkError() {
    final errorInfo = ErrorInfo(
      type: ErrorType.network,
      message: '網絡連接失敗',
      canRetry: true,
    );
    
    ErrorHandlerService.showErrorDialog(
      context,
      errorInfo,
      onRetry: () => _showSnackBar('重試網絡連接'),
    );
  }

  void _testServerError() {
    final errorInfo = ErrorInfo(
      type: ErrorType.server,
      message: '服務器內部錯誤',
      canRetry: true,
    );
    
    ErrorHandlerService.showErrorDialog(
      context,
      errorInfo,
      onRetry: () => _showSnackBar('重試服務器請求'),
    );
  }

  void _testPermissionError() {
    final errorInfo = ErrorInfo(
      type: ErrorType.permission,
      message: '相機權限被拒絕',
      canRetry: false,
    );
    
    ErrorHandlerService.showErrorDialog(context, errorInfo);
  }

  Future<void> _testRetryMechanism() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await RetryService.retry(
        () async {
          // 模擬可能失敗的操作
          if (DateTime.now().millisecond % 2 == 0) {
            throw Exception('模擬的網絡錯誤');
          }
          return '操作成功';
        },
        maxAttempts: 3,
        delay: const Duration(seconds: 1),
      );
      
      if (mounted) {
        _showSnackBar(result ?? '重試後仍然失敗');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('重試機制測試完成: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
