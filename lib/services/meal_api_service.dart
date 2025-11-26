import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_category.dart';
import '../models/meal.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;

  MealApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MealCategory>> fetchCategories() async {
    final uri = Uri.parse('$_baseUrl/categories.php');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List categoriesJson = data['categories'] ?? [];

    return categoriesJson
        .map((c) => MealCategory.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final uri = Uri.parse('$_baseUrl/filter.php?c=$category');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load meals');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List mealsJson = data['meals'] ?? [];

    return mealsJson
        .map((m) => MealSummary.fromFilterJson(
              m as Map<String, dynamic>,
              category: category,
            ))
        .toList();
  }

  Future<List<MealSummary>> searchMealsByName(String query) async {
    final uri = Uri.parse('$_baseUrl/search.php?s=$query');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to search meals');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List? mealsJson = data['meals'];

    if (mealsJson == null) return [];

    return mealsJson
        .map((m) => MealSummary.fromSearchJson(m as Map<String, dynamic>))
        .toList();
  }

  // користи го search endpoint + филтрирај по избраната категорија
  Future<List<MealSummary>> searchMealsInCategory(
      String query, String category) async {
    final allMatches = await searchMealsByName(query);
    return allMatches
        .where((m) => m.category?.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load meal detail');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List mealsJson = data['meals'] ?? [];

    if (mealsJson.isEmpty) {
      throw Exception('Meal not found');
    }

    return MealDetail.fromJson(mealsJson.first as Map<String, dynamic>);
  }

  Future<MealDetail> fetchRandomMeal() async {
    final uri = Uri.parse('$_baseUrl/random.php');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load random meal');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final List mealsJson = data['meals'] ?? [];

    if (mealsJson.isEmpty) {
      throw Exception('Random meal not found');
    }

    return MealDetail.fromJson(mealsJson.first as Map<String, dynamic>);
  }
}
