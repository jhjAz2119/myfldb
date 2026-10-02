import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;

  const AdminAppBar({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
