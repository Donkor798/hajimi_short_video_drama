import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';

/// 我的页面 ViewModel（MVVM）
/// 负责：用户资料（昵称/ID/头像）持久化、统计数据（收藏/历史）、清理历史
/// author : Donkor , 创建日期: 2025-09-11
class MyViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  bool _loading = false;
  bool get isLoading => _loading;

  // 用户资料
  String _nickname = '';
  String get nickname => _nickname;

  String _userId = '';
  String get userId => _userId;

  String _avatarUrl = '';
  String get avatarUrl => _avatarUrl;

  // 统计
  int _favoriteCount = 0;
  int get favoriteCount => _favoriteCount;

  int _historyCount = 0;
  int get historyCount => _historyCount;

  String? _error;
  String? get errorMessage => _error;

  /// 初始化：加载/生成 用户资料 + 统计数据
  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _ensureProfile();
      await Future.wait([
        _loadFavoriteCount(),
        _loadHistoryCount(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await init();
  }

  /// 确保用户资料存在（如无则生成并保存）
  Future<void> _ensureProfile() async {
    _nickname = await _db.getSetting('user_nickname') ?? '';
    _userId = await _db.getSetting('user_id') ?? '';
    _avatarUrl = await _db.getSetting('user_avatar') ?? '';

    if (_userId.isEmpty) {
      // 生成 180000-999999 的 6 位随机数
      final rand = Random();
      _userId = (180000 + rand.nextInt(820000)).toString();
      await _db.saveSetting('user_id', _userId);
    }
    if (_nickname.isEmpty) {
      _nickname = _generateNickname();
      await _db.saveSetting('user_nickname', _nickname);
    }
    if (_avatarUrl.isEmpty) {
      _avatarUrl = _buildAvatarUrl(seed: _userId);
      await _db.saveSetting('user_avatar', _avatarUrl);
    }
  }

  String _generateNickname() {
    // nick 前缀 user_ + 6 位小写字母
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    final r = Random();
    final suffix = List.generate(6, (_) => letters[r.nextInt(letters.length)]).join();
    return 'user_$suffix';
  }

  String _buildAvatarUrl({required String seed}) {
    // 使用 picsum.photos 的 seed 生成稳定头像
    return 'https://picsum.photos/seed/$seed/200';
  }

  Future<void> _loadFavoriteCount() async {
    final list = await _db.getUserFavorites('local', 'drama');
    _favoriteCount = list.length;
  }

  Future<void> _loadHistoryCount() async {
    final list = await _db.getPlayHistory(limit: 1 << 20);
    _historyCount = list.length;
  }

  /// 清空观看历史
  Future<void> clearHistory() async {
    await _db.clearPlayHistory();
    _historyCount = 0;
    notifyListeners();
  }

  /// 更换头像：随机 seed，持久化
  Future<void> refreshAvatar() async {
    final r = Random();
    final seed = '${_userId}_${r.nextInt(1 << 32)}';
    _avatarUrl = _buildAvatarUrl(seed: seed);
    await _db.saveSetting('user_avatar', _avatarUrl);
    notifyListeners();
  }

  /// 随机昵称：重新生成并持久化
  Future<void> regenerateNickname() async {
    _nickname = _generateNickname();
    await _db.saveSetting('user_nickname', _nickname);
    notifyListeners();
  }

  /// 退出登录：重置本地用户资料（重新生成 ID/昵称/头像）
  Future<void> logoutAndResetProfile() async {
    await _db.deleteSetting('user_id');
    await _db.deleteSetting('user_nickname');
    await _db.deleteSetting('user_avatar');
    await _ensureProfile();
    notifyListeners();
  }

  /// 复制用户ID到剪贴板
  Future<void> copyUserId() async {
    await Clipboard.setData(ClipboardData(text: _userId));
  }
}

