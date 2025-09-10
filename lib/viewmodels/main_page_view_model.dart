import 'package:flutter/foundation.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';

/// 主页面底部导航 ViewModel（Provider 管理）
/// - 持有 CircularBottomNavigationController
/// - 负责记录/更新当前选中索引
/// author: Donkor , 创建日期: 2025-09-10
class MainPageViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  final CircularBottomNavigationController navigationController =
      CircularBottomNavigationController(0);

  int get selectedIndex => _selectedIndex;

  /// 处理底部导航点击
  void onTabTap(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    navigationController.value = index;
    notifyListeners();
  }

  @override
  void dispose() {
    navigationController.dispose();
    super.dispose();
  }
}

