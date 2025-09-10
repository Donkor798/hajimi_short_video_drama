import '../models/drama.dart';
import '../services/drama_api_service.dart';
import 'base_view_model.dart';

/// 热门页 ViewModel（分页）
/// author : Donkor , 创建日期: 2025-09-10
class HotViewModel extends BaseViewModel {
  final DramaApiService _api = DramaApiService();

  final List<Drama> _items = [];
  List<Drama> get items => List.unmodifiable(_items);

  int _page = 1;
  int _totalPages = 1;
  int? _categoryId; // 作为“热门”的分类id

  bool get hasMore => _page < _totalPages;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> init({int? categoryId}) async {
    _categoryId = categoryId;
    await refresh();
  }

  @override
  Future<void> onRefresh() async => refresh();

  @override
  Future<void> refresh() async {
    _page = 1;
    _totalPages = 1;
    _items.clear();
    notifyListeners();

    // 选择一个分类作为“热门”的数据来源
    if (_categoryId == null) {
      final cats = await _api.getCategories();
      if (cats.success && cats.data != null && cats.data!.isNotEmpty) {
        _categoryId = cats.data!.first.typeId;
      } else {
        setError(cats.message ?? '获取分类失败');
        notifyListeners();
        return;
      }
    }

    await _load(page: 1, loadMore: false);
  }

  Future<bool> loadMore() async {
    if (_isLoadingMore || !hasMore) return false;
    _isLoadingMore = true;
    notifyListeners();
    final next = _page + 1;
    final ok = await _load(page: next, loadMore: true);
    _isLoadingMore = false;
    notifyListeners();
    return ok && hasMore;
  }

  Future<bool> _load({required int page, required bool loadMore}) async {
    try {
      final resp = await _api.getCategoryDramas(categoryId: _categoryId!, page: page);
      if (resp.success && resp.data != null) {
        final data = resp.data!;
        if (loadMore) {
          _items.addAll(data.dramas);
        } else {
          _items
            ..clear()
            ..addAll(data.dramas);
        }
        _page = data.currentPage;
        _totalPages = data.totalPages;
        return true;
      } else {
        setError(resp.message ?? '加载热门失败');
        if (!loadMore) _items.clear();
        return false;
      }
    } catch (e) {
      setError('加载热门失败: $e');
      if (!loadMore) _items.clear();
      return false;
    } finally {
      notifyListeners();
    }
  }
}

