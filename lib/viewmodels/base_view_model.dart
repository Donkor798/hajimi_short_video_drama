import 'package:flutter/foundation.dart';

/// 基础ViewModel - 提供通用的状态管理功能
abstract class BaseViewModel extends ChangeNotifier {
  /// 是否正在加载
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 是否有错误
  bool get hasError => _errorMessage != null;

  /// 设置加载状态
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 执行异步操作的通用方法
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    bool clearErrorOnStart = true,
    void Function(String error)? onError,
  }) async {
    try {
      if (clearErrorOnStart) {
        clearError();
      }
      
      if (showLoading) {
        setLoading(true);
      }

      final result = await operation();
      
      if (showLoading) {
        setLoading(false);
      }
      
      return result;
    } catch (e) {
      if (showLoading) {
        setLoading(false);
      }
      
      final errorMsg = e.toString();
      setError(errorMsg);
      
      if (onError != null) {
        onError(errorMsg);
      }
      
      return null;
    }
  }

  /// 重试操作
  Future<void> retry() async {
    clearError();
    await onRetry();
  }

  /// 子类需要实现的重试方法
  Future<void> onRetry() async {}

  /// 刷新数据
  Future<void> refresh() async {
    clearError();
    await onRefresh();
  }

  /// 子类需要实现的刷新方法
  Future<void> onRefresh() async {}

  @override
  void dispose() {
    super.dispose();
  }
}
