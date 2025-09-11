import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/log_util.dart';
import '../constants/app_constants.dart';

/// HTTP服务类 - 封装网络请求
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  late Dio _dio;

  /// 初始化HTTP服务
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => LogD(obj.toString()),
    ));

    // 添加错误拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }


  /// 处理错误
  void _handleError(DioException error) {
    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '请求超时，请检查网络连接';
        break;
      case DioExceptionType.badResponse:
        errorMessage = '服务器响应错误: ${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = '请求已取消';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          errorMessage = '网络连接失败，请检查网络设置';
        } else {
          errorMessage = '未知错误: ${error.message}';
        }
        break;
      default:
        errorMessage = '网络请求失败';
    }

    // 使用 log_util 进行错误打印
    LogE('HTTP Error: $errorMessage; detail: ${error.message}');
  }

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('未知错误: $e');
    }
  }

  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('未知错误: $e');
    }
  }

  /// 获取错误消息
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppConstants.networkErrorMessage;
      case DioExceptionType.badResponse:
        return AppConstants.serverErrorMessage;
      default:
        return AppConstants.unknownErrorMessage;
    }
  }
}

/// API响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  /// 成功响应
  factory ApiResponse.success(T data) {
    return ApiResponse._(
      success: true,
      data: data,
    );
  }

  /// 错误响应
  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
