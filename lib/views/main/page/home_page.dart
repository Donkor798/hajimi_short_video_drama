import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../../widgets/drama_card.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart' as custom_widgets;
import '../../../models/drama.dart';

/// 首页
/// Author: Donkor
/// Created: 2025-09-10
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late HomeViewModel _viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && !viewModel.hasData) {
            return const LoadingWidget();
          }

          if (viewModel.hasError && !viewModel.hasData) {
            return custom_widgets.CustomErrorWidget(
              message: viewModel.errorMessage ?? context.tr('load_failed'),
              onRetry: () => viewModel.retry(),
            );
          }

          // 首页分类：支持下拉刷新 + 上拉加载更多（分类结果分页）
          return EasyRefresh(
            footer: const ClassicFooter(), //
            onRefresh: () async { await viewModel.refresh(); },
            onLoad: viewModel.hasMoreCategory
                ? () async { await viewModel.loadMoreCategory(); }
                : null,
            child: _buildOnlyCategoryContent(viewModel),
          );
        },
      ),
    );
  }

  /// 构建应用栏（圆角+渐变，带热门/推荐/最新/搜索图标）
  /// author : Donkor , 创建日期: 2025-09-10
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF5A8DEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      title: Text(
        context.tr('app_name'),
        style: AppTextStyles.h5.copyWith(color: AppColors.textLight),
      ),
      actions: [
        // 热门
        IconButton(
          tooltip: context.tr('hot'),
          icon: const Icon(Icons.local_fire_department, color: AppColors.textLight),
          onPressed: _onHotTap,
        ),
        // 推荐
        IconButton(
          tooltip: context.tr('recommend'),
          icon: const Icon(Icons.thumb_up_alt_outlined, color: AppColors.textLight),
          onPressed: _onRecommendTap,
        ),
        // 最新
        IconButton(
          tooltip: context.tr('latest'),
          icon: const Icon(Icons.update, color: AppColors.textLight),
          onPressed: _onLatestTap,
        ),
        // 搜索
        IconButton(
          tooltip: context.tr('search'),
          icon: const Icon(Icons.search, color: AppColors.textLight),
          onPressed: () => NavigatorUtils.push(context, MainRouter.searchPage),
        ),
      ],
    );
  }

  void _onHotTap() {
    NavigatorUtils.push(context, MainRouter.hotPage);
  }

  void _onRecommendTap() {
    NavigatorUtils.push(context, MainRouter.recommendPage);
  }

  void _onLatestTap() {
    NavigatorUtils.push(context, MainRouter.latestPage);
  }


  /// 构建内容
  Widget _buildContent(HomeViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 热门短剧（置顶展示）
          if (viewModel.hotDramas.isNotEmpty || viewModel.isLoadingHot) ...[
            SectionHeader(
              title: context.tr('hot'),
              onMoreTap: () {
                // 跳转到热门页面
              },
            ),
            const SizedBox(height: 12),
            _buildHotSection(viewModel),
            const SizedBox(height: 24),
          ],

          // 全部分类（热门列表下面）
          if (viewModel.categories.isNotEmpty) ...[
            SectionHeader(
              title: context.tr('all_categories'),
              onMoreTap: () {
                // 跳转到分类页面
              },
            ),
            const SizedBox(height: 12),
            _buildCategorySection(viewModel),
            // 分类结果区域（点击某一分类后显示）
            if (viewModel.selectedCategoryId != null) ...[
              const SizedBox(height: 12),
              _buildCategoryResultsSection(viewModel),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 24),
          ],

          // 推荐短剧
          if (viewModel.recommendDramas.isNotEmpty || viewModel.isLoadingRecommend) ...[
            SectionHeader(
              title: context.tr('recommend'),
              onMoreTap: () {
                // 跳转到推荐页面
              },
            ),
            const SizedBox(height: 12),
            _buildRecommendSection(viewModel),
            const SizedBox(height: 24),
          ],

          // 最新短剧
          if (viewModel.latestDramas.isNotEmpty || viewModel.isLoadingLatest) ...[
            SectionHeader(
              title: context.tr('latest'),
              onMoreTap: () {
                // 跳转到最新页面
              },
            ),
            const SizedBox(height: 12),

            _buildLatestSection(viewModel),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
  /// 仅展示分类的内容区域
  /// author : Donkor , 创建日期: 2025-09-10
  Widget _buildOnlyCategoryContent(HomeViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.categories.isNotEmpty) ...[
            SectionHeader(
              title: context.tr('all_categories'),
              onMoreTap: () {},
            ),
            const SizedBox(height: 12),
            _buildCategorySection(viewModel),
            const SizedBox(height: 12),
            _buildCategoryResultsSection(viewModel),
          ],
        ],
      ),
    );
  }


  /// 构建分类区域（移除左滑刷新功能）
  Widget _buildCategorySection(HomeViewModel viewModel) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(), // 移除弹性滚动效果，避免左滑刷新
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              label: category.typeName,
              isSelected: viewModel.selectedCategoryId == category.typeId,
              onTap: () => viewModel.selectCategory(category.typeId),
            ),
          );
        },
      ),
    );
  }

  /// 构建推荐区域
  Widget _buildRecommendSection(HomeViewModel viewModel) {
    if (viewModel.isLoadingRecommend) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.recommendDramas.length,
        itemBuilder: (context, index) {
          final drama = viewModel.recommendDramas[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < viewModel.recommendDramas.length - 1 ? 12 : 0,
            ),
            child: SizedBox(
              width: 160,
              child: DramaCard(
                drama: drama,
                onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}'),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建最新区域
  /// 构建分类结果区域（网格，不横向滑动，移除加载更多功能）
  Widget _buildCategoryResultsSection(HomeViewModel viewModel) {
    // 首次加载或切换分类时显示整体loading
    if (viewModel.isLoadingCategory && viewModel.categoryDramas.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.categoryDramas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text(context.tr('no_data'))),
      );
    }

    final items = viewModel.categoryDramas;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final drama = items[index];
        return DramaCard(
          drama: drama,
          onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}'),
        );
      },
    );
  }

  Widget _buildLatestSection(HomeViewModel viewModel) {
    if (viewModel.isLoadingLatest) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.latestDramas.length,
        itemBuilder: (context, index) {
          final drama = viewModel.latestDramas[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < viewModel.latestDramas.length - 1 ? 12 : 0,
            ),
            child: SizedBox(
              width: 160,
              child: DramaCard(
                drama: drama,
                onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}'),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建热门区域
  Widget _buildHotSection(HomeViewModel viewModel) {
    if (viewModel.isLoadingHot) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.hotDramas.length,
        itemBuilder: (context, index) {
          final drama = viewModel.hotDramas[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < viewModel.hotDramas.length - 1 ? 12 : 0,
            ),
            child: SizedBox(
              width: 160,
              child: DramaCard(
                drama: drama,
                onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
