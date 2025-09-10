import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/localization.dart';
import '../../../widgets/gradient_app_bar.dart';

/// 我的
/// 我的 页面
/// Author: Donkor
/// Created: 2025-09-10
class MyFragment extends StatelessWidget {
  const MyFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        titleText: context.tr('mine'),
        showBack: false,
      ),
      body: const Center(
        child: Text('我的页面 - 开发中'),
      ),
    );
  }
}

