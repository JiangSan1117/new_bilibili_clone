// lib/pages/chat_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/real_api_service.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String participantName;
  final String participantAvatar;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.participantName,
    required this.participantAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('💬 ChatPage: 開始加載訊息 - conversationId: ${widget.conversationId}');
      final result = await RealApiService.getConversationMessages(
        conversationId: widget.conversationId,
      );
      print('💬 ChatPage: API響應: $result');
      
      if (result['success'] == true) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(result['messages'] ?? []);
          _isLoading = false;
        });
        print('💬 ChatPage: 獲取到 ${_messages.length} 條訊息');
        
        // 滾動到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          _error = result['error'] ?? '載入訊息失敗';
          _isLoading = false;
        });
        print('💬 ChatPage: 載入失敗: $_error');
      }
    } catch (e) {
      setState(() {
        _error = '載入訊息失敗: $e';
        _isLoading = false;
      });
      print('💬 ChatPage: 載入錯誤: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // 清空輸入框
    _messageController.clear();

    // 添加臨時訊息到列表（優化用戶體驗）
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?['id'] ?? 'current_user';
    
    final tempMessage = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'sender': currentUserId,
      'receiver': widget.conversationId.split('_')[1], // 簡化處理
      'content': content,
      'isRead': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(tempMessage);
    });

    // 滾動到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final result = await RealApiService.sendMessage(
        conversationId: widget.conversationId,
        content: content,
      );

      if (result['success'] == true) {
        // 移除臨時訊息，添加真實訊息
        setState(() {
          _messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
          _messages.add(result['message']);
        });
      } else {
        // 發送失敗，移除臨時訊息並顯示錯誤
        setState(() {
          _messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發送失敗: ${result['error']}')),
        );
      }
    } catch (e) {
      // 發送失敗，移除臨時訊息並顯示錯誤
      setState(() {
        _messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送失敗: $e')),
      );
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return '';
    
    try {
      final time = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(time);
      
      if (difference.inDays > 0) {
        return DateFormat('MM/dd HH:mm').format(time);
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小時前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分鐘前';
      } else {
        return '剛剛';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.participantAvatar),
            ),
            const SizedBox(width: 12),
            Text(widget.participantName),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 訊息列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              child: const Text('重試'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  '開始聊天吧！',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final currentUserId = authProvider.currentUser?['id'] ?? 'current_user';
                              final isMe = message['sender'] == currentUserId;
                              
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue.shade500 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['content'] ?? '',
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTime(message['createdAt']),
                                        style: TextStyle(
                                          color: isMe ? Colors.white70 : Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          
          // 輸入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '輸入訊息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}