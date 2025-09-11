import 'package:flutter/material.dart';


/// 分类标签组件
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? 20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 可滚动的分类标签列表
class CategoryChipList extends StatelessWidget {
  final List<String> categories;
  final int? selectedIndex;
  final Function(int index)? onCategorySelected;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const CategoryChipList({
    super.key,
    required this.categories,
    this.selectedIndex,
    this.onCategorySelected,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1 ? 8 : 0,
            ),
            child: CategoryChip(
              label: categories[index],
              isSelected: isSelected,
              onTap: () => onCategorySelected?.call(index),
            ),
          );
        },
      ),
    );
  }
}

/// 网格布局的分类标签
class CategoryChipGrid extends StatelessWidget {
  final List<String> categories;
  final List<int>? selectedIndices;
  final Function(int index)? onCategorySelected;
  final int crossAxisCount;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const CategoryChipGrid({
    super.key,
    required this.categories,
    this.selectedIndices,
    this.onCategorySelected,
    this.crossAxisCount = 3,
    this.childAspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 3.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final isSelected = selectedIndices?.contains(index) ?? false;
        
        return CategoryChip(
          label: categories[index],
          isSelected: isSelected,
          onTap: () => onCategorySelected?.call(index),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      },
    );
  }
}
