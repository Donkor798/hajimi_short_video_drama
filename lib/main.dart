import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'services/http_service.dart';
import 'utils/localization.dart';
import 'router/routers.dart';
import 'utils/storage_utils.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/search_view_model.dart';
import 'viewmodels/drama_detail_view_model.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'viewmodels/main_page_view_model.dart';

import 'views/main/page/home_page.dart';

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
  // 初始化存储
  await StorageUtils.init();

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
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // 国际化配置
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,

        // 主题配置
        theme: _buildTheme(),

        // 首页
        home: const MainPage(),

        // 使用 Fluro 生成器
        onGenerateRoute: Routes.router.generator,
      ),
    );
  }

  /// 构建主题
  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      useMaterial3: true,
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
      HomePage(),
      FavoritesPage(),
      SettingsPage(),
    ];

    return Scaffold(
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
      TabItem(Icons.home, context.tr('home'), AppColors.primary, labelStyle: const TextStyle(fontSize: 12)),
      TabItem(Icons.favorite, context.tr('favorites'), AppColors.primary, labelStyle: const TextStyle(fontSize: 12)),
      TabItem(Icons.settings, context.tr('settings'), AppColors.primary, labelStyle: const TextStyle(fontSize: 12)),
    ];

    const double bottomNavBarHeight = 60.0; // 底部栏高度
    final Color background = AppColors.surface; // 背景色

    return CircularBottomNavigation(
      tabItems,
      controller: viewModel.navigationController,
      selectedPos: viewModel.selectedIndex,
      barHeight: bottomNavBarHeight,
      barBackgroundColor: background,
      backgroundBoxShadow: const <BoxShadow>[
        BoxShadow(color: Colors.black45, blurRadius: 10.0),
      ],
      animationDuration: const Duration(milliseconds: 300),
      selectedCallback: (int? selectedPos) {
        viewModel.onTabTap(selectedPos ?? 0);
      },
    );
  }
}

/// 临时收藏页面
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('favorites')),
      ),
      body: const Center(
        child: Text('收藏页面 - 开发中'),
      ),
    );
  }
}

/// 临时设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
      ),
      body: const Center(
        child: Text('设置页面 - 开发中'),
      ),
    );
  }
}
