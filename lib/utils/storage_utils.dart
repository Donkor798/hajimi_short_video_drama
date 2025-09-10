import 'dart:convert';
import '../constants/app_constants.dart';
import '../database/database_helper.dart';

/// 本地存储工具类
class StorageUtils {
  // 迁移到 SQLite，不再使用 SharedPreferences
  static final DatabaseHelper _db = DatabaseHelper();

  /// 初始化（可选）
  static Future<void> init() async {
    // 触发数据库初始化
    await _db.database;
  }

  /// 保存字符串
  static Future<bool> setString(String key, String value) async {
    await init();
    await _db.saveSetting(_getKey(key), value);
    return true;
  }

  /// 获取字符串
  static Future<String?> getString(String key) async {
    await init();
    return _db.getSetting(_getKey(key));
  }

  /// 保存整数
  static Future<bool> setInt(String key, int value) async {
    await init();
    await _db.saveSetting(_getKey(key), value.toString());
    return true;
  }

  /// 获取整数
  static Future<int?> getInt(String key) async {
    await init();
    final v = await _db.getSetting(_getKey(key));
    return v == null ? null : int.tryParse(v);
  }

  /// 保存布尔值
  static Future<bool> setBool(String key, bool value) async {
    await init();
    await _db.saveSetting(_getKey(key), value ? 'true' : 'false');
    return true;
  }

  /// 获取布尔值
  static Future<bool?> getBool(String key) async {
    await init();
    final v = await _db.getSetting(_getKey(key));
    if (v == null) return null;
    if (v == 'true') return true;
    if (v == 'false') return false;
    return null;
  }

  /// 保存双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    await init();
    await _db.saveSetting(_getKey(key), value.toString());
    return true;
  }

  /// 获取双精度浮点数
  static Future<double?> getDouble(String key) async {
    await init();
    final v = await _db.getSetting(_getKey(key));
    return v == null ? null : double.tryParse(v);
  }

  /// 保存字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    await init();
    final jsonString = json.encode(value);
    await _db.saveSetting(_getKey(key), jsonString);
    return true;
  }

  /// 获取字符串列表
  static Future<List<String>?> getStringList(String key) async {
    await init();
    final jsonString = await _db.getSetting(_getKey(key));
    if (jsonString == null) return null;
    try {
      final list = json.decode(jsonString) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  /// 保存JSON对象
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    await init();
    final jsonString = json.encode(value);
    await _db.saveSetting(_getKey(key), jsonString);
    return true;
  }

  /// 获取JSON对象
  static Future<Map<String, dynamic>?> getJson(String key) async {
    await init();
    final jsonString = await _db.getSetting(_getKey(key));
    if (jsonString == null) return null;
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 保存JSON列表
  static Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await init();
    final jsonString = json.encode(value);
    await _db.saveSetting(_getKey(key), jsonString);
    return true;
  }

  /// 获取JSON列表
  static Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    await init();
    final jsonString = await _db.getSetting(_getKey(key));
    if (jsonString == null) return null;
    try {
      final list = json.decode(jsonString) as List<dynamic>;
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    } catch (_) {
      return null;
    }
  }

  /// 删除指定键的数据
  static Future<bool> remove(String key) async {
    await init();
    await _db.deleteSetting(_getKey(key));
    return true;
  }

  /// 检查是否包含指定键
  static Future<bool> containsKey(String key) async {
    await init();
    final settings = await _db.getAllSettings();
    return settings.containsKey(_getKey(key));
  }

  /// 清空所有数据
  static Future<bool> clear() async {
    await init();
    // 清空所有设置（谨慎使用）
    final settings = await _db.getAllSettings();
    for (final k in settings.keys) {
      await _db.deleteSetting(k);
    }
    return true;
  }

  /// 获取所有键
  static Future<Set<String>> getKeys() async {
    await init();
    final settings = await _db.getAllSettings();
    return settings.keys.toSet();
  }

  /// 获取带前缀的键
  static String _getKey(String key) {
    return '${AppConstants.cacheKeyPrefix}$key';
  }

  // 便捷方法

  /// 保存语言设置
  static Future<bool> setLanguage(String language) async {
    return setString(StorageKeys.language, language);
  }

  /// 获取语言设置
  static Future<String?> getLanguage() async {
    return getString(StorageKeys.language);
  }

  /// 保存主题设置
  static Future<bool> setTheme(String theme) async {
    return setString(StorageKeys.theme, theme);
  }

  /// 获取主题设置
  static Future<String?> getTheme() async {
    return getString(StorageKeys.theme);
  }

  /// 保存播放历史
  static Future<bool> setPlayHistory(List<Map<String, dynamic>> history) async {
    // 暂存为 JSON 到 settings，后续可考虑单独建表
    return setJsonList(StorageKeys.playHistory, history);
  }

  /// 获取播放历史
  static Future<List<Map<String, dynamic>>?> getPlayHistory() async {
    return getJsonList(StorageKeys.playHistory);
  }

  /// 保存收藏列表
  static Future<bool> setFavorites(List<Map<String, dynamic>> favorites) async {
    // 如果后续接入用户体系，可切换至 user_favorites 表
    return setJsonList(StorageKeys.favorites, favorites);
  }

  /// 获取收藏列表
  static Future<List<Map<String, dynamic>>?> getFavorites() async {
    return getJsonList(StorageKeys.favorites);
  }

  /// 保存搜索历史
  static Future<bool> setSearchHistory(List<String> history) async {
    await init();
    // 清空并按顺序写入
    await _db.clearSearchHistory();
    for (final keyword in history) {
      await _db.saveSearchHistory(keyword);
    }
    return true;
  }

  /// 获取搜索历史
  static Future<List<String>?> getSearchHistory() async {
    await init();
    // 默认取 20 条
    final list = await _db.getSearchHistory(limit: 20);
    return list;
  }
}
