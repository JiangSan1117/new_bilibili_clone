// lib/utils/date_utils.dart
import 'package:intl/intl.dart';

class DateUtils {
  // 格式化日期时间
  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy/MM/dd HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  // 格式化日期
  static String formatDate(DateTime dateTime, {String format = 'yyyy/MM/dd'}) {
    return DateFormat(format).format(dateTime);
  }

  // 格式化时间
  static String formatTime(DateTime dateTime, {String format = 'HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  // 相对时间显示（如：1分钟前，2小时前）
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  // 检查是否为今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // 检查是否为昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  // 获取友好的日期显示
  static String getFriendlyDate(DateTime dateTime) {
    if (isToday(dateTime)) {
      return '今天 ${formatTime(dateTime)}';
    } else if (isYesterday(dateTime)) {
      return '昨天 ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }
}
