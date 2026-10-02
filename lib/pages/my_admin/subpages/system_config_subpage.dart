//系统管理
import 'package:flutter/material.dart';
import '../admin_theme.dart';

class SystemConfigSubpage extends StatefulWidget {
  const SystemConfigSubpage({super.key});

  @override
  State<SystemConfigSubpage> createState() => _SystemConfigSubpageState();
}

class _SystemConfigSubpageState extends State<SystemConfigSubpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: const Center(
        child: Text(
          '系统管理页面 — 待完善',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
