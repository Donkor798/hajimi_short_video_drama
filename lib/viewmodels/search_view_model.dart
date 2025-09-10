import '../models/drama.dart';
import '../services/drama_api_service.dart';
import '../utils/storage_utils.dart';
import 'base_view_model.dart';

/// 搜索页面ViewModel
class SearchViewModel extends BaseViewModel {
  final DramaApiService _apiService = DramaApiService();

  /// 搜索结果
  List<Drama> _searchResults = [];
  List<Drama> get searchResults => _searchResults;

  /// 搜索历史
  List<String> _searchHistory = [];
  List<String> get searchHistory => _searchHistory;

  /// 当前搜索关键词
  String _currentKeyword = '';
  String get currentKeyword => _currentKeyword;

  /// 是否显示搜索结果
  bool _showResults = false;
  bool get showResults => _showResults;

  /// 是否有搜索结果
  bool get hasResults => _searchResults.isNotEmpty;

  /// 是否有搜索历史
  bool get hasHistory => _searchHistory.isNotEmpty;

  /// 初始化
  Future<void> init() async {
    await loadSearchHistory();
  }

  /// 搜索短剧
  Future<void> searchDramas(String keyword) async {
    if (keyword.trim().isEmpty) {
      _showResults = false;
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _currentKeyword = keyword.trim();
    
    await executeAsync(() async {
      final response = await _apiService.searchDramas(name: _currentKeyword);
      
      if (response.success && response.data != null) {
        _searchResults = response.data!.dramas;
        _showResults = true;
        
        // 添加到搜索历史
        await addToSearchHistory(_currentKeyword);
      } else {
        setError(response.message ?? '搜索失败');
        _searchResults.clear();
        _showResults = true;
      }
    });
  }

  /// 清空搜索结果
  void clearSearchResults() {
    _searchResults.clear();
    _currentKeyword = '';
    _showResults = false;
    clearError();
    notifyListeners();
  }

  /// 加载搜索历史
  Future<void> loadSearchHistory() async {
    try {
      final history = await StorageUtils.getSearchHistory();
      _searchHistory = history ?? [];
      notifyListeners();
    } catch (e) {
      // 忽略加载历史的错误
    }
  }

  /// 添加到搜索历史
  Future<void> addToSearchHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;

    try {
      // 移除已存在的相同关键词
      _searchHistory.remove(keyword);
      
      // 添加到开头
      _searchHistory.insert(0, keyword);
      
      // 限制历史记录数量
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.take(20).toList();
      }
      
      // 保存到本地存储
      await StorageUtils.setSearchHistory(_searchHistory);
      notifyListeners();
    } catch (e) {
      // 忽略保存历史的错误
    }
  }

  /// 删除搜索历史项
  Future<void> removeFromSearchHistory(String keyword) async {
    try {
      _searchHistory.remove(keyword);
      await StorageUtils.setSearchHistory(_searchHistory);
      notifyListeners();
    } catch (e) {
      // 忽略删除历史的错误
    }
  }

  /// 清空搜索历史
  Future<void> clearSearchHistory() async {
    try {
      _searchHistory.clear();
      await StorageUtils.setSearchHistory(_searchHistory);
      notifyListeners();
    } catch (e) {
      // 忽略清空历史的错误
    }
  }

  /// 从历史记录搜索
  Future<void> searchFromHistory(String keyword) async {
    await searchDramas(keyword);
  }

  /// 获取热门搜索词（可以从推荐数据中获取）
  List<String> getHotSearchKeywords() {
    // 这里可以返回一些热门搜索词
    // 实际项目中可能需要从服务器获取
    return [
      '霸道总裁',
      '甜宠',
      '重生',
      '穿越',
      '复仇',
      '豪门',
      '校园',
      '古装',
    ];
  }

  /// 重试搜索
  @override
  Future<void> onRetry() async {
    if (_currentKeyword.isNotEmpty) {
      await searchDramas(_currentKeyword);
    }
  }

  /// 刷新搜索结果
  @override
  Future<void> onRefresh() async {
    if (_currentKeyword.isNotEmpty) {
      await searchDramas(_currentKeyword);
    }
  }
}
