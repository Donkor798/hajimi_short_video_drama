import '../models/category.dart';
import '../models/drama.dart';
import '../services/drama_api_service.dart';
import 'base_view_model.dart';

/// 首页ViewModel
class HomeViewModel extends BaseViewModel {
  final DramaApiService _apiService = DramaApiService();

  /// 分类列表
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  /// 推荐短剧列表
  List<Drama> _recommendDramas = [];
  List<Drama> get recommendDramas => _recommendDramas;

  /// 最新短剧列表
  List<Drama> _latestDramas = [];
  List<Drama> get latestDramas => _latestDramas;

  /// 热门短剧列表
  List<Drama> _hotDramas = [];
  List<Drama> get hotDramas => _hotDramas;

  /// 分类下的短剧结果（点击分类后显示）
  List<Drama> _categoryDramas = [];
  List<Drama> get categoryDramas => _categoryDramas;

  /// 分类分页信息
  int _categoryPage = 1;
  int _categoryTotalPages = 1;
  int get categoryPage => _categoryPage;
  int get categoryTotalPages => _categoryTotalPages;

  /// 当前选中的分类ID
  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  /// 是否正在加载推荐
  bool _isLoadingRecommend = false;
  bool get isLoadingRecommend => _isLoadingRecommend;

  /// 是否正在加载最新
  bool _isLoadingLatest = false;
  bool get isLoadingLatest => _isLoadingLatest;
  /// 是否正在加载分类结果（首屏/切换分类）
  bool _isLoadingCategory = false;
  bool get isLoadingCategory => _isLoadingCategory;
  /// 是否正在上拉加载更多（分类列表）
  bool _isLoadingCategoryMore = false;
  bool get isLoadingCategoryMore => _isLoadingCategoryMore;


  /// 是否正在加载热门
  bool _isLoadingHot = false;
  bool get isLoadingHot => _isLoadingHot;

  /// 初始化数据
  /// 进入首页即加载：分类/推荐/最新/热门，并默认选中第一个分类加载其数据
  Future<void> init() async {
    await executeAsync(() async {
      await Future.wait([
        loadCategories(),
        loadRecommendDramas(),
        loadLatestDramas(),
        loadHotDramas(),
      ]);
      // 默认选中第一个分类并加载
      if (_selectedCategoryId == null && _categories.isNotEmpty) {
        selectCategory(_categories.first.typeId);
      }
    });
  }

  /// 加载分类列表
  Future<void> loadCategories() async {
    final response = await _apiService.getCategories();
    if (response.success && response.data != null) {
      _categories = response.data!;
      notifyListeners();
    } else {
      setError(response.message ?? '加载分类失败');
    }
  }

  /// 加载推荐短剧
  Future<void> loadRecommendDramas({int? categoryId}) async {
    _isLoadingRecommend = true;
    notifyListeners();

    try {
      final response = await _apiService.getRecommendDramas(
        categoryId: categoryId,
        size: 20,
      );

      if (response.success && response.data != null) {
        _recommendDramas = response.data!;
      } else {
        setError(response.message ?? '加载推荐失败');
      }
    } catch (e) {
      setError('加载推荐失败: $e');
    } finally {
      _isLoadingRecommend = false;
      notifyListeners();
    }
  }

  /// 加载最新短剧
  Future<void> loadLatestDramas() async {
    _isLoadingLatest = true;
    notifyListeners();

    try {
      final response = await _apiService.getLatestDramas(page: 1);

      if (response.success && response.data != null) {
        _latestDramas = response.data!;
      } else {
        setError(response.message ?? '加载最新失败');
      }
    } catch (e) {
      setError('加载最新失败: $e');
    } finally {
      _isLoadingLatest = false;
      notifyListeners();
    }
  }

  /// 加载热门短剧（使用分类列表的第一个分类）
  Future<void> loadHotDramas() async {
    _isLoadingHot = true;
    notifyListeners();
    try {
      // 使用第一个分类作为热门分类
      final categoryId = _categories.isNotEmpty ? _categories.first.typeId : 1;
      final response = await _apiService.getCategoryDramas(
        categoryId: categoryId,
        page: 1,
      );
      if (response.success && response.data != null) {
        _hotDramas = response.data!.dramas;
      } else {
        setError(response.message ?? '加载热门失败');
      }
    } catch (e) {
      setError('加载热门失败: $e');
    } finally {
      _isLoadingHot = false;
      notifyListeners();
    }
  }

  /// 根据选中分类加载列表（支持分页）
  Future<void> loadCategoryDramas({
    required int categoryId,
    int page = 1,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      // 上拉加载更多：仅标记“加载更多”状态，避免首屏loading影响整体刷新
      _isLoadingCategoryMore = true;
      notifyListeners();
    } else {
      _isLoadingCategory = true;
      notifyListeners();
    }
    try {
      final response = await _apiService.getCategoryDramas(
        categoryId: categoryId,
        page: page,
      );
      if (response.success && response.data != null) {
        final data = response.data!;
        _categoryPage = data.currentPage;
        _categoryTotalPages = data.totalPages;
        if (loadMore) {
          _categoryDramas = [..._categoryDramas, ...data.dramas];
        } else {
          _categoryDramas = data.dramas;
        }
      } else {
        if (!loadMore) {
          _categoryDramas = [];
        }
        setError(response.message ?? '加载分类数据失败');
      }
    } catch (e) {
      if (!loadMore) {
        _categoryDramas = [];
      }
      setError('加载分类数据失败: $e');
    } finally {
      if (loadMore) {
        _isLoadingCategoryMore = false;
      } else {
        _isLoadingCategory = false;
      }
      notifyListeners();
    }
  }

  /// 上拉加载更多（分类）
  Future<bool> loadMoreCategory() async {
    if (_selectedCategoryId == null) return false;
    if (_categoryPage >= _categoryTotalPages) {
      return false; // 没有更多了
    }
    final next = _categoryPage + 1;
    await loadCategoryDramas(categoryId: _selectedCategoryId!, page: next, loadMore: true);
    return _categoryPage < _categoryTotalPages;
  }

  /// 选择分类
  void selectCategory(int? categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      // 重置分页
      _categoryPage = 1;
      _categoryTotalPages = 1;
      notifyListeners();

      // 选中具体分类：加载分类列表 + 过滤推荐
      if (categoryId != null) {
        loadCategoryDramas(categoryId: categoryId, page: 1, loadMore: false);
        loadRecommendDramas(categoryId: categoryId);
      } else {
        // 无“全部分类”标签时，此分支基本不触达；保留以便外部调用清空筛选
        _categoryDramas = [];
        notifyListeners();
        loadRecommendDramas(categoryId: null);
      }
    }
  }

  /// 刷新所有数据
  @override
  Future<void> onRefresh() async {
    await init();
  }

  /// 重试加载
  @override
  Future<void> onRetry() async {
    await init();
  }

  /// 获取分类名称
  String getCategoryName(int categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.typeId == categoryId,
      orElse: () => Category(typeId: categoryId, typeName: '未知分类'),
    );
    return category.typeName;
  }

  /// 是否有数据
  bool get hasData {
    return _categories.isNotEmpty ||
           _recommendDramas.isNotEmpty ||
           _latestDramas.isNotEmpty ||
           _hotDramas.isNotEmpty;
  }

  /// 是否正在加载任何数据
  bool get isLoadingAny {
    return isLoading || _isLoadingRecommend || _isLoadingLatest || _isLoadingHot;
  }
}
