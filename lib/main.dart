
import 'package:ecommerce_app_example/product_pages/product.dart';
import 'package:ecommerce_app_example/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'global/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('productBox');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.mainColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.mainColor,
          secondary: AppColors.mainColor
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Firebase Initialization',

      home: const SplashScreen(),
    );
  }
}