import 'package:flutter/material.dart';
import '../models/meal_category.dart';
import '../services/meal_api_service.dart';
import '../widgets/category_card.dart';
import 'meals_by_category_screen.dart';
import 'meal_detail_screen.dart';
import '../models/meal.dart';

class CategoriesScreen extends StatefulWidget {
  final MealApiService api;

  const CategoriesScreen({super.key, required this.api});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<MealCategory>> _futureCategories;
  List<MealCategory> _allCategories = [];
  List<MealCategory> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureCategories = widget.api.fetchCategories();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  void _load() async {
    final cats = await _futureCategories;
    setState(() {
      _allCategories = cats;
      _filteredCategories = cats;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _openRandomMeal() async {
    try {
      final MealDetail randomMeal = await widget.api.fetchRandomMeal();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(
            api: widget.api,
            initialMeal: randomMeal,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не успеав да вчитам рандом рецепт')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Пребарај категории...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mealify'),
        actions: [
          IconButton(
            tooltip: 'Random рецепт на денот',
            icon: const Icon(Icons.casino),
            onPressed: _openRandomMeal,
          ),
        ],
      ),
      body: FutureBuilder<List<MealCategory>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allCategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _allCategories.isEmpty) {
            return Center(
              child: Text('Грешка при вчитување категории'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = _filteredCategories[index];
                      return CategoryCard(
                        category: cat,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MealsByCategoryScreen(
                                api: widget.api,
                                category: cat,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
