class MealCategory {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String description;

  MealCategory({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbnailUrl: json['strCategoryThumb'] ?? '',
      description: json['strCategoryDescription'] ?? '',
    );
  }
}
