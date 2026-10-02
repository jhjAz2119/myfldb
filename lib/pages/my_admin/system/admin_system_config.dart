import 'package:flutter/material.dart';
import '../shared/admin_app_bar.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_theme.dart';

class AdminSystemConfig extends StatefulWidget {
  const AdminSystemConfig({super.key});
  @override
  State<AdminSystemConfig> createState() => _AdminSystemConfigState();
}

class _AdminSystemConfigState extends State<AdminSystemConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 6),
          Expanded(
            child: Column(
              children: [
                const AdminAppBar(title: '系统管理'),
                Expanded(
                  child: Container(
                    color: AdminTheme.bgPrimary,
                    child: const Center(
                      child: Text('系统管理 — 开发中', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
