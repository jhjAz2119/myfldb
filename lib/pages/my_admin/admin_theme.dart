//统一样式
import 'package:flutter/material.dart';

class AdminTheme {
  // === 颜色 ===
  static const Color bgPrimary = Color(0xFFF8F9FA);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgSidebar = Color(0xFF1E293B);
  static const Color primary = Color(0xFF4DB6AC);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // === 尺寸 ===
  static const double sidebarWidth = 240;
  static const double radiusMd = 12;
  static const double radiusSm = 8;
  static const EdgeInsets contentPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);

  // === 按钮样式 ===
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(100, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );

  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: danger,
    foregroundColor: Colors.white,
    minimumSize: const Size(100, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );

  static ButtonStyle outlineButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: primary,
    minimumSize: const Size(100, 44),
    side: const BorderSide(color: primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );

  // === 布局外壳 ===
  static Widget buildFullScreen({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }

  static Widget buildSidebarContainer({required Widget child}) {
    return SizedBox(
      width: sidebarWidth,
      child: child,
    );
  }

  static Widget buildContentArea({required Widget child}) {
    return Expanded(child: child);
  }

  static Widget buildContentWithBar({
    required PreferredSizeWidget appBar,
    required Widget body,
  }) {
    return Column(
      children: [
        appBar,
        Expanded(child: body),
      ],
    );
  }
}
