import 'package:flutter/material.dart';

class AppTheme {
  // 背景色 —— 清新渐变
  static const Color bgStart = Color(0xFFE8F5F2);
  static const Color bgMiddle = Color(0xFFF0F7F5);
  static const Color bgEnd = Color(0xFFF8FBFA);

  // 主色调
  static const Color primary = Color(0xFF4DB6AC);
  static const Color focus = Color(0xFF26A69A);
  static const Color cardBg = Colors.white;

  // 文字色
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color textLight = Color(0xFF999999); // 浅灰色
  // 按钮
  static const Color buttonBg = primary;
  static const Color buttonText = Colors.white;

  // 边框
  static const Color border = Color(0xFFE0E2E2);

  // 圆角
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 16;

  // 间距
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 32);
  static const EdgeInsets cardPadding = EdgeInsets.all(28);

  // 文字样式
  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: 14,
    color: primary,
    decoration: TextDecoration.none,
  );

  // ✅ 背景渐变 —— 统一调用
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgStart, bgMiddle, bgEnd],
  );

  // ✅ 直接获取背景装饰
  static BoxDecoration get background =>
      const BoxDecoration(gradient: backgroundGradient);
}
