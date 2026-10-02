//用户列表
import 'package:flutter/material.dart';
import '../admin_theme.dart';
import '../admin_data_service.dart';

class UserListSubpage extends StatefulWidget {
  const UserListSubpage({super.key});

  @override
  State<UserListSubpage> createState() => _UserListSubpageState();
}

class _UserListSubpageState extends State<UserListSubpage> {
  bool _loading = true;
  List _userList = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  Future<void> _loadUserList() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    final res = await AdminDataService.getUserList();
    if (res['success'] == true && mounted) {
      setState(() {
        _userList = res['data'] ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _errorMsg = res['message'] ?? '加载失败';
        _loading = false;
      });
    }
  }

  Future<void> _deleteUser(dynamic userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该用户吗？此操作不可恢复！'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await AdminDataService.deleteUser(userId);
    if (res['success'] == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('删除成功')));
      _loadUserList();
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['message'] ?? '删除失败')));
    }
  }

  Future<void> _toggleFreeze(dynamic userId, bool isFrozen) async {
    final res = await AdminDataService.toggleUserStatus(userId, !isFrozen);
    if (res['success'] == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(isFrozen ? '已解冻' : '已冻结')));
      _loadUserList();
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['message'] ?? '操作失败')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_errorMsg',
                          style: TextStyle(color: AdminTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserList,
                        style: AdminTheme.primaryButton,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : _buildTable(),
    );
  }

  Widget _buildTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AdminTheme.bgSecondary,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              ),
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: Text('账号')),
                  DataColumn(label: Text('昵称')),
                  DataColumn(label: Text('状态')),
                  DataColumn(label: Text('操作')),
                ],
                rows: _userList.map((user) {
                  final userId = user['id'] ?? user['user_id'];
                  final isFrozen = user['frozen'] == true;
                  return DataRow(cells: [
                    DataCell(Text(user['account']?.toString() ?? '')),
                    DataCell(Text(user['nickname']?.toString() ?? '')),
                    DataCell(Text(
                      isFrozen ? '已冻结' : '正常',
                      style: TextStyle(
                          color: isFrozen
                              ? AdminTheme.danger
                              : AdminTheme.success),
                    )),
                    DataCell(Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _toggleFreeze(userId, isFrozen),
                          style: AdminTheme.outlineButton,
                          child: Text(isFrozen ? '解冻' : '冻结'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _deleteUser(userId),
                          style: AdminTheme.dangerButton,
                          child: const Text('删除'),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
