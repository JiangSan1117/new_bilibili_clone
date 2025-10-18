import 'package:flutter/material.dart';
import '../services/real_api_service.dart';
import '../pages/user_profile_page.dart';

class InteractionButtons extends StatefulWidget {
  final String postId;
  final String userId;
  final int initialLikes;
  final int initialComments;
  final bool isLiked;
  final String authorId;
  final bool isFollowing;
  final VoidCallback? onCommentPressed;

  const InteractionButtons({
    super.key,
    required this.postId,
    required this.userId,
    required this.initialLikes,
    required this.initialComments,
    this.isLiked = false,
    required this.authorId,
    this.isFollowing = false,
    this.onCommentPressed,
  });

  @override
  State<InteractionButtons> createState() => _InteractionButtonsState();
}

class _InteractionButtonsState extends State<InteractionButtons> {
  late int _likeCount;
  late int _commentCount;
  late bool _isLiked;
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikes;
    _commentCount = widget.initialComments;
    _isLiked = widget.isLiked;
    _isFollowing = widget.isFollowing;
  }

  Future<void> _toggleLike() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RealApiService.toggleLikePost(
        postId: widget.postId,
        userId: widget.userId,
      );

      if (result['success'] == true) {
        setState(() {
          _isLiked = result['isLiked'] ?? false;
          _likeCount = result['likeCount'] ?? 0;
        });
      } else {
        _showSnackBar('操作失敗: ${result['error']}');
      }
    } catch (e) {
      _showSnackBar('網絡錯誤: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RealApiService.toggleFollowUser(
        targetUserId: widget.authorId,
      );

      if (result['success'] == true) {
        setState(() {
          _isFollowing = result['isFollowing'] ?? false;
        });
        
        final message = _isFollowing ? '已關注' : '已取消關注';
        _showSnackBar(message);
      } else {
        _showSnackBar('操作失敗: ${result['error']}');
      }
    } catch (e) {
      _showSnackBar('網絡錯誤: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => CommentDialog(
        postId: widget.postId,
        userId: widget.userId,
        onCommentAdded: () {
          setState(() {
            _commentCount++;
          });
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 跳轉到用戶資料頁面
  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          userId: widget.authorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 點讚按鈕
        InkWell(
          onTap: _toggleLike,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _likeCount.toString(),
                  style: TextStyle(
                    color: _isLiked ? Colors.red : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 評論按鈕
        InkWell(
          onTap: widget.onCommentPressed ?? _showCommentDialog,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _commentCount.toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 關注按鈕
        if (widget.authorId != widget.userId)
          InkWell(
            onTap: _toggleFollow,
            onLongPress: _navigateToUserProfile,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isFollowing ? Colors.grey.shade200 : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isFollowing ? '已關注' : '關注',
                style: TextStyle(
                  color: _isFollowing ? Colors.grey.shade600 : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // 分享按鈕
        InkWell(
          onTap: () {
            _showSnackBar('分享功能即將推出');
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Icon(
              Icons.share_outlined,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class CommentDialog extends StatefulWidget {
  final String postId;
  final String userId;
  final VoidCallback onCommentAdded;

  const CommentDialog({
    super.key,
    required this.postId,
    required this.userId,
    required this.onCommentAdded,
  });

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await RealApiService.commentPost(
        postId: widget.postId,
        userId: widget.userId,
        username: '當前用戶', // 應該從用戶資料獲取
        content: content,
      );

      if (result['success'] == true) {
        widget.onCommentAdded();
        _commentController.clear();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('評論已發布')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('評論失敗: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('網絡錯誤: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('發表評論'),
      content: TextField(
        controller: _commentController,
        decoration: const InputDecoration(
          hintText: '寫下你的想法...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        maxLength: 500,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitComment,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('發布'),
        ),
      ],
    );
  }
}