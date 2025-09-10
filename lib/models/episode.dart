/// 剧集模型
class Episode {
  final int dramaId;
  final int episodeNumber;
  final String title;
  final String? playUrl;
  final String? thumbnail;
  final int? duration; // 时长（秒）
  final String? description;
  final bool isWatched;
  final int? watchProgress; // 观看进度（秒）

  Episode({
    required this.dramaId,
    required this.episodeNumber,
    required this.title,
    this.playUrl,
    this.thumbnail,
    this.duration,
    this.description,
    this.isWatched = false,
    this.watchProgress,
  });

  /// 从JSON创建Episode对象
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      dramaId: json['drama_id'] as int? ?? 0,
      episodeNumber: json['episode_number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      playUrl: json['play_url'] as String?,
      thumbnail: json['thumbnail'] as String?,
      duration: json['duration'] as int?,
      description: json['description'] as String?,
      isWatched: json['is_watched'] as bool? ?? false,
      watchProgress: json['watch_progress'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'drama_id': dramaId,
      'episode_number': episodeNumber,
      'title': title,
      'play_url': playUrl,
      'thumbnail': thumbnail,
      'duration': duration,
      'description': description,
      'is_watched': isWatched,
      'watch_progress': watchProgress,
    };
  }

  /// 复制对象
  Episode copyWith({
    int? dramaId,
    int? episodeNumber,
    String? title,
    String? playUrl,
    String? thumbnail,
    int? duration,
    String? description,
    bool? isWatched,
    int? watchProgress,
  }) {
    return Episode(
      dramaId: dramaId ?? this.dramaId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      playUrl: playUrl ?? this.playUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      isWatched: isWatched ?? this.isWatched,
      watchProgress: watchProgress ?? this.watchProgress,
    );
  }

  /// 获取格式化的时长
  String get formattedDuration {
    if (duration == null) return '';
    
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    
    if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  /// 获取观看进度百分比
  double get progressPercentage {
    if (duration == null || watchProgress == null) return 0.0;
    return (watchProgress! / duration!).clamp(0.0, 1.0);
  }

  /// 获取格式化的观看进度
  String get formattedProgress {
    if (watchProgress == null) return '';
    
    final minutes = watchProgress! ~/ 60;
    final seconds = watchProgress! % 60;
    
    if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  /// 是否有播放地址
  bool get hasPlayUrl {
    return playUrl != null && playUrl!.isNotEmpty;
  }

  /// 是否有缩略图
  bool get hasThumbnail {
    return thumbnail != null && thumbnail!.isNotEmpty;
  }

  /// 是否有描述
  bool get hasDescription {
    return description != null && description!.isNotEmpty;
  }

  /// 是否已开始观看
  bool get hasStartedWatching {
    return watchProgress != null && watchProgress! > 0;
  }

  /// 是否观看完成
  bool get isCompleted {
    if (duration == null || watchProgress == null) return false;
    return watchProgress! >= duration! * 0.9; // 观看90%以上认为完成
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Episode &&
        other.dramaId == dramaId &&
        other.episodeNumber == episodeNumber;
  }

  @override
  int get hashCode {
    return dramaId.hashCode ^ episodeNumber.hashCode;
  }

  @override
  String toString() {
    return 'Episode(dramaId: $dramaId, episodeNumber: $episodeNumber, title: $title)';
  }
}
