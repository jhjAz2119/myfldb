import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'api_service.dart';
import 'widgets/common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return AppScaffold(
      title: "账号信息",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "个人资料",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // 展示信息
            _infoRow("账号", user.account ?? "-"),
            _infoRow("昵称", user.nickname ?? "-"),
            _infoRow("性别", user.gender ?? "未设置"),
            _infoRow("生日", user.birthday ?? "未设置"),

            const SizedBox(height: 32),

            // 编辑按钮
            AppButton(
              text: "修改资料",
              onTap: () => _showEditDialog(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showEditDialog(UserProvider user) {
    final nickCtrl = TextEditingController(text: user.nickname);
    final birthCtrl = TextEditingController(text: user.birthday ?? "");
    String selectedGender = user.gender ?? "未设置";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("修改个人信息"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nickCtrl,
                decoration: const InputDecoration(labelText: "昵称"),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (_, setDialogState) => DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: "性别"),
                  items: const [
                    DropdownMenuItem(value: "未设置", child: Text("未设置")),
                    DropdownMenuItem(value: "男", child: Text("男")),
                    DropdownMenuItem(value: "女", child: Text("女")),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedGender = val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: birthCtrl,
                decoration: const InputDecoration(
                  labelText: "生日",
                  hintText: "格式：2000-01-01",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          ElevatedButton(
            child: const Text("保存"),
            onPressed: () async {
              final res = await ApiService.updateProfile(
                account: user.account!,
                nickname: nickCtrl.text.trim(),
                gender: selectedGender,
                birthday: birthCtrl.text.trim(),
              );
              if (res["code"] == 200 && ctx.mounted) {
                final newData = await ApiService.getProfile(user.account!);
                if (newData["code"] == 200 && mounted) {
                  await user.saveProfile(newData["data"]);
                }
                Navigator.pop(ctx); // 关弹窗
                if (context.mounted) Navigator.pop(context); // 回上一页
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("保存成功")),
                );
              } else if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res["detail"] ?? "保存失败")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
