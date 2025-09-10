import 'package:flutter/foundation.dart';

/// 底部导航 ViewModel（使用 Provider 管理状态）
/// 负责记录与切换当前选中的底部导航索引
/// author: Donkor, created: 2025-09-10
class MainViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// 切换当前索引（避免重复通知）
  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}

