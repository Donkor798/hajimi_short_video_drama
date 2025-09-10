import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../viewmodels/recommend_view_model.dart';
import '../../../widgets/drama_card.dart';

/// 推荐页面 - 展示推荐短剧列表，支持下拉刷新
/// author : Donkor , 创建日期: 2025-09-10
class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  late final RecommendViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RecommendViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.init());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<RecommendViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(context.tr('recommend')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => NavigatorUtils.goBack(context),
              ),
            ),
            body: EasyRefresh(
              header: const ClassicHeader(), // 下拉刷新的头部提示
              footer: const ClassicFooter(), // 上拉加载的底部提示
              onRefresh: () async => vm.refresh(),
              onLoad: () async { await vm.loadMore(); }, // 始终允许触发，VM 内部基于 hasMore 决定是否继续
              child: vm.isLoading && vm.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : (vm.items.isEmpty && vm.hasError)
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(vm.errorMessage ?? context.tr('load_failed')),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => vm.refresh(),
                                child: Text(context.tr('retry')),
                              )
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(), // 物理滚动：保留回弹效果，避免 AlwaysScrollable 影响上拉触发
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: vm.items.length,
                          itemBuilder: (context, index) {
                            final drama = vm.items[index];
                            return DramaCard(
                              drama: drama,
                              showUpdateTime: false,
                              onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}'),
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
}

