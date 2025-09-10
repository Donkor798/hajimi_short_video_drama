import 'dart:async';
import 'package:sqflite/sqflite.dart';

/// 数据库管理类
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // 使用应用自有的数据库名称，防止与其他工程冲突
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/hajimi_short_video_drama.db';

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // 开启外键支持
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建设置表
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建搜索历史表
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword TEXT UNIQUE NOT NULL,
        search_count INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建用户收藏表
    await db.execute('''
      CREATE TABLE user_favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        target_id TEXT NOT NULL,
        target_type TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 插入默认设置
    await _insertDefaultSettings(db);
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 这里处理数据库版本升级逻辑
    if (oldVersion < 2) {
      // 添加新字段或表的逻辑
    }
  }

  /// 插入默认设置
  Future<void> _insertDefaultSettings(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final defaultSettings = [
      {'key': 'language', 'value': 'zh'},
      {'key': 'theme_color_index', 'value': '0'},
      {'key': 'dark_mode', 'value': 'false'},
      {'key': 'notifications_enabled', 'value': 'true'},
      {'key': 'sound_enabled', 'value': 'true'},
      {'key': 'vibration_enabled', 'value': 'true'},
      {'key': 'font_size', 'value': '16.0'},
    ];

    for (final setting in defaultSettings) {
      await db.insert('settings', {
        'key': setting['key'],
        'value': setting['value'],
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// 保存设置
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取设置
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  /// 获取所有设置
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    
    final Map<String, String> settings = {};
    for (final map in maps) {
      settings[map['key'] as String] = map['value'] as String;
    }
    
    return settings;
  }

  /// 删除设置
  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// 保存搜索历史
  Future<void> saveSearchHistory(String keyword) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 检查是否已存在
    final existing = await db.query(
      'search_history',
      where: 'keyword = ?',
      whereArgs: [keyword],
    );

    if (existing.isNotEmpty) {
      // 更新搜索次数和时间
      await db.update(
        'search_history',
        {
          'search_count': (existing.first['search_count'] as int) + 1,
          'updated_at': now,
        },
        where: 'keyword = ?',
        whereArgs: [keyword],
      );
    } else {
      // 插入新记录
      await db.insert('search_history', {
        'keyword': keyword,
        'search_count': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// 获取搜索历史
  Future<List<String>> getSearchHistory({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_history',
      orderBy: 'updated_at DESC',
      limit: limit,
    );

    return maps.map((map) => map['keyword'] as String).toList();
  }

  /// 删除搜索历史项
  Future<void> deleteSearchHistoryItem(String keyword) async {
    final db = await database;
    await db.delete(
      'search_history',
      where: 'keyword = ?',
      whereArgs: [keyword],
    );
  }

  /// 清空搜索历史
  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  /// 保存用户收藏
  Future<void> saveUserFavorite(String userId, String targetId, String targetType) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'user_favorites',
      {
        'user_id': userId,
        'target_id': targetId,
        'target_type': targetType,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 删除用户收藏
  Future<void> deleteUserFavorite(String userId, String targetId, String targetType) async {
    final db = await database;
    await db.delete(
      'user_favorites',
      where: 'user_id = ? AND target_id = ? AND target_type = ?',
      whereArgs: [userId, targetId, targetType],
    );
  }

  /// 检查是否已收藏
  Future<bool> isFavorited(String userId, String targetId, String targetType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_favorites',
      where: 'user_id = ? AND target_id = ? AND target_type = ?',
      whereArgs: [userId, targetId, targetType],
    );

    return maps.isNotEmpty;
  }

  /// 获取用户收藏列表
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId, String targetType) async {
    final db = await database;
    return await db.query(
      'user_favorites',
      where: 'user_id = ? AND target_type = ?',
      whereArgs: [userId, targetType],
      orderBy: 'created_at DESC',
    );
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
