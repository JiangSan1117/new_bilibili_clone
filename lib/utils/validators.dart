// lib/utils/validators.dart
class FormValidators {
  // 邮箱验证
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }

    return null;
  }

  // 密码验证
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码至少需要6位字符';
    }

    if (value.length > 20) {
      return '密码不能超过20位字符';
    }

    return null;
  }

  // 必填字段验证
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }

    return null;
  }

  // 标题验证
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入标题';
    }

    if (value.trim().length < 3) {
      return '标题至少需要3个字符';
    }

    if (value.trim().length > 50) {
      return '标题不能超过50个字符';
    }

    return null;
  }

  // 内容验证
  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入内容';
    }

    if (value.trim().length < 10) {
      return '内容至少需要10个字符';
    }

    if (value.trim().length > 2000) {
      return '内容不能超过2000个字符';
    }

    return null;
  }

  // 手机号验证
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    }

    final phoneRegex = RegExp(r'^09[0-9]{8}$');

    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的台湾手机号码';
    }

    return null;
  }

  // 确认密码验证
  static String? validateConfirmPassword(
      String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }

    if (value != originalPassword) {
      return '两次输入的密码不一致';
    }

    return null;
  }
}
