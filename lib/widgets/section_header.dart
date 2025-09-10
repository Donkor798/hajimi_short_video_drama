import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/localization.dart';

/// 区域标题组件
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onMoreTap;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool showMoreButton;
  final String? moreText;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onMoreTap,
    this.trailing,
    this.padding,
    this.showMoreButton = true,
    this.moreText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          // 标题区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          
          // 右侧内容
          if (trailing != null) ...[
            trailing!,
          ] else if (showMoreButton && onMoreTap != null) ...[
            GestureDetector(
              onTap: onMoreTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    moreText ?? context.tr('load_more'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 带图标的区域标题
class IconSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onMoreTap;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const IconSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onMoreTap,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          // 图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 标题区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          
          // 更多按钮
          if (onMoreTap != null) ...[
            GestureDetector(
              onTap: onMoreTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('load_more'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 可折叠的区域标题
class CollapsibleSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final EdgeInsetsGeometry? padding;

  const CollapsibleSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.isExpanded,
    this.onToggle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          children: [
            // 标题区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h6,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            // 展开/收起图标
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
