//侧边栏
import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AdminTheme.sidebarWidth,
      color: AdminTheme.bgSidebar,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 标题区
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
                Text(
                  '管理员 您好',
                  style: TextStyle(
                    color: AdminTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 菜单项
          _buildMenuItem(0, Icons.dashboard_outlined, '数据统计'),
          _buildGroupTitle('用户管理'),
          _buildMenuItem(1, Icons.people_outline, '用户列表'),
          _buildMenuItem(2, Icons.verified_user_outlined, '身份认证审核'),
          _buildGroupTitle('资金管理'),
          _buildMenuItem(3, Icons.monetization_on_outlined, '充值审核'),
          _buildMenuItem(4, Icons.account_balance_wallet_outlined, '提现审核'),
          _buildGroupTitle('项目管理'),
          _buildMenuItem(5, Icons.folder_open_outlined, '项目管理'),
          _buildGroupTitle('系统'),
          _buildMenuItem(6, Icons.settings_outlined, '系统管理'),
          _buildMenuItem(7, Icons.history_outlined, '日志管理'),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFF334155)),
          _buildBackButton(context),
        ],
      ),
    );
  }

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

  Widget _buildMenuItem(int index, IconData icon, String label) {
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
        onTap: () => onItemTapped(index),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
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
          style: TextStyle(
            color: AdminTheme.textLight,
            fontSize: 14,
          ),
        ),
        onTap: () => Navigator.pop(context),
      ),
    );
  }
}
