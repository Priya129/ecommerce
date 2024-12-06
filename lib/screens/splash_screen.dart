import 'dart:async';
import 'package:flutter/material.dart';
import '../global/app_colors.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Timer(const Duration(seconds: 5), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget> [
              Image.asset(
                'assets/Images/shopping-cart.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20,),
              FadeTransition(
                  opacity: _animation,
                child: const Text(
                  'eCommerceApp',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}