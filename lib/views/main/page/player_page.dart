import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/player_view_model.dart';

import 'package:video_player/video_player.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/drama.dart';

import '../../../utils/localization.dart';

import '../../../router/fluro_navigator.dart';


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

class _PlayerPageState extends State<PlayerPage> with SingleTickerProviderStateMixin {
  // 沉浸式系统栏仅在本页生效，业务状态交由 PlayerViewModel 管理（Provider）
  // UI 过渡动效（切集时淡入淡出遮罩）
  late final AnimationController _flashCtl;
  late final Animation<double> _flashOpacity;



  @override
  void initState() {
    super.initState();
    // 沉浸式系统栏，仅本页生效
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // 切集过渡淡入淡出动画
    _flashCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _flashOpacity = Tween<double>(begin: 0, end: 0.15).animate(_flashCtl);
  }

  @override
  void dispose() {
    _flashCtl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playChangeFlash() async {
    try {
      await _flashCtl.forward(from: 0);
      await _flashCtl.reverse();
    } catch (_) {}
  }




  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlayerViewModel>(
      create: (_) => PlayerViewModel(
        drama: widget.drama,
        initialEpisodeNumber: widget.episodeNumber,
      )..init(),
      child: Consumer<PlayerViewModel>(
        builder: (context, vm, _) {
          if (vm.hasError) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('load_failed'),
                      style: AppTextStyles.h6.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.errorMessage ?? context.tr('unknown_error'),
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => vm.onPageChanged(vm.currentIndex),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: Builder(
              builder: (context) {
                final padding = MediaQuery.of(context).padding;
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.read<PlayerViewModel>().toggleOverlayVisible(),
                  child: Stack(
                    children: [
                    // 1) 主体：抖音式纵向 PageView
                    PageView.builder(
                      controller: vm.pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: vm.itemCount,
                      onPageChanged: (index) {
                        vm.onPageChanged(index);
                        HapticFeedback.lightImpact(); // 轻微震动反馈
                        _playChangeFlash(); // 过渡淡入淡出
                      },
                      itemBuilder: (context, index) {
                        final ctrl = vm.controllers[index];
                        return Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: (ctrl != null && ctrl.value.isInitialized)
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: ctrl.value.size.width,
                                    height: ctrl.value.size.height,
                                    child: VideoPlayer(ctrl),
                                  ),
                                )
                              : const CircularProgressIndicator(color: AppColors.primary),
                        );
                      },
                    ),

                    // 2) 顶部信息条（返回 + 剧名 + 当前集），带渐变，适配沉浸式安全区，可显隐
                    Positioned(
                      left: 0,
                      right: 0,
                      top: padding.top,
                      child: IgnorePointer(
                        ignoring: !vm.overlayVisible,
                        child: AnimatedOpacity(
                          opacity: vm.overlayVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 160),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black54, Colors.transparent],
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => NavigatorUtils.goBack(context),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.drama.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.tr('episode', params: {'number': (vm.currentIndex + 1).toString()}),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),



                    // 4) 切集过渡淡入淡出遮罩
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _flashCtl,
                          builder: (_, __) => Container(
                            color: Colors.black.withOpacity(_flashOpacity.value),
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                );
              },
            ),
          ); // Scaffold
        },
      ),
    );
  }
}

