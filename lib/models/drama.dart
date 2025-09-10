/// 短剧模型
import '../constants/app_constants.dart';

class Drama {
  final int id;
  final String name;
  final String cover;
  final String updateTime;
  final int score;
  final String? description;
  final String? director;
  final String? cast;
  final String? genre;
  final String? releaseDate;
  final int? totalEpisodes;
  final int? categoryId;
  final bool? isFavorite;

  Drama({
    required this.id,
    required this.name,
    required this.cover,
    required this.updateTime,
    required this.score,
    this.description,
    this.director,
    this.cast,
    this.genre,
    this.releaseDate,
    this.totalEpisodes,
    this.categoryId,
    this.isFavorite,
  });

  /// 从JSON创建Drama对象
  factory Drama.fromJson(Map<String, dynamic> json) {
    // 兼容不同后端字段命名与类型差异
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return v.toInt();
      if (v is String) {
        return int.tryParse(v) ?? 0;
      }
      return 0;
    }

    int? _toIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String _toStr(dynamic v) => v?.toString() ?? '';

    String cover = _toStr(
      json['cover'] ?? json['cover_url'] ?? json['thumb'] ?? json['pic'] ?? json['vod_pic'],
    );
    // 补全相对地址：支持 //host/path、/path、path 三种形式
    if (cover.isNotEmpty && !cover.startsWith('http')) {
      if (cover.startsWith('//')) {
        cover = 'https:$cover';
      } else if (cover.startsWith('/')) {
        cover = '${AppConstants.baseUrl}$cover';
      } else {
        cover = '${AppConstants.baseUrl}/$cover';
      }
    }

    final name = _toStr(json['name'] ?? json['title'] ?? json['vod_name']);
    final updateTime = _toStr(
      json['update_time'] ?? json['updateTime'] ?? json['last_update'] ?? json['vod_time'] ??
      json['time'] ?? json['date'] ?? json['pubdate'] ?? json['updated_at'] ?? json['create_time'],
    );
    final score = _toInt(json['score'] ?? json['rating'] ?? json['vod_score']);
    final releaseDate = _toStr(
      json['release_date'] ?? json['releaseDate'] ?? json['vod_pubdate'] ?? json['pubdate'] ?? json['publish_date'],
    );
    final totalEpisodes = _toIntNullable(json['total_episodes'] ?? json['episode_total'] ?? json['vod_total']);
    final categoryId = _toIntNullable(json['category_id'] ?? json['type_id'] ?? json['tid']);

    return Drama(
      id: _toInt(json['id'] ?? json['drama_id'] ?? json['vod_id']),
      name: name,
      cover: cover,
      updateTime: updateTime,
      score: score,
      description: json['description'] as String? ?? json['vod_remarks'] as String?,
      director: json['director'] as String?,
      cast: json['cast'] as String?,
      genre: json['genre'] as String?,
      releaseDate: releaseDate,
      totalEpisodes: totalEpisodes,
      categoryId: categoryId,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'update_time': updateTime,
      'score': score,
      'description': description,
      'director': director,
      'cast': cast,
      'genre': genre,
      'release_date': releaseDate,
      'total_episodes': totalEpisodes,
      'category_id': categoryId,
      'is_favorite': isFavorite,
    };
  }

  /// 复制对象
  Drama copyWith({
    int? id,
    String? name,
    String? cover,
    String? updateTime,
    int? score,
    String? description,
    String? director,
    String? cast,
    String? genre,
    String? releaseDate,
    int? totalEpisodes,
    int? categoryId,
    bool? isFavorite,
  }) {
    return Drama(
      id: id ?? this.id,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      updateTime: updateTime ?? this.updateTime,
      score: score ?? this.score,
      description: description ?? this.description,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// 获取评分星级（1-5星）
  double get starRating {
    return (score / 20.0).clamp(0.0, 5.0);
  }

  /// 获取格式化的评分
  String get formattedScore {
    return (score / 10.0).toStringAsFixed(1);
  }

  /// 是否有描述
  bool get hasDescription {
    return description != null && description!.isNotEmpty;
  }

  /// 是否有导演信息
  bool get hasDirector {
    return director != null && director!.isNotEmpty;
  }

  /// 是否有演员信息
  bool get hasCast {
    return cast != null && cast!.isNotEmpty;
  }

  /// 是否有类型信息
  bool get hasGenre {
    return genre != null && genre!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Drama && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'Drama(id: $id, name: $name, score: $score)';
  }
}
