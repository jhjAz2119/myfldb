import 'package:flutter/material.dart';
import '../shared/admin_app_bar.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_theme.dart';

class AdminWithdrawAudit extends StatefulWidget {
  const AdminWithdrawAudit({super.key});
  @override
  State<AdminWithdrawAudit> createState() => _AdminWithdrawAuditState();
}

class _AdminWithdrawAuditState extends State<AdminWithdrawAudit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 4),
          Expanded(
            child: Column(
              children: [
                const AdminAppBar(title: '提现审核'),
                Expanded(
                  child: Container(
                    color: AdminTheme.bgPrimary,
                    child: const Center(
                      child: Text('提现审核 — 开发中', style: TextStyle(fontSize: 18)),
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
