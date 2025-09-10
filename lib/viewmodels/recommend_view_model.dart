import '../models/drama.dart';
import '../services/drama_api_service.dart';
import 'base_view_model.dart';

/// 推荐页 ViewModel（分页，支持下拉刷新与上拉加载）
/// author : Donkor , 创建日期: 2025-09-10
class RecommendViewModel extends BaseViewModel {
  final DramaApiService _api = DramaApiService();

  final List<Drama> _items = [];
  List<Drama> get items => List.unmodifiable(_items);

  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  static const int _pageSize = 20; // 每页条数

  Future<void> init() async {
    await refresh();
  }

  @override
  Future<void> onRefresh() async => refresh();

  @override
  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _items.clear();
    notifyListeners();
    await _load(page: 1, loadMore: false);
  }

  Future<bool> loadMore() async {
    if (_isLoadingMore || !_hasMore) return false;
    _isLoadingMore = true;
    notifyListeners();
    final next = _page + 1;
    final ok = await _load(page: next, loadMore: true);
    _isLoadingMore = false;
    notifyListeners();
    return ok && _hasMore;
  }

  Future<bool> _load({required int page, required bool loadMore}) async {
    try {
      final resp = await _api.getRecommendDramas(page: page, size: _pageSize);
      if (resp.success && resp.data != null) {
        final list = resp.data!;
        if (loadMore) {
          _items.addAll(list);
        } else {
          _items
            ..clear()
            ..addAll(list);
        }
        _page = page;
        // 根据返回数量判断是否还有更多
        _hasMore = list.length >= _pageSize;
        return true;
      } else {
        setError(resp.message ?? '加载推荐失败');
        if (!loadMore) _items.clear();
        return false;
      }
    } catch (e) {
      setError('加载推荐失败: $e');
      if (!loadMore) _items.clear();
      return false;
    } finally {
      notifyListeners();
    }
  }
}

