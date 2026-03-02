import '../models/category.dart';
import '../models/drama.dart';
import '../services/drama_api_service.dart';
import '../utils/log_util.dart';
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
  /// 进入首页即加载：分类/推荐/最新/热门
  /// 如果有分类，则加载第一个分类的数据；如果没有分类，则不加载分类数据
  Future<void> init() async {
    LogI('HomeViewModel: 开始初始化');
    await executeAsync(() async {
      try {
        LogI('HomeViewModel: 先加载分类，确保短剧分类ID可用');
        await loadCategories();

        // 如果有分类，则默认选中第一个分类并加载其数据
        // 如果没有分类，则不加载分类数据，直接显示推荐/最新/热门
        if (_categories.isNotEmpty) {
          final containsSelected = _selectedCategoryId != null &&
              _categories.any((c) => c.typeId == _selectedCategoryId);
          if (!containsSelected) {
            _selectedCategoryId = _categories.first.typeId;
          }
          LogI('HomeViewModel: 加载分类短剧 - categoryId:$_selectedCategoryId');
          await loadCategoryDramas(
            categoryId: _selectedCategoryId!,
            page: 1,
            loadMore: false,
          );
          LogI('HomeViewModel: 初始化完成 - 分类短剧数:${_categoryDramas.length}');
        } else {
          LogI('HomeViewModel: 没有分类数据，跳过分类短剧加载');
          _selectedCategoryId = null;
          _categoryDramas = [];
          notifyListeners();
        }

        LogI('HomeViewModel: 并行加载推荐/最新/热门');
        await Future.wait([
          loadRecommendDramas(categoryId: _selectedCategoryId),
          loadLatestDramas(),
          loadHotDramas(),
        ]);
        LogI(
            'HomeViewModel: 列表加载完成 - 推荐数:${_recommendDramas.length}, 最新数:${_latestDramas.length}, 热门数:${_hotDramas.length}');
      } catch (e) {
        LogE('HomeViewModel: 初始化失败 - $e');
        rethrow;
      }
    });
  }

  /// 加载分类列表
  Future<void> loadCategories() async {
    try {
      LogI('HomeViewModel: 开始加载分类列表');
      final response = await _apiService.getCategories();
      if (response.success && response.data != null) {
        _categories = response.data!;
        LogI('HomeViewModel: 分类列表加载成功 - 数量:${_categories.length}');
        notifyListeners();
      } else {
        LogE('HomeViewModel: 分类列表加载失败 - ${response.message}');
        setError(response.message ?? '加载分类失败');
      }
    } catch (e) {
      LogE('HomeViewModel: 分类列表加载异常 - $e');
      setError('加载分类失败: $e');
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
      // 仅使用短剧分类作为热门来源；无短剧分类时保持空列表
      if (_categories.isEmpty) {
        _hotDramas = [];
        return;
      }
      final categoryId = _categories.first.typeId;
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
    LogI(
        'HomeViewModel: 开始加载分类短剧 - categoryId:$categoryId, page:$page, loadMore:$loadMore');
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
      LogI(
          'HomeViewModel: 分类短剧API响应 - success:${response.success}, hasData:${response.data != null}');
      if (response.success && response.data != null) {
        final data = response.data!;
        _categoryPage = data.currentPage;
        _categoryTotalPages = data.totalPages;
        LogI(
            'HomeViewModel: 分类短剧数据 - dramas:${data.dramas.length}, currentPage:${data.currentPage}, totalPages:${data.totalPages}');
        if (loadMore) {
          _categoryDramas = [..._categoryDramas, ...data.dramas];
        } else {
          _categoryDramas = data.dramas;
        }
        LogI('HomeViewModel: 分类短剧加载成功 - 当前总数:${_categoryDramas.length}');
      } else {
        LogE('HomeViewModel: 分类短剧加载失败 - ${response.message}');
        if (!loadMore) {
          _categoryDramas = [];
        }
        setError(response.message ?? '加载分类数据失败');
      }
    } catch (e) {
      LogE('HomeViewModel: 分类短剧加载异常 - $e');
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
    await loadCategoryDramas(
        categoryId: _selectedCategoryId!, page: next, loadMore: true);
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

  /// 是否还有更多分类数据可加载
  bool get hasMoreCategory =>
      _selectedCategoryId != null && _categoryPage < _categoryTotalPages;

  /// 是否正在加载任何数据
  bool get isLoadingAny {
    return isLoading ||
        _isLoadingRecommend ||
        _isLoadingLatest ||
        _isLoadingHot;
  }
}
