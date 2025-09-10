import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/localization.dart';
import '../../../widgets/gradient_app_bar.dart';

/// 收藏页
/// Author: Donkor
/// Created: 2025-09-10
class FavoritesFragment extends StatelessWidget {
  const FavoritesFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        titleText: context.tr('favorites'),
        showBack: false,
      ),
      body: const Center(
        child: Text('收藏页面 - 开发中'),
      ),
    );
  }
}

