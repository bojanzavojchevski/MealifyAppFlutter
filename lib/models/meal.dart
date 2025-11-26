class MealSummary {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String? category;

  MealSummary({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    this.category,
  });

  factory MealSummary.fromFilterJson(Map<String, dynamic> json, {String? category}) {
    // filter.php нема категорија, па рачно ја задаваме
    return MealSummary(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      category: category,
    );
  }

  factory MealSummary.fromSearchJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      category: json['strCategory'],
    );
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({
    required this.name,
    required this.measure,
  });
}

class MealDetail {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String instructions;
  final String? youtubeUrl;
  final String? area;
  final String? category;
  final List<Ingredient> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.instructions,
    this.youtubeUrl,
    this.area,
    this.category,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final List<Ingredient> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'];
      final meas = json['strMeasure$i'];

      if (ing != null &&
          ing.toString().trim().isNotEmpty) {
        ingredients.add(
          Ingredient(
            name: ing.toString(),
            measure: (meas ?? '').toString(),
          ),
        );
      }
    }

    return MealDetail(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      youtubeUrl: json['strYoutube'],
      area: json['strArea'],
      category: json['strCategory'],
      ingredients: ingredients,
    );
  }
}
