import 'package:flutter_test/flutter_test.dart';
import 'package:hajimi_short_video_drama/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Category.fromJson should create Category object correctly', () {
      // Arrange
      final json = {
        'type_id': 1,
        'type_name': '爱情',
      };

      // Act
      final category = Category.fromJson(json);

      // Assert
      expect(category.typeId, 1);
      expect(category.typeName, '爱情');
    });

    test('Category.fromJson should handle missing fields', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final category = Category.fromJson(json);

      // Assert
      expect(category.typeId, 0);
      expect(category.typeName, '');
    });

    test('Category.toJson should convert Category object to JSON correctly', () {
      // Arrange
      final category = Category(
        typeId: 1,
        typeName: '爱情',
      );

      // Act
      final json = category.toJson();

      // Assert
      expect(json['type_id'], 1);
      expect(json['type_name'], '爱情');
    });

    test('Category.copyWith should create new instance with updated values', () {
      // Arrange
      final originalCategory = Category(
        typeId: 1,
        typeName: '爱情',
      );

      // Act
      final updatedCategory = originalCategory.copyWith(
        typeName: '动作',
      );

      // Assert
      expect(updatedCategory.typeId, 1); // 保持不变
      expect(updatedCategory.typeName, '动作'); // 已更新
    });

    test('Category equality should work correctly', () {
      // Arrange
      final category1 = Category(
        typeId: 1,
        typeName: '爱情',
      );

      final category2 = Category(
        typeId: 1,
        typeName: '爱情',
      );

      final category3 = Category(
        typeId: 2,
        typeName: '爱情',
      );

      final category4 = Category(
        typeId: 1,
        typeName: '动作',
      );

      // Act & Assert
      expect(category1 == category2, true); // 完全相同
      expect(category1 == category3, false); // 不同ID
      expect(category1 == category4, false); // 不同名称
      expect(category1.hashCode, category2.hashCode); // 相同对象，hashCode应该相同
    });

    test('Category toString should return correct string representation', () {
      // Arrange
      final category = Category(
        typeId: 1,
        typeName: '爱情',
      );

      // Act
      final stringRepresentation = category.toString();

      // Assert
      expect(stringRepresentation, 'Category(typeId: 1, typeName: 爱情)');
    });
  });
}
