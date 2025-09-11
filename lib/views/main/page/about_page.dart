import 'package:flutter/material.dart';
import '../../../utils/localization.dart';
import '../../../widgets/gradient_app_bar.dart';

/// 关于页面
/// 页面说明：展示应用信息（名称、版本）、作者与开源信息，提供反馈/协议入口
/// author : Donkor , 创建日期(2025-09-11)
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String appVersion = '1.0.0+1'; // 从 pubspec.yaml 复制，若更新版本请同步此常量

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        titleText: context.tr('about'),
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildInfoCard(context),
          const SizedBox(height: 16),
          _buildLinks(context),
        ],
      ),
    );
  }

  /// 顶部应用信息
  Widget _buildHeader(BuildContext context) {
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
          // 使用占位圆形图标代替图片，避免引入新资源；若后续提供网络Logo，请替换为 SvCacheImage
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.ondemand_video, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('app_name'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${context.tr('version')}: $appVersion',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 应用与作者信息
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(
            context,
            icon: Icons.person,
            title: 'Author',
            subtitle: 'Donkor',
          ),
          _divider(context),
          _buildInfoItem(
            context,
            icon: Icons.info_outline,
            title: context.tr('app_info'),
            subtitle: context.tr('mine'),
          ),
        ],
      ),
    );
  }

  /// 相关链接（反馈、隐私、条款、开源）
  Widget _buildLinks(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLinkItem(
            context,
            icon: Icons.feedback_outlined,
            title: context.tr('feedback'),
            subtitle: 'Email: example@domain.com',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('feature_wip'))));
            },
          ),
          _divider(context),
          _buildLinkItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: context.tr('privacy_policy'),
            subtitle: 'https://example.com/privacy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('feature_wip'))));
            },
          ),
          _divider(context),
          _buildLinkItem(
            context,
            icon: Icons.description_outlined,
            title: context.tr('terms_of_service'),
            subtitle: 'https://example.com/terms',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('feature_wip'))));
            },
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.only(left: 56),
        color: Theme.of(context).dividerColor,
      );

  Widget _buildInfoItem(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
}

