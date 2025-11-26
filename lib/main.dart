import 'package:flutter/material.dart';
import 'services/meal_api_service.dart';
import 'screens/categories_screen.dart';

void main() {
  runApp(const MealifyApp());
}

class MealifyApp extends StatelessWidget {
  const MealifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = MealApiService();

    return MaterialApp(
      title: 'Mealify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF101010),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181818),
          elevation: 0,
        ),
      ),
      home: CategoriesScreen(api: api),
    );
  }
}
