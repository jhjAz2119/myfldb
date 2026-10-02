//身份认证审核
import 'package:flutter/material.dart';
import '../admin_theme.dart';
import '../admin_data_service.dart';

class UserVerifySubpage extends StatefulWidget {
  const UserVerifySubpage({super.key});

  @override
  State<UserVerifySubpage> createState() => _UserVerifySubpageState();
}

class _UserVerifySubpageState extends State<UserVerifySubpage> {
  bool _loading = true;
  List _verifyList = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadVerifyList();
  }

  Future<void> _loadVerifyList() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    // 后续可在 admin_data_service 添加 getVerifyList 方法
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _loading = false;
    });
  }

  Future<void> _handleVerify(dynamic userId, bool pass) async {
    final remarkCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pass ? '审核通过' : '审核驳回'),
        content: TextField(
          controller: remarkCtrl,
          decoration: const InputDecoration(labelText: '备注（可选）'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res =
        await AdminDataService.verifyUser(userId, pass, remarkCtrl.text.trim());
    if (res['success'] == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(pass ? '已通过' : '已驳回')));
      _loadVerifyList();
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
                        onPressed: _loadVerifyList,
                        style: AdminTheme.primaryButton,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return const Center(child: Text('待审核列表 — 接口完善后显示数据'));
  }
}
