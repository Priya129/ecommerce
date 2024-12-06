import 'package:ecommerce_app_example/cart_item/cart_page.dart';
import 'package:ecommerce_app_example/product_pages/product_list.dart';
import 'package:ecommerce_app_example/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../global/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages =[
    const ProductListScreen(),
    const CartPage(),
    const ProfileScreen(),

  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
         currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.mainColor,
          backgroundColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: 'Profile',
            )
          ]),
    );
  }
}
