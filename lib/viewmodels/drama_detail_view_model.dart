import '../models/drama.dart';
import '../models/episode.dart';
import '../services/drama_api_service.dart';
import '../utils/storage_utils.dart';
import 'base_view_model.dart';

/// 短剧详情页面ViewModel
class DramaDetailViewModel extends BaseViewModel {
  final DramaApiService _apiService = DramaApiService();

  /// 短剧信息
  Drama? _drama;
  Drama? get drama => _drama;

  /// 剧集列表
  List<Episode> _episodes = [];
  List<Episode> get episodes => _episodes;

  /// 是否收藏
  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  /// 当前选中的剧集
  int _selectedEpisode = 1;
  int get selectedEpisode => _selectedEpisode;

  /// 是否正在加载剧集
  bool _isLoadingEpisodes = false;
  bool get isLoadingEpisodes => _isLoadingEpisodes;

  /// 播放历史
  Map<int, int> _playProgress = {}; // episodeNumber -> progress in seconds
  Map<int, int> get playProgress => _playProgress;

  /// 初始化
  Future<void> init(Drama drama) async {
    _drama = drama;
    _selectedEpisode = 1;
    
    await executeAsync(() async {
      await Future.wait([
        loadEpisodes(),
        loadFavoriteStatus(),
        loadPlayProgress(),
      ]);
    });
  }

  /// 加载剧集列表
  Future<void> loadEpisodes() async {
    if (_drama == null) return;

    _isLoadingEpisodes = true;
    notifyListeners();

    try {
      final response = await _apiService.getAllEpisodes(dramaId: _drama!.id);
      
      if (response.success && response.data != null) {
        _episodes = response.data!;
        
        // 如果没有剧集数据，创建默认剧集
        if (_episodes.isEmpty && _drama!.totalEpisodes != null) {
          _episodes = List.generate(
            _drama!.totalEpisodes!,
            (index) => Episode(
              dramaId: _drama!.id,
              episodeNumber: index + 1,
              title: '第${index + 1}集',
            ),
          );
        }
      } else {
        setError(response.message ?? '加载剧集失败');
      }
    } catch (e) {
      setError('加载剧集失败: $e');
    } finally {
      _isLoadingEpisodes = false;
      notifyListeners();
    }
  }

  /// 加载收藏状态
  Future<void> loadFavoriteStatus() async {
    if (_drama == null) return;

    try {
      final favorites = await StorageUtils.getFavorites();
      if (favorites != null) {
        _isFavorite = favorites.any((fav) => fav['id'] == _drama!.id);
        notifyListeners();
      }
    } catch (e) {
      // 忽略加载收藏状态的错误
    }
  }

  /// 加载播放进度
  Future<void> loadPlayProgress() async {
    if (_drama == null) return;

    try {
      final history = await StorageUtils.getPlayHistory();
      if (history != null) {
        for (final item in history) {
          if (item['drama_id'] == _drama!.id) {
            final episodeNumber = item['episode_number'] as int?;
            final progress = item['progress'] as int?;
            if (episodeNumber != null && progress != null) {
              _playProgress[episodeNumber] = progress;
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      // 忽略加载播放进度的错误
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    if (_drama == null) return;

    try {
      final favorites = await StorageUtils.getFavorites() ?? [];
      
      if (_isFavorite) {
        // 取消收藏
        favorites.removeWhere((fav) => fav['id'] == _drama!.id);
        _isFavorite = false;
      } else {
        // 添加收藏
        favorites.insert(0, _drama!.toJson());
        _isFavorite = true;
      }
      
      await StorageUtils.setFavorites(favorites);
      notifyListeners();
    } catch (e) {
      setError('操作失败: $e');
    }
  }

  /// 选择剧集
  void selectEpisode(int episodeNumber) {
    if (_selectedEpisode != episodeNumber) {
      _selectedEpisode = episodeNumber;
      notifyListeners();
    }
  }

  /// 播放剧集
  Future<Episode?> playEpisode(int episodeNumber) async {
    if (_drama == null) return null;

    selectEpisode(episodeNumber);

    try {
      final response = await _apiService.getSingleEpisode(
        dramaId: _drama!.id,
        episode: episodeNumber,
      );
      
      if (response.success && response.data != null) {
        final episode = response.data!;
        
        // 更新播放历史
        await updatePlayHistory(episodeNumber);
        
        return episode;
      } else {
        setError(response.message ?? '获取播放地址失败');
        return null;
      }
    } catch (e) {
      setError('获取播放地址失败: $e');
      return null;
    }
  }

  /// 更新播放历史
  Future<void> updatePlayHistory(int episodeNumber, [int progress = 0]) async {
    if (_drama == null) return;

    try {
      final history = await StorageUtils.getPlayHistory() ?? [];
      
      // 移除已存在的记录
      history.removeWhere((item) => 
          item['drama_id'] == _drama!.id && 
          item['episode_number'] == episodeNumber);
      
      // 添加新记录
      history.insert(0, {
        'drama_id': _drama!.id,
        'drama_name': _drama!.name,
        'drama_cover': _drama!.cover,
        'episode_number': episodeNumber,
        'progress': progress,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 限制历史记录数量
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }
      
      await StorageUtils.setPlayHistory(history);
      
      // 更新本地进度
      _playProgress[episodeNumber] = progress;
      notifyListeners();
    } catch (e) {
      // 忽略更新历史的错误
    }
  }

  /// 获取剧集播放进度
  int getEpisodeProgress(int episodeNumber) {
    return _playProgress[episodeNumber] ?? 0;
  }

  /// 获取剧集是否已观看
  bool isEpisodeWatched(int episodeNumber) {
    final episode = _episodes.firstWhere(
      (ep) => ep.episodeNumber == episodeNumber,
      orElse: () => Episode(
        dramaId: _drama?.id ?? 0,
        episodeNumber: episodeNumber,
        title: '',
      ),
    );
    
    return episode.isWatched || getEpisodeProgress(episodeNumber) > 0;
  }

  /// 获取下一集
  Episode? getNextEpisode() {
    if (_episodes.isEmpty) return null;
    
    final currentIndex = _episodes.indexWhere(
      (ep) => ep.episodeNumber == _selectedEpisode,
    );
    
    if (currentIndex >= 0 && currentIndex < _episodes.length - 1) {
      return _episodes[currentIndex + 1];
    }
    
    return null;
  }

  /// 获取上一集
  Episode? getPreviousEpisode() {
    if (_episodes.isEmpty) return null;
    
    final currentIndex = _episodes.indexWhere(
      (ep) => ep.episodeNumber == _selectedEpisode,
    );
    
    if (currentIndex > 0) {
      return _episodes[currentIndex - 1];
    }
    
    return null;
  }

  /// 重试加载
  @override
  Future<void> onRetry() async {
    if (_drama != null) {
      await init(_drama!);
    }
  }

  /// 刷新数据
  @override
  Future<void> onRefresh() async {
    if (_drama != null) {
      await init(_drama!);
    }
  }
}
