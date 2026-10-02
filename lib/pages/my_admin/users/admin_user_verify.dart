import 'package:flutter/material.dart';
import '../shared/admin_app_bar.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_theme.dart';

class AdminUserVerify extends StatefulWidget {
  const AdminUserVerify({super.key});
  @override
  State<AdminUserVerify> createState() => _AdminUserVerifyState();
}

class _AdminUserVerifyState extends State<AdminUserVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                const AdminAppBar(title: '身份认证审核'),
                Expanded(
                  child: Container(
                    color: AdminTheme.bgPrimary,
                    child: const Center(
                      child:
                          Text('身份认证审核 — 开发中', style: TextStyle(fontSize: 18)),
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
