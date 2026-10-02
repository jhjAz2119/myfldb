//充值审核
import 'package:flutter/material.dart';
import '../admin_theme.dart';

class RechargeAuditSubpage extends StatefulWidget {
  const RechargeAuditSubpage({super.key});

  @override
  State<RechargeAuditSubpage> createState() => _RechargeAuditSubpageState();
}

class _RechargeAuditSubpageState extends State<RechargeAuditSubpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: const Center(
        child: Text(
          '充值审核页面 — 待完善',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
