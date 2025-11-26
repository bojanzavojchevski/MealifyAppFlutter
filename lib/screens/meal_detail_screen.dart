import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import '../widgets/section_title.dart';

class MealDetailScreen extends StatefulWidget {
  final MealApiService api;
  final String? mealId;
  final MealDetail? initialMeal;

  const MealDetailScreen({
    super.key,
    required this.api,
    this.mealId,
    this.initialMeal,
  }) : assert(mealId != null || initialMeal != null,
            'Either mealId or initialMeal must be provided');

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Future<MealDetail> _futureMeal;

  @override
  void initState() {
    super.initState();
    if (widget.initialMeal != null) {
      _futureMeal = Future.value(widget.initialMeal);
    } else {
      _futureMeal = widget.api.fetchMealDetail(widget.mealId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали за рецепт'),
      ),
      body: FutureBuilder<MealDetail>(
        future: _futureMeal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Грешка при вчитување рецепт'));
          }

          final meal = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    meal.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (meal.category != null)
                            Chip(
                              label: Text(meal.category!),
                            ),
                          if (meal.area != null)
                            Chip(
                              label: Text(meal.area!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle('Состојки'),
                      ...meal.ingredients.map(
                        (ing) => Text(
                          '• ${ing.name} (${ing.measure})',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle('Инструкции'),
                      Text(
                        meal.instructions,
                        textAlign: TextAlign.justify,
                      ),
                      if (meal.youtubeUrl != null &&
                          meal.youtubeUrl!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const SectionTitle('YouTube линк'),
                        SelectableText(
                          meal.youtubeUrl!,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ],
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
