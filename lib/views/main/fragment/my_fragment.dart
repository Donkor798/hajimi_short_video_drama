import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/sv_cache_image.dart';
import '../../../viewmodels/my_view_model.dart';
import '../main_router.dart';

/// 我的
/// 页面说明：展示用户头像/昵称/ID、收藏数量、观看历史数量；移除“常用入口/操作”，改为“其他功能”：更换头像/随机昵称/复制ID
/// author : Donkor , 创建日期: 2025-09-11
class MyFragment extends StatelessWidget {
  const MyFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyViewModel()..init(),
      child: Scaffold(
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: AppColors.background,
        appBar: GradientAppBar(
          titleText: context.tr('mine'),
          showBack: false,
        ),
        body: Consumer<MyViewModel>(
          builder: (context, vm, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileCard(context, vm),
                const SizedBox(height: 20),
                _buildQuickActions(context, vm),
                const SizedBox(height: 20),
                _buildFunctionList(context, vm),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 用户信息卡片（美化版）
  Widget _buildProfileCard(BuildContext context, MyViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.12), Theme.of(context).colorScheme.primary.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          // 头像容器（带装饰边框）
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(2),
              child: SvCacheImage.avatar(
                imageUrl: vm.avatarUrl,
                size: 64,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.nickname.isNotEmpty ? vm.nickname : context.tr('local_user'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${vm.userId.isNotEmpty ? vm.userId : '—'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 编辑按钮
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('feature_wip'))),
              );
            },
            icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }




  /// 快捷操作区域
  Widget _buildQuickActions(BuildContext context, MyViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('quick_actions'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  icon: Icons.refresh,
                  label: context.tr('refresh_avatar'),
                  color: Colors.purple,
                  onTap: () async {
                    await vm.refreshAvatar();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('avatar_updated'))),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  icon: Icons.shuffle,
                  label: context.tr('random_nickname'),
                  color: Colors.orange,
                  onTap: () async {
                    await vm.regenerateNickname();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('nickname_updated'))),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  context,
                  icon: Icons.copy,
                  label: context.tr('copy_id'),
                  color: Colors.teal,
                  onTap: () async {
                    await vm.copyUserId();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('copied'))),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 快捷操作项组件
  Widget _buildQuickActionItem(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 功能列表区域
  Widget _buildFunctionList(BuildContext context, MyViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 观看历史
          _buildFunctionItem(
            context,
            icon: Icons.history,
            iconColor: Theme.of(context).colorScheme.primary,
            title: context.tr('play_history'),
            subtitle: context.tr('view_watch_history'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('feature_wip'))));
            },
          ),
          _buildDivider(context),

          // 下载管理
          _buildFunctionItem(
            context,
            icon: Icons.download,
            iconColor: Colors.green,
            title: context.tr('download_manager'),
            subtitle: context.tr('offline_videos'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('feature_wip'))));
            },
          ),
          _buildDivider(context),

          // 设置
          _buildFunctionItem(
            context,
            icon: Icons.settings,
            iconColor: Colors.grey[600]!,
            title: context.tr('settings'),
            subtitle: context.tr('app_preferences'),
            onTap: () {
              NavigatorUtils.push(context, MainRouter.settingsPage);
            },
          ),
          _buildDivider(context),

          // 关于
          _buildFunctionItem(
            context,
            icon: Icons.info,
            iconColor: Colors.blue,
            title: context.tr('about'),
            subtitle: context.tr('app_info'),
            onTap: () {
              NavigatorUtils.push(context, MainRouter.aboutPage);
            },
          ),
          _buildDivider(context),

          // 退出登录
          _buildFunctionItem(
            context,
            icon: Icons.logout,
            iconColor: Colors.red,
            title: context.tr('logout'),
            subtitle: context.tr('logout_account'),
            titleColor: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// 分隔线
  Widget _buildDivider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  /// 功能项组件（增强版）
  Widget _buildFunctionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('logout_confirm_title')),
          content: Text(context.tr('logout_confirm_message')),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBack(context),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                NavigatorUtils.goBack(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('logout_success'))),
                );
              },
              child: Text(context.tr('confirm'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
