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
        List<dynamic> dramasData = const [];
        if (raw is List) {
          dramasData = raw;
        } else if (raw is Map<String, dynamic>) {
          dramasData = (raw['list'] as List?) ??
              (raw['data'] as List?) ??
              (raw['items'] as List?) ??
              (raw['records'] as List?) ??
              (raw['rows'] as List?) ??
              const [];
        }
        final dramas = dramasData
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

      if (response.success && response.data != null) {
        final raw = response.data;
        List<dynamic> dramasData = const [];
        if (raw is List) {
          dramasData = raw;
        } else if (raw is Map<String, dynamic>) {
          dramasData = (raw['list'] as List?) ??
              (raw['data'] as List?) ??
              (raw['items'] as List?) ??
              (raw['records'] as List?) ??
              (raw['rows'] as List?) ??
              const [];
        }
        final dramas = dramasData
            .map((json) => Drama.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(dramas);
      } else {
        return ApiResponse.error(response.message ?? '获取最新失败');
      }
    } catch (e) {
      return ApiResponse.error('获取最新失败: $e');
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
        final episodeData = Episode.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(episodeData);
      } else {
        return ApiResponse.error(response.message ?? '获取播放地址失败');
      }
    } catch (e) {
      return ApiResponse.error('获取播放地址失败: $e');
    }
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
        final data = response.data as Map<String, dynamic>;
        final episodesData = data['episodes'] as List<dynamic>? ?? [];

        final episodes = episodesData
            .map((json) => Episode.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(episodes);
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
