import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF6366F1); // 靛蓝色
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  
  // 辅助色
  static const Color secondary = Color(0xFFEC4899); // 粉色
  static const Color secondaryDark = Color(0xFFDB2777);
  static const Color secondaryLight = Color(0xFFF472B6);
  
  // 背景色
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // 文本色
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // 状态色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // 边框色
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  
  // 分割线色
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);
  
  // 阴影色
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
  
  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 卡片颜色
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E293B);
  
  // 输入框颜色
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color inputBackgroundDark = Color(0xFF334155);
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color inputBorderDark = Color(0xFF475569);
  
  // 按钮颜色
  static const Color buttonDisabled = Color(0xFFCBD5E1);
  static const Color buttonDisabledDark = Color(0xFF475569);
}
