import 'package:flutter_test/flutter_test.dart';
import 'package:hajimi_short_video_drama/models/drama.dart';

void main() {
  group('Drama Model Tests', () {
    test('Drama.fromJson should create Drama object correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'name': '测试短剧',
        'cover': 'https://example.com/cover.jpg',
        'update_time': '2024-12-19',
        'score': 85,
        'description': '这是一个测试短剧',
        'director': '测试导演',
        'cast': '测试演员',
        'genre': '爱情',
        'total_episodes': 20,
      };

      // Act
      final drama = Drama.fromJson(json);

      // Assert
      expect(drama.id, 1);
      expect(drama.name, '测试短剧');
      expect(drama.cover, 'https://example.com/cover.jpg');
      expect(drama.updateTime, '2024-12-19');
      expect(drama.score, 85);
      expect(drama.description, '这是一个测试短剧');
      expect(drama.director, '测试导演');
      expect(drama.cast, '测试演员');
      expect(drama.genre, '爱情');
      expect(drama.totalEpisodes, 20);
    });

    test('Drama.toJson should convert Drama object to JSON correctly', () {
      // Arrange
      final drama = Drama(
        id: 1,
        name: '测试短剧',
        cover: 'https://example.com/cover.jpg',
        updateTime: '2024-12-19',
        score: 85,
        description: '这是一个测试短剧',
        director: '测试导演',
        cast: '测试演员',
        genre: '爱情',
        totalEpisodes: 20,
      );

      // Act
      final json = drama.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], '测试短剧');
      expect(json['cover'], 'https://example.com/cover.jpg');
      expect(json['update_time'], '2024-12-19');
      expect(json['score'], 85);
      expect(json['description'], '这是一个测试短剧');
      expect(json['director'], '测试导演');
      expect(json['cast'], '测试演员');
      expect(json['genre'], '爱情');
      expect(json['total_episodes'], 20);
    });

    test('Drama.starRating should calculate star rating correctly', () {
      // Arrange
      final drama1 = Drama(
        id: 1,
        name: '测试短剧1',
        cover: '',
        updateTime: '',
        score: 100, // 满分
      );
      
      final drama2 = Drama(
        id: 2,
        name: '测试短剧2',
        cover: '',
        updateTime: '',
        score: 60, // 3星
      );

      // Act & Assert
      expect(drama1.starRating, 5.0);
      expect(drama2.starRating, 3.0);
    });

    test('Drama.formattedScore should format score correctly', () {
      // Arrange
      final drama = Drama(
        id: 1,
        name: '测试短剧',
        cover: '',
        updateTime: '',
        score: 85,
      );

      // Act & Assert
      expect(drama.formattedScore, '8.5');
    });

    test('Drama boolean properties should work correctly', () {
      // Arrange
      final dramaWithInfo = Drama(
        id: 1,
        name: '测试短剧',
        cover: '',
        updateTime: '',
        score: 85,
        description: '有描述',
        director: '有导演',
        cast: '有演员',
        genre: '有类型',
      );

      final dramaWithoutInfo = Drama(
        id: 2,
        name: '测试短剧2',
        cover: '',
        updateTime: '',
        score: 85,
      );

      // Act & Assert
      expect(dramaWithInfo.hasDescription, true);
      expect(dramaWithInfo.hasDirector, true);
      expect(dramaWithInfo.hasCast, true);
      expect(dramaWithInfo.hasGenre, true);

      expect(dramaWithoutInfo.hasDescription, false);
      expect(dramaWithoutInfo.hasDirector, false);
      expect(dramaWithoutInfo.hasCast, false);
      expect(dramaWithoutInfo.hasGenre, false);
    });

    test('Drama.copyWith should create new instance with updated values', () {
      // Arrange
      final originalDrama = Drama(
        id: 1,
        name: '原始短剧',
        cover: '',
        updateTime: '',
        score: 85,
      );

      // Act
      final updatedDrama = originalDrama.copyWith(
        name: '更新后的短剧',
        score: 90,
      );

      // Assert
      expect(updatedDrama.id, 1); // 保持不变
      expect(updatedDrama.name, '更新后的短剧'); // 已更新
      expect(updatedDrama.score, 90); // 已更新
      expect(updatedDrama.cover, ''); // 保持不变
      expect(updatedDrama.updateTime, ''); // 保持不变
    });

    test('Drama equality should work correctly', () {
      // Arrange
      final drama1 = Drama(
        id: 1,
        name: '测试短剧',
        cover: '',
        updateTime: '',
        score: 85,
      );

      final drama2 = Drama(
        id: 1,
        name: '不同名称',
        cover: '',
        updateTime: '',
        score: 90,
      );

      final drama3 = Drama(
        id: 2,
        name: '测试短剧',
        cover: '',
        updateTime: '',
        score: 85,
      );

      // Act & Assert
      expect(drama1 == drama2, true); // 相同ID，应该相等
      expect(drama1 == drama3, false); // 不同ID，应该不相等
      expect(drama1.hashCode, drama2.hashCode); // 相同ID，hashCode应该相同
    });
  });
}
