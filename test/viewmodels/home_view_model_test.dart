import 'package:flutter_test/flutter_test.dart';
import 'package:hajimi_short_video_drama/viewmodels/home_view_model.dart';
import 'package:hajimi_short_video_drama/models/category.dart';

void main() {
  group('HomeViewModel Tests', () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test('initial state should be correct', () {
      // Assert
      expect(viewModel.categories, isEmpty);
      expect(viewModel.recommendDramas, isEmpty);
      expect(viewModel.latestDramas, isEmpty);
      expect(viewModel.hotDramas, isEmpty);
      expect(viewModel.selectedCategoryId, isNull);
      expect(viewModel.isLoading, false);
      expect(viewModel.hasError, false);
      expect(viewModel.hasData, false);
    });

    test('selectCategory should update selectedCategoryId', () {
      // Arrange
      const categoryId = 1;

      // Act
      viewModel.selectCategory(categoryId);

      // Assert
      expect(viewModel.selectedCategoryId, categoryId);
    });

    test('selectCategory with same id should not trigger change', () {
      // Arrange
      const categoryId = 1;
      viewModel.selectCategory(categoryId);
      var changeCount = 0;
      viewModel.addListener(() => changeCount++);

      // Act
      viewModel.selectCategory(categoryId);

      // Assert
      expect(changeCount, 0);
    });

    test('selectCategory with null should clear selection', () {
      // Arrange
      viewModel.selectCategory(1);

      // Act
      viewModel.selectCategory(null);

      // Assert
      expect(viewModel.selectedCategoryId, isNull);
    });

    test('getCategoryName should return correct name', () {
      // Arrange
      final categories = [
        Category(typeId: 1, typeName: '爱情'),
        Category(typeId: 2, typeName: '动作'),
      ];
      
      // 模拟设置分类数据
      viewModel.categories.addAll(categories);

      // Act & Assert
      expect(viewModel.getCategoryName(1), '爱情');
      expect(viewModel.getCategoryName(2), '动作');
      expect(viewModel.getCategoryName(999), '未知分类');
    });

    test('hasData should return true when any data exists', () {
      // Arrange - 初始状态应该没有数据
      expect(viewModel.hasData, false);

      // Act - 添加一些分类数据
      viewModel.categories.add(Category(typeId: 1, typeName: '爱情'));

      // Assert
      expect(viewModel.hasData, true);
    });

    test('isLoadingAny should return true when any loading is active', () {
      // Arrange
      expect(viewModel.isLoadingAny, false);

      // Act - 模拟加载状态
      viewModel.setLoading(true);

      // Assert
      expect(viewModel.isLoadingAny, true);
    });
  });
}
