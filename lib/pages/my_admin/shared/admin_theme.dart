import 'package:flutter/material.dart';

class AdminTheme {
  // 背景色
  static const Color bgPrimary = Color(0xFFF5F7FA);
  static const Color bgCard = Colors.white;
  static const Color bgSidebar = Color(0xFF1E293B);

  // 主色调
  static const Color primary = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF26A69A);
  static const Color accent = Color(0xFFFF9800);

  // 文字色
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  // 状态色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color pending = Color(0xFF3B82F6);

  // 圆角
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;

  // 间距
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;

  // 卡片阴影
  static BoxShadow cardShadow = BoxShadow(
    color: const Color(0xFF00000D),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  // 卡片样式
  static CardDecoration cardDecoration = CardDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: [cardShadow],
  );

  // 按钮主样式
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // 次要按钮
  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE2E8F0),
    foregroundColor: textPrimary,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // 危险按钮
  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: error,
    foregroundColor: textWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

// 方便使用的扩展类
class CardDecoration extends BoxDecoration {
  const CardDecoration({
    super.color,
    super.borderRadius,
    super.boxShadow,
  });
}
