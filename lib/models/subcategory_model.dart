class SubCategory {
  final String id;
  final String categoryId;
  final String name;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
    };
  }

  factory SubCategory.fromMap(Map<String, dynamic> map, String docId) {
    return SubCategory(
      id: docId,
      categoryId: map['categoryId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}
