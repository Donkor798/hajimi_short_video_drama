import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/drama.dart';
import '../../../models/episode.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../main_router.dart';

/// 视频播放器页面
/// Author: Donkor
/// Created: 2024-12-19
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
  bool _isFullScreen = false;

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
                    '播放失败',
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
      appBar: _isFullScreen ? null : _buildAppBar(),
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
            '第${widget.episodeNumber}集',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMoreOptions(),
        ),
      ],
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
              '播放失败',
              style: AppTextStyles.h6.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '未知错误',
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
              child: const Text('重试'),
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
        
        // 控制栏（非全屏时显示）
        if (!_isFullScreen) _buildControlBar(),
      ],
    );
  }

  /// 构建控制栏
  Widget _buildControlBar() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 播放控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 上一集
              IconButton(
                onPressed: _hasPreviousEpisode() ? _playPreviousEpisode : null,
                icon: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              // 播放/暂停
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _videoPlayerController?.value.isPlaying == true
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              
              // 下一集
              IconButton(
                onPressed: _hasNextEpisode() ? _playNextEpisode : null,
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 剧集信息
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '第${widget.episodeNumber}集',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.drama.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 全屏按钮
              IconButton(
                onPressed: _toggleFullScreen,
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 切换播放/暂停
  void _togglePlayPause() {
    if (_videoPlayerController?.value.isPlaying == true) {
      _videoPlayerController?.pause();
    } else {
      _videoPlayerController?.play();
    }
  }

  /// 切换全屏
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  /// 是否有上一集
  bool _hasPreviousEpisode() {
    return widget.episodeNumber > 1;
  }

  /// 是否有下一集
  bool _hasNextEpisode() {
    // 这里应该根据实际的剧集数量判断
    return widget.episodeNumber < (widget.drama.totalEpisodes ?? 100);
  }

  /// 播放上一集
  void _playPreviousEpisode() {
    if (_hasPreviousEpisode()) {
      NavigatorUtils.goBack(context);
      NavigatorUtils.push(
        context,
        '${MainRouter.playerPage}/${widget.drama.id}/${widget.episodeNumber - 1}',
        arguments: widget.drama,
      );
    }
  }

  /// 播放下一集
  void _playNextEpisode() {
    if (_hasNextEpisode()) {
      NavigatorUtils.goBack(context);
      NavigatorUtils.push(
        context,
        '${MainRouter.playerPage}/${widget.drama.id}/${widget.episodeNumber + 1}',
        arguments: widget.drama,
      );
    }
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('播放速度'),
              onTap: () {
                NavigatorUtils.goBack(context);
                _showSpeedOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.high_quality),
              title: const Text('画质选择'),
              onTap: () {
                NavigatorUtils.goBack(context);
                _showQualityOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('下载'),
              onTap: () {
                NavigatorUtils.goBack(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('下载功能开发中')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示播放速度选项
  void _showSpeedOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('播放速度调节功能开发中')),
    );
  }

  /// 显示画质选项
  void _showQualityOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('画质选择功能开发中')),
    );
  }
}
