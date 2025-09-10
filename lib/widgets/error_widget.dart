import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/localization.dart';

/// 错误显示组件
class CustomErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const CustomErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            
            const SizedBox(height: 16),
            
            // 错误消息
            Text(
              message ?? context.tr('unknown_error'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 重试按钮
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  retryText ?? context.tr('retry'),
                  style: AppTextStyles.button,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: context.tr('network_error'),
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// 空数据组件
class EmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyWidget({
    super.key,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 空状态图标
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            
            const SizedBox(height: 16),
            
            // 空状态消息
            Text(
              message ?? context.tr('no_data'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 操作按钮
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 搜索空结果组件
class SearchEmptyWidget extends StatelessWidget {
  final String? keyword;
  final VoidCallback? onClearSearch;

  const SearchEmptyWidget({
    super.key,
    this.keyword,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      message: keyword != null
          ? '未找到"$keyword"相关的短剧'
          : context.tr('no_search_result'),
      icon: Icons.search_off,
      action: onClearSearch != null
          ? TextButton(
              onPressed: onClearSearch,
              child: Text(
                '清空搜索',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}

/// 收藏空状态组件
class FavoritesEmptyWidget extends StatelessWidget {
  final VoidCallback? onBrowse;

  const FavoritesEmptyWidget({
    super.key,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      message: '还没有收藏任何短剧\n快去发现喜欢的内容吧',
      icon: Icons.favorite_border,
      action: onBrowse != null
          ? ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '去浏览',
                style: AppTextStyles.button,
              ),
            )
          : null,
    );
  }
}

/// 历史记录空状态组件
class HistoryEmptyWidget extends StatelessWidget {
  final VoidCallback? onBrowse;

  const HistoryEmptyWidget({
    super.key,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      message: '暂无观看历史\n开始观看短剧吧',
      icon: Icons.history,
      action: onBrowse != null
          ? ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '去浏览',
                style: AppTextStyles.button,
              ),
            )
          : null,
    );
  }
}
