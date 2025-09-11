import '../database/database_helper.dart';
import '../models/drama.dart';
import '../services/drama_api_service.dart';
import '../constants/app_constants.dart';
import 'base_view_model.dart';

/// 收藏页 ViewModel（MVVM + Provider）
/// - 负责从本地 user_favorites 表读取收藏的剧目ID
/// - 分页拉取元信息（封面、名称）并组装为 Drama 列表
/// - 支持下拉刷新与上拉加载更多
/// - author : Donkor , 创建日期: 2025-09-11
class FavoritesViewModel extends BaseViewModel {
  final DatabaseHelper _db = DatabaseHelper();
  final DramaApiService _api = DramaApiService();

  // 展示用的剧目列表
  final List<Drama> _items = [];
  List<Drama> get items => List.unmodifiable(_items);

  // 收藏ID有序列表（created_at DESC）
  List<int> _favoriteIds = [];

  // 分页信息
  int _page = 1;
  static const int _pageSize = AppConstants.defaultPageSize; // 每页条数
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  //

///
  int _lastSyncVersion = 0; //
  int get lastSyncVersion => _lastSyncVersion;

  /// 初始化（进入页面时调用）
  Future<void> init() async {
    await refresh();
  }

  /// 下拉刷新
  @override
  Future<void> onRefresh() async => refresh();

  /// 处理来自详情页的收藏变更同步
  void maybeApplySync(int syncVersion) {
    if (syncVersion != _lastSyncVersion) {
      _lastSyncVersion = syncVersion;
      // 为确保数据与本地收藏表一致，直接执行一次刷新
      refresh();
    }
  }

  @override
  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _items.clear();
    notifyListeners();
    await _loadFavoritesMeta(reset: true);
  }

  /// 上拉加载更多
  Future<bool> loadMore() async {
    if (_isLoadingMore || !_hasMore) return false;
    _isLoadingMore = true;
    notifyListeners();
    final ok = await _loadFavoritesMeta(reset: false);
    _isLoadingMore = false;
    notifyListeners();
    return ok && _hasMore;
  }

  /// 从数据库读取收藏ID，并按分页请求元信息
  Future<bool> _loadFavoritesMeta({required bool reset}) async {
    try {
      if (reset) {
        // 只读取一次完整的收藏ID列表（本地，快速）
        final rows = await _db.getUserFavorites('local', 'drama');
        _favoriteIds = rows
            .map((e) => int.tryParse((e['target_id'] ?? '').toString()) ?? 0)
            .where((id) => id > 0)
            .toList();
      }
      if (_favoriteIds.isEmpty) {
        _hasMore = false;
        return true;
      }

      final start = (_page - 1) * _pageSize;
      if (start >= _favoriteIds.length) {
        _hasMore = false;
        return true;
      }
      final end = (start + _pageSize).clamp(0, _favoriteIds.length);
      final slice = _favoriteIds.sublist(start, end);

      // 先放入占位项，提升感知速度
      if (reset) {
        _items.clear();
      }
      for (final id in slice) {
        _items.add(Drama(id: id, name: '', cover: '', updateTime: '', score: 0));
      }
      notifyListeners();

      // 并发拉取 meta（description/cover/videoName/totalEpisodes）
      final metas = await Future.wait(slice.map((id) async {
        final resp = await _api.getAllEpisodesAndMeta(dramaId: id);
        return (id, resp);
      }));

      // 用元信息更新占位项
      for (final entry in metas) {
        final id = entry.$1;
        final resp = entry.$2;
        if (resp.success && resp.data != null) {
          final meta = resp.data!;
          final idx = _items.indexWhere((d) => d.id == id);
          if (idx >= 0) {
            _items[idx] = _items[idx].copyWith(
              name: meta.videoName ?? _items[idx].name,
              cover: meta.cover ?? _items[idx].cover,
              totalEpisodes: meta.totalEpisodes,
            );
          }
        }
      }

      _page += 1;
      // 是否还有更多：只要本页有元素就允许继续翻页
      _hasMore = end < _favoriteIds.length;
      return true;
    } catch (e) {
      setError('加载收藏失败: $e');
      if (reset) _items.clear();
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// 取消收藏并从列表移除
  Future<void> removeFavorite(int dramaId) async {
    try {
      await _db.deleteUserFavorite('local', dramaId.toString(), 'drama');
      _favoriteIds.removeWhere((id) => id == dramaId);
      _items.removeWhere((d) => d.id == dramaId);
      // 重新计算 hasMore（当移除到不足一页时，允许继续上拉以拉取下一批）
      _hasMore = _items.length < _favoriteIds.length;
      notifyListeners();
    } catch (e) {
      setError('取消收藏失败: $e');
    }
  }
}

