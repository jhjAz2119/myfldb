import 'package:flutter/material.dart';
import '../../theme/theme_config.dart';

class HomeTabRecommend extends StatelessWidget {
  const HomeTabRecommend({super.key});

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
            child: const Icon(Icons.thumb_up, size: 48, color: AppTheme.focus),
          ),
          const SizedBox(height: 24),
          Text("推荐", style: AppTheme.title),
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
            "这里添加推荐内容",
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
