import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/drama.dart';

import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';

import '../main_router.dart';

/// 视频播放器页面
/// Author: Donkor
/// Created: 2025-09-11
class PlayerPage extends StatefulWidget {
  final Drama drama;
  final int episodeNumber;
  final String? videoUrl;

  const PlayerPage({
    super.key,
    required this.drama,
    required this.episodeNumber,
    this.videoUrl,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  /// 初始化播放器
  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // 使用示例视频URL，实际项目中应该从API获取
      final videoUrl = widget.videoUrl ??
          'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,

        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.textTertiary,
          bufferedColor: AppColors.textSecondary,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('load_failed'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// 释放播放器资源
  void _disposePlayer() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => NavigatorUtils.goBack(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.drama.name,
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            context.tr('episode', params: {'number': widget.episodeNumber.toString()}),
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),

    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('load_failed'),
              style: AppTextStyles.h6.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? context.tr('unknown_error'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _initializePlayer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 视频播放器
        Expanded(
          child: _chewieController != null
              ? Chewie(controller: _chewieController!)
              : const SizedBox(),
        ),
        _buildEpisodeNavBar(),

        // 控制栏（非全屏时显示）

      ],
    );
  }













  /// 剧集切换按钮栏
  Widget _buildEpisodeNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_hasPreviousEpisode())
            ElevatedButton.icon(
              onPressed: _playPreviousEpisode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.skip_previous),
              label: Text(context.tr('previous_episode')),
            ),
          const SizedBox(width: 12),
          if (_hasNextEpisode())
            ElevatedButton.icon(
              onPressed: _playNextEpisode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.skip_next),
              label: Text(context.tr('next_episode')),
            ),
        ],
      ),
    );
  }

  bool _hasPreviousEpisode() => widget.episodeNumber > 1;

  bool _hasNextEpisode() {
    final total = widget.drama.totalEpisodes;
    if (total == null) return true;
    return widget.episodeNumber < total;
  }

  void _playPreviousEpisode() {
    if (!_hasPreviousEpisode()) return;
    NavigatorUtils.push(
      context,
      '${MainRouter.playerPage}/${widget.drama.id}/${widget.episodeNumber - 1}',
      replace: true,
      arguments: {'drama': widget.drama},
    );
  }

  void _playNextEpisode() {
    if (!_hasNextEpisode()) return;
    NavigatorUtils.push(
      context,
      '${MainRouter.playerPage}/${widget.drama.id}/${widget.episodeNumber + 1}',
      replace: true,
      arguments: {'drama': widget.drama},
    );
  }



}
