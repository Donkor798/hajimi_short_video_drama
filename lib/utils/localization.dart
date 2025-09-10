import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 国际化工具类
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// 获取当前的本地化实例
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// 支持的语言代码
  static const List<String> supportedLanguages = ['zh', 'en'];

  /// 支持的本地化
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 中文
    Locale('en', 'US'), // 英文
  ];

  /// 加载本地化字符串
  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      
      return true;
    } catch (e) {
      // 如果加载失败，使用默认的中文
      if (locale.languageCode != 'zh') {
        String jsonString = await rootBundle.loadString('assets/lang/zh.json');
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        
        _localizedStrings = jsonMap.map((key, value) {
          return MapEntry(key, value.toString());
        });
      }
      return false;
    }
  }

  /// 获取本地化字符串
  String translate(String key, {Map<String, String>? params}) {
    String text = _localizedStrings[key] ?? key;
    
    // 处理参数替换
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    
    return text;
  }

  /// 简化的获取方法
  String t(String key, {Map<String, String>? params}) {
    return translate(key, params: params);
  }
}

/// 本地化代理
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLanguages.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// 本地化扩展方法
extension LocalizationExtension on BuildContext {
  /// 获取本地化字符串
  String tr(String key, {Map<String, String>? params}) {
    return AppLocalizations.of(this)?.translate(key, params: params) ?? key;
  }
  
  /// 获取当前语言代码
  String get languageCode {
    return Localizations.localeOf(this).languageCode;
  }
  
  /// 是否为中文
  bool get isZh {
    return languageCode == 'zh';
  }
  
  /// 是否为英文
  bool get isEn {
    return languageCode == 'en';
  }
}
