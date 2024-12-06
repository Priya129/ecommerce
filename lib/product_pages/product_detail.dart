import 'dart:convert';
import 'package:ecommerce_app_example/product_pages/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/app_colors.dart';

class ProductDetailScreen extends StatelessWidget{
  final Product product;

  ProductDetailScreen({required this.product});

  Future<void> addToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedCart = prefs.getStringList('cart');
    List<Product> currentCart = storedCart != null
    ? storedCart.map((item) => Product.fromJson(jsonDecode(item))).toList()
        : [];

    bool productExits = false;
    for (var cartProduct in currentCart) {
      if(cartProduct.id == product.id){
        productExits = true;
        cartProduct.quantity +=1;
        break;
      }
    }

    if(!productExits){
      product.quantity =1;
      currentCart.add(product);
    }

    List<String> updatedCart =
        currentCart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', updatedCart);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          product.title,
          style: const TextStyle(
            color: AppColors.mainColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  product.image,
                  height: 400,
                ),
              ),
              const SizedBox(height: 25,),
              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8,),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 40, color: Colors.green),
              ),
              const SizedBox(height: 14,),
              const Text(
                "Description",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 6,),
              Text(
                product.description,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                textAlign: TextAlign.justify,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300)
          )
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border:  Border.all(color: AppColors.mainColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: (){
                    addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                        '${product.title} added to the cart!',
                        style: TextStyle(color: Colors.white),
                      ),
                        backgroundColor: Colors.green,
                      )
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined),
                      SizedBox(width: 3,),
                      Text('Add to Cart'),

                    ],
                  ),
                ),

              ),
            ),
            const SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }

}