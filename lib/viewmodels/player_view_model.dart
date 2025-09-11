import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/drama.dart';

/// 播放页 ViewModel（Provider / MVVM）
/// 说明：负责抖音式上下滑分页播放的业务状态与控制
/// author : Donkor , 创建的日期(2025-09-11)
class PlayerViewModel extends ChangeNotifier {
  final Drama drama; // 当前剧集信息，用于总集数等
  final int initialEpisodeNumber; // 初始集数（1开始）

  // PageView / 播放控制
  late final PageController pageController;
  int currentIndex = 0; // 当前播放的索引（从0开始）
  final Map<int, VideoPlayerController> controllers = {}; // 控制器缓存
  final Set<int> _initializing = {}; // 避免重复初始化

  // UI 交互状态（会话级）
  final Set<int> liked = {}; // 点赞的索引集合（会话内）
  final Set<int> favorited = {}; // 收藏的索引集合（会话内）
  bool overlayVisible = true; // 叠加UI可见性（单击切换）

  bool hasError = false;
  String? errorMessage;

  PlayerViewModel({required this.drama, required this.initialEpisodeNumber});

  // 初始化（在页面创建时调用）
  void init() {
    currentIndex = (initialEpisodeNumber - 1).clamp(0, 1 << 30);
    pageController = PageController(initialPage: currentIndex);
    _ensureAndPlay(currentIndex);
    _prefetchNeighbors(currentIndex);
  }

  // 计算总集数：未知则给较大上限，便于测试滚动
  int get itemCount {
    final t = drama.totalEpisodes;
    if (t != null && t > 0) return t;
    return 50;
  }

  // 本地测试视频路径：index 映射到 1..5.mp4
  String _buildAssetPath(int index) {
    final assetIndex = (index % 5) + 1;
    return 'assets/video/$assetIndex.mp4';
  }

  bool _hasPreviousIndex(int index) => index >= 0;
  bool _hasNextIndex(int index) => index < itemCount;

  Future<void> _ensureController(int index) async {
    if (controllers.containsKey(index) || _initializing.contains(index)) return;
    _initializing.add(index);
    final ctrl = VideoPlayerController.asset(_buildAssetPath(index));
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      controllers[index] = ctrl;
      notifyListeners();
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      _initializing.remove(index);
    }
  }

  Future<void> _ensureAndPlay(int index) async {
    await _ensureController(index);
    // 暂停其他
    controllers.forEach((k, c) {
      if (k != index && c.value.isInitialized && c.value.isPlaying) {
        c.pause();
      }
    });
    final current = controllers[index];
    if (current != null && current.value.isInitialized) {
      await current.play();
      notifyListeners();
    }
  }

  void _prefetchNeighbors(int index) {
    final prev = index - 1;
    final next = index + 1;
    if (_hasPreviousIndex(prev)) {
      _ensureController(prev);
    }
    if (_hasNextIndex(next)) {
      _ensureController(next);
    }
  }

  void onPageChanged(int index) {
    currentIndex = index;
    _ensureAndPlay(index);
    _prefetchNeighbors(index);
  }

  // 点赞/收藏状态切换（会话内状态，后续可接入真正的后端/数据库）
  void toggleLike(int index) {
    if (liked.contains(index)) {
      liked.remove(index);
    } else {
      liked.add(index);
    }
    notifyListeners();
  }

  void toggleFavorite(int index) {
    if (favorited.contains(index)) {
      favorited.remove(index);
    } else {
      favorited.add(index);
    }
    notifyListeners();
  }

  // 叠加UI显隐切换（单击屏幕）
  void toggleOverlayVisible() {
    overlayVisible = !overlayVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    controllers.clear();
    pageController.dispose();
    super.dispose();
  }
}

