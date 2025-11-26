import 'package:flutter/material.dart';
import '../models/meal_category.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_grid_item.dart';
import 'meal_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final MealApiService api;
  final MealCategory category;

  const MealsByCategoryScreen({
    super.key,
    required this.api,
    required this.category,
  });

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  List<MealSummary> _meals = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
    });
    try {
      final items =
          await widget.api.fetchMealsByCategory(widget.category.name);
      if (!mounted) return;
      setState(() {
        _meals = items;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Грешка при вчитување јадења')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchMeals(String query) async {
    if (query.trim().isEmpty) {
      _loadMeals();
      return;
    }
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });
    try {
      final items = await widget.api
          .searchMealsInCategory(query.trim(), widget.category.name);
      if (!mounted) return;
      setState(() {
        _meals = items;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Грешка при пребарување')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    _searchMeals(text);
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
        hintText: 'Пребарување во ${widget.category.name}...',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_meals.isEmpty)
              const Expanded(
                child: Center(child: Text('Нема резултати')),
              )
            else
              Expanded(
                child: GridView.builder(
                  itemCount: _meals.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return MealGridItem(
                      meal: meal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(
                              api: widget.api,
                              mealId: meal.id,
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
      ),
    );
  }
}
