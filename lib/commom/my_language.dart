import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class MyLanguage with ChangeNotifier {
  String _language = "zh"; // 默认中文
  final DatabaseHelper _dbHelper = DatabaseHelper();

  MyLanguage() {
    _loadLanguageFromDatabase();
  }

  String get language => _language;

  Locale get locale => _getLocaleFromLanguageCode(_language);

  /// 从数据库加载语言设置
  Future<void> _loadLanguageFromDatabase() async {
    try {
      final savedLanguage = await _dbHelper.getSetting('language');
      if (savedLanguage != null && _isValidLanguage(savedLanguage)) {
        _language = savedLanguage;
        notifyListeners();
      }
    } catch (e) {
      // 如果加载失败，使用默认语言
      _language = "zh";
    }
  }

  /// 保存语言设置到数据库
  Future<void> _saveLanguageToDatabase(String language) async {
    try {
      await _dbHelper.saveSetting('language', language);
    } catch (e) {
      // 保存失败时的处理
      print('保存语言设置失败: $e');
    }
  }

  /// 验证语言代码是否有效
  bool _isValidLanguage(String languageCode) {
    return supportedLanguages.any((lang) => lang.code == languageCode);
  }

  void changeMode(String language) async {
    if (_isValidLanguage(language)) {
      _language = language;
      await _saveLanguageToDatabase(language);
      notifyListeners();
    }
  }

  Locale _getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case "zh":
        return const Locale('zh', 'CN');
      case "zh_Hant":
        return const Locale('zh', 'TW');
      case "en":
        return const Locale('en', 'US');
      case "es":
        return const Locale('es', 'ES');
      case "th":
        return const Locale('th', 'TH');
      case "pt":
        return const Locale('pt', 'PT');
      case "fr":
        return const Locale('fr', 'FR');
      case "hi":
        return const Locale('hi', 'IN');
      default:
        return const Locale('en', 'US');
    }
  }
}

// 语言配置类
class LanguageConfig {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageConfig({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

// 支持的语言列表
List<LanguageConfig> supportedLanguages = [
  const LanguageConfig(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
  const LanguageConfig(code: 'zh', name: 'Chinese (Simplified)', nativeName: '简体中文', flag: '🇨🇳'),
];

// 保持向后兼容
List<String> languages = supportedLanguages.map((e) => e.code).toList();
