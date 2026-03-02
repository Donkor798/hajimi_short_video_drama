import '../constants/app_constants.dart';
import '../models/category.dart';
import '../models/drama.dart';
import '../models/episode.dart';
import 'http_service.dart';

/// 短剧API服务类
class DramaApiService {
  static final DramaApiService _instance = DramaApiService._internal();
  factory DramaApiService() => _instance;
  DramaApiService._internal();

  final HttpService _httpService = HttpService();

  /// 获取分类列表
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await _httpService.get(ApiEndpoints.categories);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final categoriesData = data['categories'] as List<dynamic>;

        final categories = categoriesData
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(categories);
      } else {
        return ApiResponse.error(response.message ?? '获取分类失败');
      }
    } catch (e) {
      return ApiResponse.error('获取分类失败: $e');
    }
  }

  /// 获取推荐短剧
  Future<ApiResponse<List<Drama>>> getRecommendDramas({
    int? categoryId,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId.toString();
      }

      final response = await _httpService.get(
        ApiEndpoints.recommend,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final raw = response.data;
        if (_isApiErrorPayload(raw)) {
          return ApiResponse.error(_extractApiErrorMessage(raw, '获取推荐失败'));
        }
        final dramas = _extractDramaList(raw)
            .map((json) => Drama.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(dramas);
      } else {
        return ApiResponse.error(response.message ?? '获取推荐失败');
      }
    } catch (e) {
      return ApiResponse.error('获取推荐失败: $e');
    }
  }

  /// 获取分类短剧列表
  Future<ApiResponse<DramaListResponse>> getCategoryDramas({
    required int categoryId,
    int page = 1,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.list,
        queryParameters: {
          'categoryId': categoryId.toString(),
          'page': page.toString(),
        },
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final dramasData = data['list'] as List<dynamic>? ?? [];

        final dramas = dramasData
            .map((json) => Drama.fromJson(json as Map<String, dynamic>))
            .toList();

        final listResponse = DramaListResponse(
          dramas: dramas,
          total: data['total'] as int? ?? 0,
          totalPages: data['totalPages'] as int? ?? 0,
          currentPage: data['currentPage'] as int? ?? 1,
        );

        return ApiResponse.success(listResponse);
      } else {
        return ApiResponse.error(response.message ?? '获取列表失败');
      }
    } catch (e) {
      return ApiResponse.error('获取列表失败: $e');
    }
  }

  /// 搜索短剧
  Future<ApiResponse<DramaListResponse>> searchDramas({
    required String name,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.search,
        queryParameters: {
          'name': name,
        },
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final dramasData = data['list'] as List<dynamic>? ?? [];

        final dramas = dramasData
            .map((json) => Drama.fromJson(json as Map<String, dynamic>))
            .toList();

        final listResponse = DramaListResponse(
          dramas: dramas,
          total: data['total'] as int? ?? 0,
          totalPages: data['totalPages'] as int? ?? 0,
          currentPage: data['currentPage'] as int? ?? 1,
        );

        return ApiResponse.success(listResponse);
      } else {
        return ApiResponse.error(response.message ?? '搜索失败');
      }
    } catch (e) {
      return ApiResponse.error('搜索失败: $e');
    }
  }

  /// 获取最新短剧
  Future<ApiResponse<List<Drama>>> getLatestDramas({
    int page = 1,
    int size = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.latest,
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      if (!response.success || response.data == null) {
        return _fallbackLatestByRecommend(size: size);
      }

      final raw = response.data;
      final dramas = _extractDramaList(raw)
          .map((json) => Drama.fromJson(json as Map<String, dynamic>))
          .toList();

      // 文档存在 /vod/latest，但线上可能返回业务 404；此时降级到推荐。
      if (_isApiErrorPayload(raw) || dramas.isEmpty) {
        return _fallbackLatestByRecommend(size: size);
      }

      return ApiResponse.success(dramas);
    } catch (e) {
      return _fallbackLatestByRecommend(size: size);
    }
  }

  /// 获取单集播放地址
  Future<ApiResponse<Episode>> getSingleEpisode({
    required int dramaId,
    int episode = 1,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.parseSingle,
        queryParameters: {
          'id': dramaId.toString(),
          'episode': episode.toString(),
        },
      );

      if (response.success && response.data != null) {
        final raw = response.data;
        // 兼容多种返回结构：可能是 {data: {...}} / {result: {...}} / 直接就是对象
        final map = _unwrapToEpisodeMap(raw) ??
            (raw is Map<String, dynamic> ? raw : <String, dynamic>{});
        if (_hasEpisodeUrl(map)) {
          final episodeData = Episode.fromJson(map);
          return ApiResponse.success(episodeData);
        }
        if (_isApiErrorPayload(raw)) {
          return ApiResponse.error(_extractApiErrorMessage(raw, '获取播放地址失败'));
        }
        // single 不可用时，降级到 all 结果里找目标集。
        final allResp = await getAllEpisodesAndMeta(dramaId: dramaId);
        if (allResp.success && allResp.data != null) {
          final episodes = allResp.data!.episodes;
          if (episodes.isNotEmpty) {
            final target = episodes.firstWhere(
              (e) => e.episodeNumber == episode,
              orElse: () => episodes.first,
            );
            if ((target.playUrl ?? '').isNotEmpty) {
              return ApiResponse.success(target);
            }
          }
        }
        final episodeData = Episode.fromJson(map);
        return ApiResponse.success(episodeData);
      } else {
        return ApiResponse.error(response.message ?? '获取播放地址失败');
      }
    } catch (e) {
      return ApiResponse.error('获取播放地址失败: $e');
    }
  }

  Future<ApiResponse<List<Drama>>> _fallbackLatestByRecommend({
    required int size,
  }) async {
    try {
      final fallbackResp = await _httpService.get(
        ApiEndpoints.recommend,
        queryParameters: {'size': size.toString()},
      );
      if (!fallbackResp.success || fallbackResp.data == null) {
        return ApiResponse.error(fallbackResp.message ?? '获取最新失败');
      }
      final raw = fallbackResp.data;
      if (_isApiErrorPayload(raw)) {
        return ApiResponse.error(_extractApiErrorMessage(raw, '获取最新失败'));
      }
      final dramas = _extractDramaList(raw)
          .map((json) => Drama.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(dramas);
    } catch (e) {
      return ApiResponse.error('获取最新失败: $e');
    }
  }

  List<dynamic> _extractDramaList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final direct = (raw['list'] as List?) ??
          (raw['data'] as List?) ??
          (raw['items'] as List?) ??
          (raw['records'] as List?) ??
          (raw['rows'] as List?);
      if (direct != null) return direct;

      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return (data['list'] as List?) ??
            (data['items'] as List?) ??
            (data['rows'] as List?) ??
            const [];
      }
    }
    return const [];
  }

  bool _isApiErrorPayload(dynamic raw) {
    if (raw is! Map<String, dynamic>) return false;
    if (!raw.containsKey('code')) return false;
    final code = raw['code'];
    final codeNum = int.tryParse(code?.toString() ?? '');
    if (codeNum == null) return false;
    return codeNum != 0 && codeNum != 200;
  }

  String _extractApiErrorMessage(dynamic raw, String fallback) {
    if (raw is Map<String, dynamic>) {
      final msg = raw['msg']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
      final message = raw['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }

  bool _hasEpisodeUrl(Map<String, dynamic> m) {
    const keys = ['play_url', 'playUrl', 'parsedUrl', 'url', 'link'];
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// 批量获取剧集地址
  Future<ApiResponse<List<Episode>>> getBatchEpisodes({
    required int dramaId,
    required List<int> episodes,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.parseBatch,
        queryParameters: {
          'id': dramaId.toString(),
          'episodes': episodes.join(','),
        },
      );

      if (response.success && response.data != null) {
        final raw = response.data;
        final episodesData = _unwrapToEpisodeList(raw);
        final list = episodesData
            .whereType<Map<String, dynamic>>()
            .map((json) => Episode.fromJson(json))
            .toList();

        return ApiResponse.success(list);
      } else {
        return ApiResponse.error(response.message ?? '获取剧集地址失败');
      }
    } catch (e) {
      return ApiResponse.error('获取剧集地址失败: $e');
    }
  }

  /// 获取全集地址
  Future<ApiResponse<List<Episode>>> getAllEpisodes({
    required int dramaId,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.parseAll,
        queryParameters: {
          'id': dramaId.toString(),
        },
      );

      if (response.success && response.data != null) {
        final raw = response.data;
        List<dynamic> episodesData = const [];
        if (raw is List) {
          episodesData = raw;
        } else if (raw is Map<String, dynamic>) {
          episodesData = (raw['episodes'] as List?) ??
              (raw['results'] as List?) ??
              (raw['list'] as List?) ??
              (raw['data'] as List?) ??
              (raw['items'] as List?) ??
              (raw['records'] as List?) ??
              (raw['rows'] as List?) ??
              const [];
        }
        // 仅保留成功解析的条目（若带有 status 字段）
        final filtered = episodesData.where((e) {
          if (e is Map<String, dynamic>) {
            final s = (e['status'] ?? '').toString().toLowerCase();
            return s.isEmpty || s == 'success';
          }
          return true;
        }).toList();

        final episodes = filtered
            .map((json) => Episode.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(episodes);
      } else {
        return ApiResponse.error(response.message ?? '获取全集地址失败');
      }
    } catch (e) {
      return ApiResponse.error('获取全集地址失败: $e');
    }
  }

  /// 获取全集及元信息（如 description/cover/videoName/totalEpisodes）
  Future<ApiResponse<ParseAllResult>> getAllEpisodesAndMeta({
    required int dramaId,
  }) async {
    try {
      final response = await _httpService.get(
        ApiEndpoints.parseAll,
        queryParameters: {'id': dramaId.toString()},
      );
      if (response.success && response.data != null) {
        final raw = response.data;
        final result = ParseAllResult.fromRaw(raw);
        return ApiResponse.success(result);
      } else {
        return ApiResponse.error(response.message ?? '获取全集信息失败');
      }
    } catch (e) {
      return ApiResponse.error('获取全集信息失败: $e');
    }
  }

  // 解析辅助：将各种包裹结构解包为包含 parsedUrl 的剧集 Map
  Map<String, dynamic>? _unwrapToEpisodeMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      bool hasUrlKey(Map<String, dynamic> m) {
        const keys = ['play_url', 'playUrl', 'parsedUrl', 'url', 'link'];
        for (final k in keys) {
          final v = m[k];
          if (v != null && v.toString().isNotEmpty) return true;
        }
        return false;
      }

      if (hasUrlKey(raw)) return raw;
      for (final k in ['data', 'result', 'episode', 'item', 'record']) {
        final v = raw[k];
        if (v is Map<String, dynamic>) {
          final mm = _unwrapToEpisodeMap(v);
          if (mm != null) return mm;
        } else if (v is List &&
            v.isNotEmpty &&
            v.first is Map<String, dynamic>) {
          final mm = _unwrapToEpisodeMap(v.first as Map<String, dynamic>);
          if (mm != null) return mm;
        }
      }
      for (final v in raw.values) {
        if (v is Map<String, dynamic>) {
          final mm = _unwrapToEpisodeMap(v);
          if (mm != null) return mm;
        }
      }
    } else if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map<String, dynamic>) {
        return _unwrapToEpisodeMap(first);
      }
    }
    return null;
  }

  // 解析辅助：将各种包裹结构解包为剧集列表
  List<dynamic> _unwrapToEpisodeList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      for (final key in [
        'episodes',
        'results',
        'list',
        'data',
        'items',
        'records',
        'rows',
      ]) {
        final v = raw[key];
        if (v is List) return v;
      }
      final d = raw['data'];
      if (d is Map<String, dynamic>) {
        return _unwrapToEpisodeList(d);
      }
    }
    return const [];
  }
}

/// parseAll meta result model
class ParseAllResult {
  final String? description;
  final String? cover;
  final String? videoName;
  final int? totalEpisodes;
  final List<Episode> episodes;

  ParseAllResult({
    required this.description,
    required this.cover,
    required this.videoName,
    required this.totalEpisodes,
    required this.episodes,
  });

  factory ParseAllResult.fromRaw(dynamic raw) {
    Map<String, dynamic> map;
    if (raw is Map<String, dynamic>) {
      map = raw;
    } else {
      map = {'results': raw};
    }
    List<dynamic> episodesData = (map['results'] as List?) ??
        (map['episodes'] as List?) ??
        (map['list'] as List?) ??
        (map['data'] as List?) ??
        (map['items'] as List?) ??
        (map['records'] as List?) ??
        (map['rows'] as List?) ??
        const [];

    // filter success
    final filtered = episodesData.where((e) {
      if (e is Map<String, dynamic>) {
        final s = (e['status'] ?? '').toString().toLowerCase();
        return s.isEmpty || s == 'success';
      }
      return true;
    }).toList();

    final episodes = filtered
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();

    return ParseAllResult(
      description: map['description'] as String?,
      cover: map['cover'] as String?,
      videoName: map['videoName'] as String?,
      totalEpisodes: (map['totalEpisodes'] is int)
          ? map['totalEpisodes'] as int
          : int.tryParse((map['totalEpisodes'] ?? '').toString()),
      episodes: episodes,
    );
  }
}

/// 短剧列表响应模型
class DramaListResponse {
  final List<Drama> dramas;
  final int total;
  final int totalPages;
  final int currentPage;

  DramaListResponse({
    required this.dramas,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}
