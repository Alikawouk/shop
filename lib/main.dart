import 'package:flutter/material.dart';
import 'package:shop/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 146, 230, 247),
          surface: const Color.fromARGB(255, 44, 50, 60),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 49, 57, 59),
        useMaterial3: true,
      ),
      home: const GroceryList(),
    );
  }
}
