import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/drama.dart';
import '../models/episode.dart';

import '../services/drama_api_service.dart';

/// 播放页 ViewModel（Provider / MVVM）
/// 说明：负责抖音式上下滑分页播放，使用 parsedUrl 的网络地址进行播放
/// author : Donkor , 创建的日期(2025-09-11)
class PlayerViewModel extends ChangeNotifier {
  final Drama drama; // 当前剧信息，用于总集数等
  final int initialEpisodeNumber; // 初始集数（1开始）
  final String? initialVideoUrl; // 初始集的parsedUrl（可选）

  // PageView / 播放控制
  late final PageController pageController;
  int currentIndex = 0; // 当前播放索引（从0开始）
  final Map<int, VideoPlayerController> controllers = {}; // 控制器缓存，key 为索引
  final Set<int> _initializing = {}; // 避免重复初始化

  // URL 缓存：key 为“集数”（从1开始），value 为 parsedUrl
  final Map<int, String> _urlCache = {};

  // API 服务
  final DramaApiService _api = DramaApiService();

  // UI 交互状态（会话级）
  final Set<int> liked = {}; // 点赞索引集合（会话内）
  final Set<int> favorited = {}; // 收藏索引集合（会话内）
  bool overlayVisible = true; // 叠加UI可见性（单击切换）

  bool hasError = false;
  String? errorMessage;

  PlayerViewModel({
    required this.drama,
    required this.initialEpisodeNumber,
    this.initialVideoUrl,
  });

  // 初始化（在页面创建时调用）
  void init() {
    hasError = false; errorMessage = null;
    // 将初始集转为索引
    currentIndex = (initialEpisodeNumber - 1).clamp(0, 1 << 30);
    pageController = PageController(initialPage: currentIndex);

    // 若外部已传入初始集 parsedUrl，则先缓存，能显著缩短首屏等待
    if (initialVideoUrl != null && initialVideoUrl!.isNotEmpty) {
      _urlCache[initialEpisodeNumber] = initialVideoUrl!;
    }
    // 预拉取相邻集的 URL（批量）
    _prefetchBatchAround(currentIndex);

    _ensureAndPlay(currentIndex);
    _prefetchNeighbors(currentIndex);
  }

  // 计算总集数
  int get itemCount {
    final t = drama.totalEpisodes;
    if (t != null && t > 0) return t;
    return 50; // 未知时给一个较大上限，便于滚动体验
  }

  bool _hasPreviousIndex(int index) => index >= 0;
  bool _hasNextIndex(int index) => index < itemCount;

  // 根据索引获取“集数”（1开始）
  // 批量获取 parsedUrl 并写入缓存；仅请求缓存缺失的集
  Future<void> _batchFetchUrls(List<int> episodeNumbers) async {
    final valid = episodeNumbers
        .where((e) => e >= 1 && e <= itemCount)
        .where((e) => (_urlCache[e]?.isNotEmpty != true))
        .toSet()
        .toList();
    if (valid.isEmpty) return;
    try {
      final resp = await _api.getBatchEpisodes(
        dramaId: drama.id,
        episodes: valid,
      );
      if (resp.success && resp.data != null) {
        for (final ep in resp.data!) {
          final url = ep.playUrl ?? '';
          if (url.isNotEmpty) {
            _urlCache[ep.episodeNumber] = url;
          }
        }
        // 批量完毕后刷新（便于可能等待中的 UI 读取到缓存）
        notifyListeners();
      }
    } catch (_) {
      // 批量失败不影响单集兜底
    }
  }

  // 以索引为中心预取相邻集的 URL（不阻塞播放）
  void _prefetchBatchAround(int index) {
    final centerEp = _episodeNumberOf(index);
    final list = <int>{centerEp - 1, centerEp, centerEp + 1, centerEp + 2}.toList();
    _batchFetchUrls(list);
  }

  int _episodeNumberOf(int index) => index + 1;

  // 获取（或拉取）指定集数的 parsedUrl
  Future<String?> _getOrFetchUrl(int episodeNumber) async {
    // 命中缓存
    final cached = _urlCache[episodeNumber];
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final resp = await _api.getSingleEpisode(
        dramaId: drama.id,
        episode: episodeNumber,
      );
      if (resp.success && resp.data != null) {
        final url = resp.data!.playUrl ?? '';
        if (url.isNotEmpty) {
          _urlCache[episodeNumber] = url;
          return url;
        }
        // 返回成功但无地址：直接返回 null，调用方负责跳过
        return null;
      } else {
        // 请求失败：直接返回 null，调用方负责跳过
        return null;
      }
    } catch (_) {
      // 网络/解析异常：直接返回 null，调用方负责跳过
      return null;
    }
  }

  //
  //   URL 
  Future<int?> _findNextPlayableIndex(int fromIndex) async {
    for (int i = fromIndex + 1; i < itemCount; i++) {
      final ep = _episodeNumberOf(i);
      final url = await _getOrFetchUrl(ep);
      if (url != null && url.isNotEmpty) return i;
    }
    return null;
  }

  //  
  Future<void> _jumpToIndex(int newIndex) async {
    currentIndex = newIndex;
    if (pageController.hasClients) {
      try {
        pageController.jumpToPage(newIndex);
      } catch (_) {}
    }
    await _ensureAndPlay(newIndex);
  }

  Future<void> _ensureController(int index) async {
    if (controllers.containsKey(index) || _initializing.contains(index)) return;
    _initializing.add(index);

    try {
      final ep = _episodeNumberOf(index);
      final url = await _getOrFetchUrl(ep);
      if (url == null || url.isEmpty) {
        // 无可用地址：直接返回，由上层决定是否跳过
        return;
      }

      // 使用网络地址（parsedUrl）初始化播放器
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await ctrl.initialize();
      await ctrl.setLooping(true);
      controllers[index] = ctrl;
      notifyListeners();
    } catch (_) {
      // 初始化失败：保持静默，由上层决定是否跳过
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
    } else {
      // 当前索引不可播：寻找下一个可播并跳转
      final next = await _findNextPlayableIndex(index);
      if (next != null) {
        await _jumpToIndex(next);
      } else {
        // 向后也找不到：可选再向前找；这里提示一次错误
        hasError = true;
        errorMessage = '暂无可播放剧集';
        notifyListeners();
      }
    }
  }

  void _prefetchNeighbors(int index) {
    //     
    _prefetchBatchAround(index);
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
    // 切页时先批量预取相邻 URL
    _prefetchBatchAround(index);
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

