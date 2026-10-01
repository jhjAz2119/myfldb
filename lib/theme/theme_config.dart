import 'package:flutter/material.dart';

class AppTheme {
  // ========== 背景色 —— 清新渐变 ==========
  static const Color bgStart = Color(0xFFE8F5F2);
  static const Color bgMiddle = Color(0xFFF0F7F5);
  static const Color bgEnd = Color(0xFFF8FBFA);

  // ========== 主色调 ==========
  static const Color primary = Color(0xFF4DB6AC);
  static const Color focus = Color(0xFF26A69A);
  static const Color cardBg = Colors.white;

  // ========== 文字色 ==========
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color textLight = Color(0xFF999999);

  // ========== 按钮基础 ==========
  static const Color buttonBg = primary;
  static const Color buttonText = Colors.white;

  // ========== 边框 ==========
  static const Color border = Color(0xFFE0E2E2);

  // ========== 圆角 ==========
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 16;

  // ========== 间距 ==========
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 32);
  static const EdgeInsets cardPadding = EdgeInsets.all(28);
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;

  // ========== 文字样式 ==========
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

  // ========== 个人信息页面按钮 —— 新增 统一管理 ==========
  static const double profileBtnHeight = 52;
  static const double profileBtnIconSize = 20;
  static const double profileBtnFontSize = 16;

  // 普通按钮（账号信息、安全中心、关于我们）
  static const Color profileBtnNormalBg = Colors.transparent;
  static const Color profileBtnNormalText = textPrimary;
  static const Color profileBtnNormalIcon = primary;
  static const double profileBtnElevation = 0;

  // 退出登录按钮
  static const Color profileBtnDangerBg = Color(0xFFFFEBEB);
  static const Color profileBtnDangerText = Color(0xFFE53935);
  static const Color profileBtnDangerIcon = Color(0xFFE53935);

  // 右侧箭头
  static const Color profileBtnArrow = textLight;
  static const double profileBtnArrowSize = 18;

  // ========== 背景渐变 ==========
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgStart, bgMiddle, bgEnd],
  );
  static BoxDecoration get background =>
      const BoxDecoration(gradient: backgroundGradient);
}
