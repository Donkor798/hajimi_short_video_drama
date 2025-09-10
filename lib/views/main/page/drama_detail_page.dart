import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/drama.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../viewmodels/drama_detail_view_model.dart';
import '../../../widgets/sv_cache_image.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart' as custom_widgets;

/// 短剧详情页面
/// Author: Donkor
/// Created: 2024-12-19
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<DramaDetailViewModel>();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.drama);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                _buildTabContent(viewModel),
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
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
        onPressed: () => NavigatorUtils.goBack(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            viewModel.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: viewModel.isFavorite ? Colors.red : AppColors.textLight,
          ),
          onPressed: () => viewModel.toggleFavorite(),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textLight),
          onPressed: () => _shareDrama(drama),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            SvCacheImage.cover(
              imageUrl: drama.cover,
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
                    color: AppColors.primary.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.textLight,
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
                    drama.name,
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
            _buildInfoRow('更新时间', drama.updateTime),
            if (drama.hasGenre) _buildInfoRow('类型', drama.genre!),
            if (drama.hasDirector) _buildInfoRow('导演', drama.director!),
            if (drama.hasCast) _buildInfoRow('演员', drama.cast!),
            if (drama.totalEpisodes != null)
              _buildInfoRow('集数', '共${drama.totalEpisodes}集'),
            
            const SizedBox(height: 16),
            
            // 描述
            if (drama.hasDescription) ...[
              Text(
                '剧情简介',
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: 8),
              Text(
                drama.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
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
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
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

  /// 构建标签栏
  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: context.tr('episode_list')),
            const Tab(text: '相关推荐'),
          ],
        ),
      ),
    );
  }

  /// 构建标签页内容
  Widget _buildTabContent(DramaDetailViewModel viewModel) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildEpisodeList(viewModel),
          _buildRecommendations(),
        ],
      ),
    );
  }

  /// 构建剧集列表
  Widget _buildEpisodeList(DramaDetailViewModel viewModel) {
    if (viewModel.isLoadingEpisodes) {
      return const LoadingWidget();
    }

    if (viewModel.episodes.isEmpty) {
      return const Center(
        child: Text('暂无剧集信息'),
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
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '第${episode.episodeNumber}集',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.textLight : AppColors.textPrimary,
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
    return const Center(
      child: Text('相关推荐 - 开发中'),
    );
  }

  /// 播放短剧
  void _playDrama(DramaDetailViewModel viewModel) {
    _playEpisode(viewModel, 1);
  }

  /// 播放剧集
  void _playEpisode(DramaDetailViewModel viewModel, int episodeNumber) {
    final drama = viewModel.drama ?? widget.drama;
    // 使用 fluro 跳转到播放器页，携带 Drama 对象作为 arguments
    NavigatorUtils.push(
      context,
      '${MainRouter.playerPage}/${drama.id}/$episodeNumber',
      arguments: drama,
    );
  }

  /// 分享短剧
  void _shareDrama(Drama drama) {
    // 实现分享功能（暂时用SnackBar提示）
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }
}
