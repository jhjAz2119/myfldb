import 'package:flutter/material.dart';
import 'admin_theme.dart';
import '../../../user_provider.dart';
import 'package:provider/provider.dart';

// 各子页面导入
import '../dashboard/admin_dashboard.dart';
import '../users/admin_user_list.dart';
import '../users/admin_user_verify.dart';
import '../finance/admin_recharge_audit.dart';
import '../finance/admin_withdraw_audit.dart';
import '../project/admin_project_list.dart';
import '../system/admin_system_config.dart';
import '../log/admin_operation_log.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  const AdminSidebar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AdminTheme.bgSidebar,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ========== 后台标题区 ==========
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '管理后台',
                  style: TextStyle(
                    color: AdminTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<UserProvider>(
                  builder: (_, user, __) => Text(
                    '${user.account ?? '管理员'} 您好',
                    style: TextStyle(
                      color: AdminTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========== 菜单项 ==========
          _buildMenuItem(
            context,
            index: 0,
            icon: Icons.dashboard_outlined,
            label: '数据统计',
            page: const AdminDashboard(),
          ),

          _buildGroupTitle('用户管理'),
          _buildMenuItem(
            context,
            index: 1,
            icon: Icons.people_outline,
            label: '用户列表',
            page: const AdminUserList(),
          ),
          _buildMenuItem(
            context,
            index: 2,
            icon: Icons.verified_user_outlined,
            label: '身份认证审核',
            page: const AdminUserVerify(),
          ),

          _buildGroupTitle('资金管理'),
          _buildMenuItem(
            context,
            index: 3,
            icon: Icons.monetization_on_outlined,
            label: '充值审核',
            page: const AdminRechargeAudit(),
          ),
          _buildMenuItem(
            context,
            index: 4,
            icon: Icons.account_balance_wallet_outlined,
            label: '提现审核',
            page: const AdminWithdrawAudit(),
          ),

          _buildGroupTitle('项目管理'),
          _buildMenuItem(
            context,
            index: 5,
            icon: Icons.folder_open_outlined,
            label: '项目管理',
            page: const AdminProjectList(),
          ),

          _buildGroupTitle('系统'),
          _buildMenuItem(
            context,
            index: 6,
            icon: Icons.settings_outlined,
            label: '系统管理',
            page: const AdminSystemConfig(),
          ),
          _buildMenuItem(
            context,
            index: 7,
            icon: Icons.history_outlined,
            label: '日志管理',
            page: const AdminOperationLog(),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFF334155)),
          _buildBackToFront(context),
        ],
      ),
    );
  }

  // 分组标题
  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AdminTheme.textLight.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
    );
  }

  // 单个菜单项
  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AdminTheme.textWhite : AdminTheme.textLight,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AdminTheme.textWhite : AdminTheme.textLight,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AdminTheme.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        ),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }

  // 返回前台按钮
  Widget _buildBackToFront(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: Icon(
          Icons.arrow_back_outlined,
          color: AdminTheme.textLight,
          size: 20,
        ),
        title: Text(
          '返回前台',
          style: TextStyle(color: AdminTheme.textLight, fontSize: 14),
        ),
        onTap: () => Navigator.pop(context),
      ),
    );
  }
}
