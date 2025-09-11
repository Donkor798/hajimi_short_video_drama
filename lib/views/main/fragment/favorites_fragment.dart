import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../../../constants/app_colors.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/drama_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart' as custom_widgets;
import '../../../viewmodels/favorites_view_model.dart';
import '../../../viewmodels/favorites_sync.dart';
import '../../../models/drama.dart';

/// 收藏页（支持下拉刷新 + 上拉加载更多）
/// author : Donkor , 创建日期: 2025-09-11
class FavoritesFragment extends StatelessWidget {
  const FavoritesFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesViewModel()..init(),
      child: Scaffold(
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: AppColors.background,
        appBar: GradientAppBar(
          titleText: context.tr('favorites'),
          showBack: false,
        ),
        body: Consumer2<FavoritesViewModel, FavoritesSync>(
          builder: (context, vm, sync, child) {
            // 监听来自详情页的收藏变更：仅当同步版本号变化时，触发一次刷新
            WidgetsBinding.instance.addPostFrameCallback((_) {
              vm.maybeApplySync(sync.version);
            });

            if (vm.isLoading && vm.items.isEmpty) {
              return const LoadingWidget();
            }

            if (vm.hasError && vm.items.isEmpty) {
              return custom_widgets.CustomErrorWidget(
                message: vm.errorMessage ?? context.tr('load_failed'),
                onRetry: () => vm.retry(),
              );
            }

            return EasyRefresh(
              header: const ClassicHeader(),
              footer: const ClassicFooter(),
              onRefresh: () async => vm.refresh(),
              // 始终提供 onLoad，由 VM 内部控制 hasMore 与节流
              onLoad: () async { await vm.loadMore(); },
              child: _buildGrid(
                context,
                vm.items,
                onBrowse: () => NavigatorUtils.push(context, MainRouter.recommendPage),
                onFavoriteTap: (d) => _confirmRemove(context, vm, d),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建网格列表
  /// author : Donkor , 创建日期: 2025-09-11
  Widget _buildGrid(
    BuildContext context,
    List<Drama> items, {
    required VoidCallback onBrowse,
    required void Function(Drama) onFavoriteTap,
  }) {
    if (items.isEmpty) {
      return custom_widgets.FavoritesEmptyWidget(onBrowse: onBrowse);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
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
          onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}', arguments: drama),
          showFavoriteBadge: true,
          isFavorite: true,
          onFavoriteTap: () => onFavoriteTap(drama),
        );
      },
    );
  }

  /// 确认移除收藏
  /// author : Donkor , 创建日期: 2025-09-11
  Future<void> _confirmRemove(BuildContext context, FavoritesViewModel vm, Drama drama) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('confirm')),
          content: Text(context.tr('confirm_remove_favorite')),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBackWithParams(context, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => NavigatorUtils.goBackWithParams(context, true),
              child: Text(context.tr('ok')),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await vm.removeFavorite(drama.id);
      // 可选：SnackBar 提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('removed'))),
        );
      }
    }
  }
}
