import 'package:flutter/material.dart';
import '../shared/admin_app_bar.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_theme.dart';

class AdminRechargeAudit extends StatefulWidget {
  const AdminRechargeAudit({super.key});
  @override
  State<AdminRechargeAudit> createState() => _AdminRechargeAuditState();
}

class _AdminRechargeAuditState extends State<AdminRechargeAudit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 3),
          Expanded(
            child: Column(
              children: [
                const AdminAppBar(title: '充值审核'),
                Expanded(
                  child: Container(
                    color: AdminTheme.bgPrimary,
                    child: const Center(
                      child: Text('充值审核 — 开发中', style: TextStyle(fontSize: 18)),
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
