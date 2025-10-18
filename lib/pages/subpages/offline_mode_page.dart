// lib/pages/subpages/offline_mode_page.dart

import 'package:flutter/material.dart';
import '../../services/offline_service.dart';
import '../../services/network_service.dart';
import '../../widgets/sponsor_ad_widget.dart';

class OfflineModePage extends StatefulWidget {
  const OfflineModePage({super.key});

  @override
  State<OfflineModePage> createState() => _OfflineModePageState();
}

class _OfflineModePageState extends State<OfflineModePage> {
  Map<String, int> _offlineStats = {};
  List<OfflineData> _offlineData = [];
  List<SyncOperation> _syncQueue = [];
  DateTime? _lastSyncTime;
  bool _isLoading = false;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
    _checkNetworkStatus();
  }

  Future<void> _loadOfflineData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await OfflineService.getOfflineDataStats();
      final offlineData = await OfflineService.getAllOfflineData();
      final syncQueue = await OfflineService.getSyncQueue();
      final lastSyncTime = await OfflineService.getLastSyncTime();
      
      setState(() {
        _offlineStats = stats;
        _offlineData = offlineData;
        _syncQueue = syncQueue;
        _lastSyncTime = lastSyncTime;
      });
    } catch (e) {
      _showSnackBar('載入離線數據失敗: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkNetworkStatus() async {
    final isConnected = await NetworkService.isConnected();
    setState(() {
      _isOfflineMode = !isConnected;
    });
  }

  Future<void> _performSync() async {
    setState(() => _isLoading = true);
    
    try {
      await OfflineService.performSync();
      await _loadOfflineData();
      _showSnackBar('同步完成');
    } catch (e) {
      _showSnackBar('同步失敗: ${e.toString()}');
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
        await _loadOfflineData();
        _showSnackBar('離線數據已清除');
      } catch (e) {
        _showSnackBar('清除失敗: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
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
        title: const Text('離線模式'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: _loadOfflineData,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 頂部贊助區
          const SponsorAdWidget(location: '離線模式頁面頂部贊助區'),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 網絡狀態卡片
                  _buildNetworkStatusCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 離線數據統計
                  _buildOfflineStatsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 同步隊列
                  _buildSyncQueueCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 離線數據列表
                  _buildOfflineDataCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 操作按鈕
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          
          // 底部贊助區
          const SponsorAdWidget(location: '離線模式頁面底部贊助區'),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isOfflineMode ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOfflineMode ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isOfflineMode ? Icons.wifi_off : Icons.wifi,
            color: _isOfflineMode ? Colors.orange.shade600 : Colors.green.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOfflineMode ? '離線模式' : '在線模式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isOfflineMode ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                ),
                Text(
                  _isOfflineMode 
                      ? '您目前無法訪問網絡，但可以瀏覽已緩存的內容'
                      : '網絡連接正常，可以同步數據',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isOfflineMode ? Colors.orange.shade600 : Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineStatsCard() {
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
            '離線數據統計',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_offlineStats.isEmpty)
            const Center(
              child: Text(
                '暫無離線數據',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._offlineStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDataTypeName(entry.key),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${entry.value} 條',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            )).toList(),
          
          if (_lastSyncTime != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.sync, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '最後同步: ${_formatDateTime(_lastSyncTime!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncQueueCard() {
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
          Row(
            children: [
              Text(
                '同步隊列',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_syncQueue.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_syncQueue.isEmpty)
            const Center(
              child: Text(
                '暫無待同步操作',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._syncQueue.take(5).map((operation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _getOperationIcon(operation.operation),
                    size: 16,
                    color: _getOperationColor(operation.operation),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_getOperationName(operation.operation)} ${_getDataTypeName(operation.type)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    _formatDateTime(operation.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          
          if (_syncQueue.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '還有 ${_syncQueue.length - 5} 個操作...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineDataCard() {
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
            '離線數據詳情',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_offlineData.isEmpty)
            const Center(
              child: Text(
                '暫無離線數據',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._offlineData.take(10).map((data) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _getDataTypeIcon(data.type),
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_getDataTypeName(data.type)} - ${data.id}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (data.isDirty)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(data.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          
          if (_offlineData.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '還有 ${_offlineData.length - 10} 個數據項...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isOfflineMode || _isLoading ? null : _performSync,
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
    );
  }

  String _getDataTypeName(String type) {
    switch (type) {
      case 'posts':
        return '文章';
      case 'comments':
        return '評論';
      case 'interactions':
        return '互動';
      case 'user_data':
        return '用戶數據';
      case 'notifications':
        return '通知';
      default:
        return type;
    }
  }

  IconData _getDataTypeIcon(String type) {
    switch (type) {
      case 'posts':
        return Icons.article;
      case 'comments':
        return Icons.comment;
      case 'interactions':
        return Icons.thumb_up;
      case 'user_data':
        return Icons.person;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.data_object;
    }
  }

  IconData _getOperationIcon(String operation) {
    switch (operation) {
      case 'create':
        return Icons.add;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.sync;
    }
  }

  Color _getOperationColor(String operation) {
    switch (operation) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getOperationName(String operation) {
    switch (operation) {
      case 'create':
        return '創建';
      case 'update':
        return '更新';
      case 'delete':
        return '刪除';
      default:
        return operation;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }
}
