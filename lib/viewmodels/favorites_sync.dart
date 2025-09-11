import 'package:flutter/material.dart';

/// 收藏变更同步器（全局，基于 Provider）
/// 用途：当详情页切换收藏状态时，通知收藏Fragment刷新数据
/// author : Donkor , 创建日期: 2025-09-11
class FavoritesSync extends ChangeNotifier {
  int _version = 0; // 变化版本号（每次变更+1）
  int get version => _version;

  int? lastDramaId; // 最近变更的剧目ID
  bool? lastIsFavorite; // 最近是否为收藏

  /// 触发一次收藏变更
  void notifyChanged({required int dramaId, required bool isFavorite}) {
    lastDramaId = dramaId;
    lastIsFavorite = isFavorite;
    _version += 1;
    notifyListeners();
  }
}

