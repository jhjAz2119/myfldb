import 'package:flutter/material.dart';
import '../../theme/theme_config.dart';

class HomeTabIndex extends StatelessWidget {
  const HomeTabIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.focus.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home, size: 48, color: AppTheme.focus),
          ),
          const SizedBox(height: 24),
          Text("首页", style: AppTheme.title),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.focus.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "这里添加首页内容",
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
