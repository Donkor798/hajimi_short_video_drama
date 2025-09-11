import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../commom/my_color.dart'; // 引入主题色列表用于校验索引范围


/// 设置页面 ViewModel（MVVM）
/// 负责：语言切换、主题颜色、缓存管理等（已移除深色模式；已移除字体大小设置）
/// author : Donkor , 创建日期: 2025-09-11
class SettingsViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  bool _loading = false;
  bool get isLoading => _loading;

  // 语言设置
  String _language = 'zh';
  String get language => _language;

  // 主题颜色索引
  int _themeColorIndex = 0;
  int get themeColorIndex => _themeColorIndex;


  // 缓存大小（MB）
  double _cacheSize = 0.0;
  double get cacheSize => _cacheSize;

  String? _error;
  String? get errorMessage => _error;

  /// 初始化设置数据
  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadSettings();
      await _calculateCacheSize();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载所有设置
  Future<void> _loadSettings() async {
    _language = await _db.getSetting('language') ?? 'zh';
    _themeColorIndex = int.tryParse(await _db.getSetting('theme_color_index') ?? '0') ?? 0;
    // 约束主题颜色索引到有效范围 [0, colors.length)，超出则回退到默认红色并写回数据库
    if (_themeColorIndex < 0 || _themeColorIndex >= colors.length) {
      _themeColorIndex = 0;
      await _db.saveSetting('theme_color_index', '0');
    }
  }

  /// 计算缓存大小
  Future<void> _calculateCacheSize() async {
    try {
      // 模拟计算缓存大小
      // 实际项目中可以计算图片缓存、数据库大小等

      // 获取搜索历史数量作为缓存大小的一部分
      final searchHistory = await _db.getSearchHistory();
      final playHistory = await _db.getPlayHistory();

      // 模拟缓存大小计算（基于数据量）
      double calculatedSize = 50.0; // 基础缓存大小
      calculatedSize += searchHistory.length * 0.1; // 搜索历史
      calculatedSize += playHistory.length * 0.5; // 播放历史

      _cacheSize = calculatedSize;
    } catch (e) {
      _cacheSize = 0.0;
    }
  }

  /// 切换语言
  Future<void> setLanguage(String newLanguage) async {
    if (_language != newLanguage) {
      _language = newLanguage;
      await _db.saveSetting('language', newLanguage);
      notifyListeners();
    }
  }

  /// 设置主题颜色
  Future<void> setThemeColor(int colorIndex) async {
    if (_themeColorIndex != colorIndex) {
      _themeColorIndex = colorIndex;
      await _db.saveSetting('theme_color_index', colorIndex.toString());
      notifyListeners();
    }
  }


  /// 清空缓存
  Future<void> clearCache() async {
    try {
      _loading = true;
      notifyListeners();

      // 清理搜索历史
      await _db.clearSearchHistory();

      // 清理播放历史（可选，用户可能不希望清理）
      // await _db.clearPlayHistory();

      // 模拟清理图片缓存等操作
      await Future.delayed(const Duration(seconds: 1));

      // 重新计算缓存大小
      await _calculateCacheSize();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 重置所有设置
  Future<void> resetSettings() async {
    try {
      _loading = true;
      notifyListeners();

      // 重置所有设置到默认值
      await _db.saveSetting('language', 'zh');
      await _db.saveSetting('theme_color_index', '0');

      // 重新加载设置
      await _loadSettings();
      await _calculateCacheSize();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 获取语言显示名称
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }


  /// 清除错误状态
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
