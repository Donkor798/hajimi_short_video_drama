import 'package:flutter/material.dart';
import 'package:hajimi_short_video_drama/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../../../utils/localization.dart';
import '../../../utils/log_util.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../models/drama.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../../widgets/drama_card.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart' as custom_widgets;
import '../../../widgets/gradient_app_bar.dart';

/// 首页
/// Author: Donkor
/// Created: 2025-09-10
class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment>
    with AutomaticKeepAliveClientMixin {
  late HomeViewModel _viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    LogI('HomeFragment: initState');
    _viewModel = context.read<HomeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LogI('HomeFragment: 开始调用 viewModel.init()');
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      // 使用主题背景，避免硬编码白色，跟随深色模式/主题色
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          LogD('HomeFragment: build - isLoading:${viewModel.isLoading}, hasData:${viewModel.hasData}, hasError:${viewModel.hasError}');

          if (viewModel.isLoading && !viewModel.hasData) {
            LogI('HomeFragment: 显示加载中');
            return const LoadingWidget();
          }

          if (viewModel.hasError && !viewModel.hasData) {
            LogE('HomeFragment: 显示错误 - ${viewModel.errorMessage}');
            return custom_widgets.CustomErrorWidget(
              message: viewModel.errorMessage ?? context.tr('load_failed'),
              onRetry: () => viewModel.retry(),
            );
          }

          // 首页分类：支持下拉刷新 + 上拉加载更多（分类结果分页）
          return EasyRefresh(
            header: const ClassicHeader(showText: false),
            footer: const ClassicFooter(showText: false), //
            onRefresh: () async {
              await viewModel.refresh();
            },
            onLoad: viewModel.hasMoreCategory
                ? () async {
                    await viewModel.loadMoreCategory();
                  }
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
    return GradientAppBar(
      titleText: context.tr('app_name'),
      actions: [
        IconButton(
          tooltip: context.tr('hot'),
          icon: const Icon(Icons.local_fire_department),
          onPressed: _onHotTap,
        ),
        IconButton(
          tooltip: context.tr('recommend'),
          icon: const Icon(Icons.thumb_up_alt_outlined),
          onPressed: _onRecommendTap,
        ),
        IconButton(
          tooltip: context.tr('latest'),
          icon: const Icon(Icons.update),
          onPressed: _onLatestTap,
        ),
        IconButton(
          tooltip: context.tr('search'),
          icon: const Icon(Icons.search),
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

  /// 仅展示分类的内容区域
  /// author : Donkor , 创建日期: 2025-09-10
  Widget _buildOnlyCategoryContent(HomeViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 如果有分类，显示分类选择器
          if (viewModel.categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCategorySection(viewModel),
            const SizedBox(height: 12),
            _buildCategoryResultsSection(viewModel),
          ] else ...[
            // 如果没有分类，显示推荐/最新/热门的混合内容
            _buildNoCategoryContent(viewModel),
          ],
        ],
      ),
    );
  }

  /// 构建分类区域（禁止横向列表向上层冒泡，避免 EasyRefresh 误触发导致指示器溢出）
  Widget _buildCategorySection(HomeViewModel viewModel) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 拦截横向列表的滚动通知，防止 EasyRefresh 接管并在受限宽度中绘制指示器
        return notification.metrics.axis == Axis.horizontal;
      },
      child: SizedBox(
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
      ),
    );
  }

  /// 构建没有分类时的内容（显示推荐/最新/热门的混合列表）
  /// author : Donkor , 创建日期: 2026-03-02
  Widget _buildNoCategoryContent(HomeViewModel viewModel) {
    // 合并所有数据：推荐 + 最新 + 热门
    final allDramas = <Drama>[
      ...viewModel.recommendDramas,
      ...viewModel.latestDramas,
      ...viewModel.hotDramas,
    ];

    // 去重（根据ID）
    final uniqueDramas = <int, Drama>{};
    for (var drama in allDramas) {
      uniqueDramas[drama.id] = drama;
    }
    final items = uniqueDramas.values.toList();

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text(context.tr('no_data'))),
      );
    }

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
          onTap: () => NavigatorUtils.push(
              context, '${MainRouter.detailPage}/${drama.id}',
              arguments: drama),
        );
      },
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
          onTap: () => NavigatorUtils.push(
              context, '${MainRouter.detailPage}/${drama.id}',
              arguments: drama),
        );
      },
    );
  }
}
