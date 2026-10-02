//日志管理
import 'package:flutter/material.dart';
import '../admin_theme.dart';

class OperationLogSubpage extends StatefulWidget {
  const OperationLogSubpage({super.key});

  @override
  State<OperationLogSubpage> createState() => _OperationLogSubpageState();
}

class _OperationLogSubpageState extends State<OperationLogSubpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: const Center(
        child: Text(
          '操作日志页面 — 待完善',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
