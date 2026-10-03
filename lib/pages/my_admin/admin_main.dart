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
  int _selectedIndex = 0;

  // ========== 下面这一段完全不动 ==========
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
  // ======================================

  // ✅ 只新增：页面加载时检查权限
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      // 没有授权标记 → 直接踢回登录页
      if (args != 'admin_authorized') {
        Navigator.pushReplacementNamed(context, '/admin-login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ========== 下面的 build 代码完全不动，和你原来一样 ==========
    return Scaffold(
      body: AdminTheme.buildFullScreen(
        child: Row(
          children: [
            AdminTheme.buildSidebarContainer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ),
            AdminTheme.buildContentArea(
              child: AdminTheme.buildContentWithBar(
                appBar: AdminAppBar(title: _pageTitles[_selectedIndex]),
                body: _subpages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
