// lib/utils/string_utils.dart
class StringUtils {
  // 检查字符串是否为空或null
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // 检查字符串是否不为空
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  // 限制字符串长度，超出部分用...代替
  static String limitLength(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // 格式化数字（如：1000 -> 1K）
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  // 隐藏部分邮箱（如：te***@example.com）
  static String hideEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return email;
    }

    final parts = email.split('@');
    if (parts[0].length <= 2) {
      return '***@${parts[1]}';
    }

    final hiddenPart = '${parts[0].substring(0, 2)}***';
    return '$hiddenPart@${parts[1]}';
  }

  // 隐藏部分手机号（如：0912***567）
  static String hidePhone(String phone) {
    if (phone.length < 7) {
      return phone;
    }

    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 3);
    return '$start***$end';
  }

  // 提取城市简称（如：台北市 -> 台北）
  static String getAbbreviatedCity(String fullCityName) {
    return fullCityName.replaceAll('縣', '').replaceAll('市', '');
  }

  // 检查是否为有效URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 从URL提取图片种子
  static String getImageSeed(String text) {
    return text.hashCode.toString();
  }
}
