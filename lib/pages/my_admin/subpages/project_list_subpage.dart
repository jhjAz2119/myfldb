//项目管理
import 'package:flutter/material.dart';
import '../admin_theme.dart';

class ProjectListSubpage extends StatefulWidget {
  const ProjectListSubpage({super.key});

  @override
  State<ProjectListSubpage> createState() => _ProjectListSubpageState();
}

class _ProjectListSubpageState extends State<ProjectListSubpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: const Center(
        child: Text(
          '项目管理页面 — 待完善',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
