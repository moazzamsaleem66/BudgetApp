import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/shop/presentation/pages/home_page.dart';

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lifestyle Shop',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
