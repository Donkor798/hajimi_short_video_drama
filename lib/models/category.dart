/// 分类模型
class Category {
  final int typeId;
  final String typeName;

  Category({
    required this.typeId,
    required this.typeName,
  });

  /// 从JSON创建Category对象
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      typeId: json['type_id'] as int? ?? 0,
      typeName: json['type_name'] as String? ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type_id': typeId,
      'type_name': typeName,
    };
  }

  /// 复制对象
  Category copyWith({
    int? typeId,
    String? typeName,
  }) {
    return Category(
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.typeId == typeId &&
        other.typeName == typeName;
  }

  @override
  int get hashCode {
    return typeId.hashCode ^ typeName.hashCode;
  }

  @override
  String toString() {
    return 'Category(typeId: $typeId, typeName: $typeName)';
  }
}
