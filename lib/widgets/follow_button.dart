// lib/widgets/follow_button.dart

import 'package:flutter/material.dart';
import '../services/interaction_service.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final String currentUserId;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.currentUserId,
    this.onFollowChanged,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final isFollowing = await InteractionService.isFollowing(
        widget.currentUserId,
        widget.targetUserId,
      );
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      debugPrint('檢查關注狀態失敗: $e');
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final newFollowStatus = await InteractionService.toggleFollow(
        widget.currentUserId,
        widget.targetUserId,
      );
      setState(() {
        _isFollowing = newFollowStatus;
      });
      widget.onFollowChanged?.call();
      _showSnackBar(_isFollowing ? '已關注' : '已取消關注');
    } catch (e) {
      _showSnackBar('操作失敗: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    // 如果目標用戶是當前用戶，不顯示關注按鈕
    if (widget.targetUserId == widget.currentUserId) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing 
              ? Colors.grey.shade200 
              : Theme.of(context).primaryColor,
          foregroundColor: _isFollowing 
              ? Colors.grey.shade600 
              : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isFollowing 
                  ? Colors.grey.shade300 
                  : Theme.of(context).primaryColor,
            ),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isFollowing ? Colors.grey.shade600 : Colors.white,
                  ),
                ),
              )
            : Text(
                _isFollowing ? '已關注' : '+ 關注',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
