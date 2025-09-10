import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class MyColor extends ChangeNotifier {
  MaterialColor color = colors[0];
  int _currentColorIndex = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  MyColor() {
    _loadColorFromDatabase();
  }

  /// 从数据库加载颜色设置
  Future<void> _loadColorFromDatabase() async {
    try {
      final colorIndexStr = await _dbHelper.getSetting('theme_color_index');
      if (colorIndexStr != null) {
        final index = int.tryParse(colorIndexStr) ?? 0;
        if (index >= 0 && index < colors.length) {
          _currentColorIndex = index;
          color = colors[index];
          notifyListeners();
        }
      }
    } catch (e) {
      // 如果加载失败，使用默认颜色
      _currentColorIndex = 0;
      color = colors[0];
    }
  }

  /// 保存颜色设置到数据库
  Future<void> _saveColorToDatabase(int index) async {
    try {
      await _dbHelper.saveSetting('theme_color_index', index.toString());
    } catch (e) {
      // 保存失败时的处理
      print('保存主题颜色失败: $e');
    }
  }

  void setColor(int index) {
    if (index >= 0 && index < colors.length) {
      _currentColorIndex = index;
      color = colors[index];
      _saveColorToDatabase(index);
      notifyListeners();
    }
  }

  /// 更改主题颜色
  void changeTheme(int index) {
    if (index >= 0 && index < colors.length) {
      _currentColorIndex = index;
      color = colors[index];
      _saveColorToDatabase(index);
      notifyListeners();
    }
  }

  /// 获取当前颜色索引
  int get currentColorIndex => _currentColorIndex;

  /// 随主题动态变化
  MaterialColor get colorPrimary => color;
}

///自定义的主题色
List<MaterialColor> colors = [
  Colors.red,
  primaryBlack,
  Colors.purple,
  Colors.cyan,
  Colors.blue,
  Colors.amber,
  Colors.green,
];

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF424242),
    100: Color(0xFF303030),
    200: Color(0xFF212121),
    300: Color(0xFF1C1C1C),
    400: Color(0xFF171717),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF0D0D0D),
    700: Color(0xFF0A0A0A),
    800: Color(0xFF070707),
    900: Color(0xFF040404),
  },
);
const int _blackPrimaryValue = 0xFF000000;

///背景颜色
const Color background = Color(0xfff4f4f4);