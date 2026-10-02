import 'package:flutter/material.dart';
import '../shared/admin_app_bar.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_theme.dart';

class AdminOperationLog extends StatefulWidget {
  const AdminOperationLog({super.key});
  @override
  State<AdminOperationLog> createState() => _AdminOperationLogState();
}

class _AdminOperationLogState extends State<AdminOperationLog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 7),
          Expanded(
            child: Column(
              children: [
                const AdminAppBar(title: '日志管理'),
                Expanded(
                  child: Container(
                    color: AdminTheme.bgPrimary,
                    child: const Center(
                      child: Text('日志管理 — 开发中', style: TextStyle(fontSize: 18)),
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
