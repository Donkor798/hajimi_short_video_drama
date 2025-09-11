import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../router/fluro_navigator.dart';
import '../views/main/main_router.dart';


/// 图片缓存组件 - 统一处理网络图片的加载、缓存和错误处理
class SvCacheImage extends StatelessWidget {
  /// 图片URL
  final String imageUrl;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 适配方式
  final BoxFit fit;

  /// 占位符
  final Widget? placeholder;

  /// 错误时显示的组件
  final Widget? errorWidget;

  /// 边框圆角
  final BorderRadius? borderRadius;

  /// 是否显示加载指示器
  final bool showLoadingIndicator;

  /// 背景颜色
  final Color? backgroundColor;

  /// 缓存时间（天）
  final int? cacheMaxAge;

  const SvCacheImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.showLoadingIndicator = true,
    this.backgroundColor,
    this.cacheMaxAge,
  });

  /// 创建圆形头像
  factory SvCacheImage.avatar({
    required String imageUrl,
    required double size,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return SvCacheImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  /// 创建圆角矩形图片
  factory SvCacheImage.rounded({
    required String imageUrl,
    double? width,
    double? height,
    double radius = 8.0,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return SvCacheImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(radius),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  /// 创建封面图片
  factory SvCacheImage.cover({
    required String imageUrl,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return SvCacheImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8.0),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 安全转换缓存维度：过滤 NaN/Infinity/<=0 的值
    int? _safeDim(double? v) {
      if (v == null) return null;
      if (v.isNaN || v.isInfinite) return null;
      if (v <= 0) return null;
      return v.toInt();
    }

    // 本地校验URL，避免传入空字符串/无host的URL引发 Invalid argument(s): No host specified in URI
    bool _isValidNetworkUrl(String u) {
      final s = u.trim();
      if (s.isEmpty) return false;
      final uri = Uri.tryParse(s);
      if (uri == null) return false;
      final scheme = uri.scheme.toLowerCase();
      return (scheme == 'http' || scheme == 'https') && (uri.host.isNotEmpty);
    }

    Widget imageWidget;
    if (!_isValidNetworkUrl(imageUrl)) {
      // URL 无效：直接使用占位或错误占位，避免触发网络请求
      imageWidget = placeholder ?? _buildErrorWidget(context);
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder != null
            ? (context, url) => placeholder!
            : showLoadingIndicator
                ? (context, url) => _buildLoadingPlaceholder(context)
                : null,
        errorWidget: errorWidget != null
            ? (context, url, error) => errorWidget!
            : (context, url, error) => _buildErrorWidget(context),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        // 仅当宽高为有效数值时，才参与缓存尺寸约束，避免 double.infinity/NaN 转换失败
        memCacheWidth: _safeDim(width),
        memCacheHeight: _safeDim(height),
        maxWidthDiskCache: _safeDim(width),
        maxHeightDiskCache: _safeDim(height),
      );
    }

    // 添加背景颜色
    if (backgroundColor != null) {
      imageWidget = Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: imageWidget,
      );
    }

    // 添加圆角
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// 构建加载占位符
  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  /// 构建错误占位符
  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            '加载失败',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 图片预览组件
class ImagePreview extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ImagePreview({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: heroTag != null
              ? Hero(
                  tag: heroTag!,
                  child: SvCacheImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                )
              : SvCacheImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }

  /// 显示图片预览
  static void show(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
  }) {
    NavigatorUtils.push(
      context,
      MainRouter.imagePreviewPage,
      arguments: {
        'imageUrl': imageUrl,
        'heroTag': heroTag,
      },
    );
  }
}
