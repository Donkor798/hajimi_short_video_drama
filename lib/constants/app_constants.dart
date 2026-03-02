/// 应用常量配置
class AppConstants {
  // API相关常量
  static const String baseUrl = 'https://api.r2afosne.dpdns.org';
  static const String apiVersion = 'v1';

  // 网络请求超时时间
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒

  // 分页相关
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // 缓存相关
  static const String cacheKeyPrefix = 'hajimi_';
  static const int imageCacheMaxAge = 7; // 7天

  // 应用信息
  static const String appName = '哈吉米短剧';
  static const String appVersion = '1.0.0';

  // 主题相关
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;

  // 动画时长
  static const int defaultAnimationDuration = 300; // 毫秒

  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String unknownErrorMessage = '未知错误，请稍后重试';
}

/// API端点常量
class ApiEndpoints {
  // 分类相关
  static const String categories = '/vod/categories';

  // 推荐相关
  static const String recommend = '/vod/recommend';

  // 列表相关
  static const String list = '/vod/list';

  // 搜索相关
  static const String search = '/vod/search';

  // 最新剧集
  static const String latest = '/vod/latest';

  // 解析相关
  static const String parseSingle = '/vod/parse/single';
  static const String parseBatch = '/vod/parse/batch';
  static const String parseAll = '/vod/parse/all';
}

/// 路由常量
class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String detail = '/detail';
  static const String player = '/player';
  static const String category = '/category';
  static const String settings = '/settings';
}

/// 存储键常量
class StorageKeys {
  static const String language = 'language';
  static const String theme = 'theme';
  static const String playHistory = 'play_history';
  static const String favorites = 'favorites';
  static const String searchHistory = 'search_history';
}
