//提现审核
import 'package:flutter/material.dart';
import '../admin_theme.dart';

class WithdrawAuditSubpage extends StatefulWidget {
  const WithdrawAuditSubpage({super.key});

  @override
  State<WithdrawAuditSubpage> createState() => _WithdrawAuditSubpageState();
}

class _WithdrawAuditSubpageState extends State<WithdrawAuditSubpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: const Center(
        child: Text(
          '提现审核页面 — 待完善',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
