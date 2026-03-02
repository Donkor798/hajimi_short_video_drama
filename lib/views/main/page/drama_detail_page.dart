import 'package:flutter/material.dart';
import 'package:hajimi_short_video_drama/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_text_styles.dart';
import '../../../models/drama.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../viewmodels/drama_detail_view_model.dart';
import '../../../viewmodels/favorites_sync.dart';
import '../../../widgets/sv_cache_image.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart' as custom_widgets;

/// 短剧详情页面
/// Author: Donkor
/// Created: 2025-09-10
class DramaDetailPage extends StatefulWidget {
  final Drama drama;

  const DramaDetailPage({
    super.key,
    required this.drama,
  });

  @override
  State<DramaDetailPage> createState() => _DramaDetailPageState();
}

class _DramaDetailPageState extends State<DramaDetailPage>
    with SingleTickerProviderStateMixin {
  late DramaDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<DramaDetailViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.drama);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DramaDetailViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              // 应用栏
              _buildSliverAppBar(viewModel),

              // 内容
              if (viewModel.isLoading && viewModel.drama == null) ...[
                const SliverFillRemaining(
                  child: LoadingWidget(),
                ),
              ] else if (viewModel.hasError && viewModel.drama == null) ...[
                SliverFillRemaining(
                  child: custom_widgets.CustomErrorWidget(
                    message: viewModel.errorMessage,
                    onRetry: () => viewModel.retry(),
                  ),
                ),
              ] else ...[
                // 短剧信息
                _buildDramaInfo(viewModel),

                // 标签页
                _buildTabBar(),

                // 标签页内容
                _buildEpisodesSliver(viewModel),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 构建可折叠应用栏
  Widget _buildSliverAppBar(DramaDetailViewModel viewModel) {
    final drama = viewModel.drama ?? widget.drama;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white),
        onPressed: () => NavigatorUtils.goBack(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            viewModel.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: viewModel.isFavorite ? Colors.red : (Theme.of(context).appBarTheme.foregroundColor ?? Colors.white),
          ),
          onPressed: () async {
            await viewModel.toggleFavorite();
            if (!mounted) return;
            final dramaId = (viewModel.drama ?? widget.drama).id;
            context.read<FavoritesSync>().notifyChanged(
              dramaId: dramaId,
              isFavorite: viewModel.isFavorite,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.share, color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white),
          onPressed: () => _shareDrama(drama),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            SvCacheImage.cover(
              imageUrl: (context.read<DramaDetailViewModel>().parseCover ?? drama.cover),
              width: double.infinity,
              height: double.infinity,
            ),

            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // 播放按钮
            Center(
              child: GestureDetector(
                onTap: () => _playDrama(viewModel),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建短剧信息
  Widget _buildDramaInfo(DramaDetailViewModel viewModel) {
    final drama = viewModel.drama ?? widget.drama;

    final total = viewModel.parseTotalEpisodes ?? drama.totalEpisodes;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和评分
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    (context.read<DramaDetailViewModel>().parseVideoName ?? drama.name),
                    style: AppTextStyles.h4,
                  ),
                ),
                if (drama.score > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          drama.formattedScore,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // 基本信息
            _buildInfoRow(context.tr('update_time'), drama.updateTime),
            if ((drama.releaseDate ?? '').isNotEmpty)
              _buildInfoRow(context.tr('release_date'), drama.releaseDate!),
            if (drama.hasGenre) _buildInfoRow(context.tr('genre'), drama.genre!),
            if (drama.hasDirector) _buildInfoRow(context.tr('director'), drama.director!),
            if (drama.hasCast) _buildInfoRow(context.tr('cast'), drama.cast!),

            if (total != null)
              _buildInfoRow(context.tr('episodes_count'), context.tr('total_episodes', params: {'total': total.toString()})),

            const SizedBox(height: 16),

            // 描述（优先使用 parseAll 的 description）
            if (((viewModel.parseDescription ?? drama.description) ?? '').isNotEmpty) ...[
              Text(
                context.tr('description'),
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: 8),
              Text(
                (viewModel.parseDescription ?? drama.description)!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建“选集”标题栏（替代 TabBar，避免嵌套滚动冲突）
  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          context.tr('episode_select'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  /// 构建“选集”内容为 Sliver，避免内外两层可滚导致的滑动冲突
  Widget _buildEpisodesSliver(DramaDetailViewModel viewModel) {
    if (viewModel.isLoadingEpisodes) {
      return const SliverToBoxAdapter(child: LoadingWidget());
    }
    if (viewModel.episodes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text(context.tr('no_episode_info'))),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final episode = viewModel.episodes[index];
            final isSelected = episode.episodeNumber == viewModel.selectedEpisode;
            final isWatched = viewModel.isEpisodeWatched(episode.episodeNumber);

            return GestureDetector(
              onTap: () => _playEpisode(viewModel, episode.episodeNumber),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        context.tr('episode', params: {'number': episode.episodeNumber.toString()}),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    if (isWatched)
                      const Positioned(
                        top: 2,
                        right: 2,
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          childCount: viewModel.episodes.length,
        ),
      ),
    );
  }

  /// 构建剧集列表
  Widget _buildEpisodeList(DramaDetailViewModel viewModel) {
    if (viewModel.isLoadingEpisodes) {
      return const LoadingWidget();
    }

    if (viewModel.episodes.isEmpty) {
      return Center(
        child: Text(context.tr('no_episode_info')),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: viewModel.episodes.length,
      itemBuilder: (context, index) {
        final episode = viewModel.episodes[index];
        final isSelected = episode.episodeNumber == viewModel.selectedEpisode;
        final isWatched = viewModel.isEpisodeWatched(episode.episodeNumber);

        return GestureDetector(
          onTap: () => _playEpisode(viewModel, episode.episodeNumber),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    context.tr('episode', params: {'number': episode.episodeNumber.toString()}),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isWatched)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建推荐内容
  Widget _buildRecommendations() {
    return Center(
      child: Text('${context.tr('related_recommendations')} - ${context.tr('loading')}'),
    );
  }

  /// 播放短剧
  // 仅播放有URL的剧集：默认播放第一个可播放的剧集
  void _playDrama(DramaDetailViewModel viewModel) {
    final firstPlayable = viewModel.episodes.isNotEmpty ? viewModel.episodes.first.episodeNumber : 1;
    _playEpisode(viewModel, firstPlayable);
  }

  /// 播放剧集
  void _playEpisode(DramaDetailViewModel viewModel, int episodeNumber) {
    final drama = viewModel.drama ?? widget.drama;
    String? url;
    for (final e in viewModel.episodes) {
      if (e.episodeNumber == episodeNumber) { url = e.playUrl; break; }
    }

    NavigatorUtils.push(
      context,
      '${MainRouter.playerPage}/${drama.id}/$episodeNumber',
      arguments: {
        'drama': drama,
        'videoUrl': url,
      },
    );
  }

  /// 分享短剧
  void _shareDrama(Drama drama) {
    // TODO(share): implement share
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('share_feature_wip'))),
    );
  }
}
