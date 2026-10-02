//主框架入口
import 'package:flutter/material.dart';
import 'admin_theme.dart';
import 'admin_sidebar.dart';
import 'admin_app_bar.dart';
import 'subpages/dashboard_subpage.dart';
import 'subpages/user_list_subpage.dart';
import 'subpages/user_verify_subpage.dart';
import 'subpages/recharge_audit_subpage.dart';
import 'subpages/withdraw_audit_subpage.dart';
import 'subpages/project_list_subpage.dart';
import 'subpages/system_config_subpage.dart';
import 'subpages/operation_log_subpage.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0; // ✅ 只变这个数字，外壳永远不重建

  // ✅ 子页面列表 — 顺序和侧边栏菜单一一对应
  static const List<Widget> _subpages = [
    DashboardSubpage(),
    UserListSubpage(),
    UserVerifySubpage(),
    RechargeAuditSubpage(),
    WithdrawAuditSubpage(),
    ProjectListSubpage(),
    SystemConfigSubpage(),
    OperationLogSubpage(),
  ];

  // ✅ 顶部标题 — 顺序同上
  static const List<String> _pageTitles = [
    '数据统计',
    '用户列表',
    '身份认证审核',
    '充值审核',
    '提现审核',
    '项目管理',
    '系统管理',
    '日志管理',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ 最外层固定不动，防止抖动
      body: AdminTheme.buildFullScreen(
        child: Row(
          children: [
            // ✅ 左侧：固定侧边栏（只建一次，不销毁）
            AdminTheme.buildSidebarContainer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  setState(() => _selectedIndex = index); // ✅ 只改数字，不跳转页面
                },
              ),
            ),

            // ✅ 右侧：只换子页面内容，外壳不动
            AdminTheme.buildContentArea(
              child: AdminTheme.buildContentWithBar(
                appBar: AdminAppBar(title: _pageTitles[_selectedIndex]),
                body: _subpages[_selectedIndex], // ✅ 切换子页面
              ),
            ),
          ],
        ),
      ),
    );
  }
}
