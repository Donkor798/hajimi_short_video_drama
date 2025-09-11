import 'package:flutter_test/flutter_test.dart';
import 'package:hajimi_short_video_drama/viewmodels/settings_view_model.dart';
import 'package:hajimi_short_video_drama/commom/my_color.dart';
import 'package:hajimi_short_video_drama/commom/my_language.dart';

/// 设置功能测试
/// 测试设置页面的各项功能是否正常工作
/// author : Donkor , 创建日期: 2025-09-11
void main() {
  group('设置功能测试', () {
    late SettingsViewModel settingsViewModel;
    late MyColor myColor;
    late MyLanguage myLanguage;

    setUp(() {
      settingsViewModel = SettingsViewModel();
      myColor = MyColor();
      myLanguage = MyLanguage();
    });

    test('SettingsViewModel 初始化测试', () {
      expect(settingsViewModel.language, 'zh');
      expect(settingsViewModel.themeColorIndex, 0);

      expect(settingsViewModel.isLoading, false);
    });


    test('MyColor 初始化测试', () {
      expect(myColor.currentColorIndex, 0);
      expect(myColor.colorPrimary, isNotNull);
    });

    test('MyLanguage 初始化测试', () {
      expect(myLanguage.language, 'zh');
      expect(myLanguage.locale.languageCode, 'zh');
    });


    test('语言显示名称测试', () {
      expect(settingsViewModel.getLanguageDisplayName('zh'), '中文');
      expect(settingsViewModel.getLanguageDisplayName('en'), 'English');
      expect(settingsViewModel.getLanguageDisplayName('unknown'), 'unknown');
    });

  });

  group('设置功能集成测试', () {
    test('语言切换功能', () async {
      final myLanguage = MyLanguage();
      
      // 测试切换到英文
      myLanguage.changeMode('en');
      expect(myLanguage.language, 'en');
      expect(myLanguage.locale.languageCode, 'en');
      
      // 测试切换回中文
      myLanguage.changeMode('zh');
      expect(myLanguage.language, 'zh');
      expect(myLanguage.locale.languageCode, 'zh');
    });

    test('主题颜色切换功能', () {
      final myColor = MyColor();
      
      // 测试切换到第二个颜色
      myColor.setColor(1);
      expect(myColor.currentColorIndex, 1);
      
      // 测试切换到第一个颜色
      myColor.setColor(0);
      expect(myColor.currentColorIndex, 0);
    });



  });
}
