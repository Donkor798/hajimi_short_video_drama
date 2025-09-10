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
              onRefresh: () async => vm.refresh(),
              onLoad: vm.hasMore ? () async { await vm.loadMore(); } : null,
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
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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

