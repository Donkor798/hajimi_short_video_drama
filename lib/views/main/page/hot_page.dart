import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';
import '../../../viewmodels/hot_view_model.dart';
import '../../../widgets/drama_card.dart';

/// 热门页面 - 默认取第一个分类作为“热门”，分页加载
/// author : Donkor , 创建日期: 2025-09-10
class HotPage extends StatefulWidget {
  const HotPage({super.key});

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  late final HotViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = HotViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.init());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<HotViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(context.tr('hot')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => NavigatorUtils.goBack(context),
              ),
            ),
            body: EasyRefresh(
              onRefresh: () async => vm.refresh(),
              onLoad: vm.hasMore ? () async { await vm.loadMore(); } : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: vm.isLoading && vm.items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
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
            ),
          );
        },
      ),
    );
  }
}

