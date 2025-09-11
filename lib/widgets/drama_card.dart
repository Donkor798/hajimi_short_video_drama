import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import '../models/drama.dart';
import 'sv_cache_image.dart';

/// 短剧卡片组件（支持：封面、名称、时间；可选收藏角标）
/// author : Donkor , 创建日期: 2025-09-10
class DramaCard extends StatelessWidget {
  final Drama drama;
  final VoidCallback? onTap;
  final bool showScore;
  final bool showUpdateTime;
  // 保持封面尺寸一致的宽高比（宽/高），默认 3:4
  final double imageAspectRatio;

  /// 是否显示收藏角标（右上角小心形）
  final bool showFavoriteBadge;

  /// 当前是否为已收藏状态（控制图标样式）
  final bool isFavorite;

  /// 点击角标的回调（如：取消收藏）
  final VoidCallback? onFavoriteTap;

  const DramaCard({
    super.key,
    required this.drama,
    this.onTap,
    this.showScore = true,
    this.showUpdateTime = false,
    this.imageAspectRatio = 3 / 4,
    this.showFavoriteBadge = false,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片 + 可选收藏角标
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: SvCacheImage(
                        imageUrl: drama.cover,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (showFavoriteBadge) Positioned(
                      right: 8,
                      top: 8,
                      child: Material(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: onFavoriteTap,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFavorite ? Colors.redAccent : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 信息区域（仅名称；推荐/最新默认不显示时间）
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    drama.name,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1, // 名称过长省略处理
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  if (showUpdateTime) ...[
                    const SizedBox(height: 6),
                    Text(
                      (drama.releaseDate != null && drama.releaseDate!.isNotEmpty)
                          ? drama.releaseDate!
                          : drama.updateTime,
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 横向短剧卡片
class HorizontalDramaCard extends StatelessWidget {
  final Drama drama;
  final VoidCallback? onTap;

  const HorizontalDramaCard({
    super.key,
    required this.drama,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 封面图片
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SvCacheImage.cover(
                imageUrl: drama.cover,
                width: 90,
                height: double.infinity,
              ),
            ),
            
            // 信息区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      drama.name,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1, // 避免卡片在固定高度下溢出
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 描述
                    if (drama.hasDescription) ...[
                      Text(
                        drama.description!,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    const Spacer(),
                    
                    // 底部信息
                    Row(
                      children: [
                        // 评分
                        if (drama.score > 0) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            drama.formattedScore,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.amber[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        
                        // 更新时间
                        Text(
                          drama.updateTime,
                          style: AppTextStyles.labelSmall,
                        ),
                        
                        const Spacer(),
                        
                        // 播放按钮
                        Icon(
                          Icons.play_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
