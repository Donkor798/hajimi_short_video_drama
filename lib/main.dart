import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'services/http_service.dart';
import 'utils/localization.dart';
import 'router/routers.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/search_view_model.dart';
import 'viewmodels/drama_detail_view_model.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'viewmodels/main_page_view_model.dart';
import 'commom/my_color.dart';
import 'commom/my_language.dart';
import 'commom/my_theme.dart';
import 'viewmodels/favorites_sync.dart';

import 'views/main/fragment/home_fragment.dart';
import 'views/main/fragment/favorites_fragment.dart';
import 'views/main/fragment/my_fragment.dart';


/// 哈吉米短剧应用
/// Author: Donkor
/// Created: 2024-12-19
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务
  await _initializeServices();

  // 初始化 Fluro 路由
  Routes.initRoutes();

  runApp(const HajimiApp());
}

/// 初始化服务
Future<void> _initializeServices() async {
  // 初始化HTTP服务
  HttpService().init();
}

class HajimiApp extends StatelessWidget {
  const HajimiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainPageViewModel()), // 底部导航状态
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => DramaDetailViewModel()),
        ChangeNotifierProvider(create: (_) => MyColor()), // 主题颜色管理
        ChangeNotifierProvider(create: (_) => MyLanguage()), // 语言管理
        ChangeNotifierProvider(create: (_) => MyTheme()), // 主题管理（深色模式、字体大小）
        ChangeNotifierProvider(create: (_) => FavoritesSync()), // 收藏变更同步器
      ],
      child: Consumer3<MyColor, MyLanguage, MyTheme>(
        builder: (context, myColor, myLanguage, myTheme, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // 国际化配置
            locale: myLanguage.locale,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,

            // 动态主题配置
            theme: myTheme.getThemeData(myColor.colorPrimary),

            // 首页
            home: const MainPage(),

            // 使用 Fluro 生成器
            onGenerateRoute: Routes.router.generator,
          );
        },
      ),
    );
  }


}

/// 主页面容器
/// 使用 circular_bottom_navigation 作为底部导航栏，移除“搜索”Tab
/// author: Donkor , 创建日期: 2025-09-10
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainPageViewModel>();
    final pages = const [
      HomeFragment(),
      FavoritesFragment(),
      MyFragment(),
    ];

    return Scaffold(
      // 让底部导航栏悬浮于内容之上（实现透明效果时避免出现色带）
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: vm.selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _CircularBottomNav(viewModel: vm),
    );
  }
}

/// 使用 circular_bottom_navigation 作为底部导航栏
/// author: Donkor , 创建日期: 2025-09-10
class _CircularBottomNav extends StatelessWidget {
  final MainPageViewModel viewModel;
  const _CircularBottomNav({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // 构建 TabItems，处理中英双语
    final tabItems = <TabItem>[
      TabItem(Icons.home, context.tr('home'), Theme.of(context).colorScheme.primary, labelStyle: const TextStyle(fontSize: 12)),
      TabItem(Icons.favorite, context.tr('favorites'), Theme.of(context).colorScheme.primary, labelStyle: const TextStyle(fontSize: 12)),
      TabItem(Icons.person, context.tr('mine'), Theme.of(context).colorScheme.primary, labelStyle: const TextStyle(fontSize: 12)),
    ];

    const double bottomNavBarHeight = 60.0; // 底部栏高度
    // 导航栏背景改为透明，移除黑色阴影
    const Color background = Colors.white;

    return CircularBottomNavigation(
      tabItems,
      controller: viewModel.navigationController,
      selectedPos: viewModel.selectedIndex,
      barHeight: bottomNavBarHeight,
      barBackgroundColor: background,
      backgroundBoxShadow: const <BoxShadow>[],
      animationDuration: const Duration(milliseconds: 300),
      selectedCallback: (int? selectedPos) {
        viewModel.onTabTap(selectedPos ?? 0);
      },
    );
  }
}

