import 'dart:convert';
import 'package:ecommerce_app_example/billing/billing_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/app_colors.dart';
import '../product_pages/product.dart';
import '../screens/home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartProducts = [];
  Map<int, int> productQuantities = {};
  Map<int, bool> selectedProducts = {};
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedCart = prefs.getStringList('cart');
    if (storedCart != null) {
      setState(() {
        cartProducts = storedCart
            .map((item) => Product.fromJson(jsonDecode(item)))
            .toList();
        for (var product in cartProducts) {
          productQuantities[product.id] = product.quantity; // Load quantities
          selectedProducts[product.id] = false; // Initialize as unselected
        }
      });
    }
  }

  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedCart =
        cartProducts.map((product) => jsonEncode(product.toJson())).toList();
    await prefs.setStringList('cart', updatedCart);
  }

  double getTotalPrice() {
    double total = 0;
    for (var product in cartProducts) {
      if (selectedProducts[product.id]!) {
        total += product.price * productQuantities[product.id]!;
      }
    }
    return total;
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value!;
      for (var product in cartProducts) {
        selectedProducts[product.id] = selectAll;
      }
    });
  }


  void removeProduct(Product product) {
    setState(() {
      cartProducts.remove(product);
      productQuantities.remove(product.id);
      selectedProducts.remove(product.id);
      _saveCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
              color: AppColors.mainColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.mainColor,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]),
                        child: ListTile(
                          leading: Checkbox(
                            side: const BorderSide(
                                color: AppColors.mainColor, width: 1.0),
                            focusColor: AppColors.mainColor,
                            activeColor: AppColors.mainColor,
                            value: selectedProducts[product.id],
                            onChanged: (value) {
                              setState(() {
                                selectedProducts[product.id] = value!;
                              });
                            },
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.network(
                                product.image,
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        '\$${product.price.toStringAsFixed(2)}')
                                  ],
                                ),
                              )
                            ],
                          ),
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.mainColor, width: 1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: AppColors.mainColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (productQuantities[product.id]! >
                                            1) {
                                          productQuantities[product.id] =
                                              productQuantities[product.id]! -
                                                  1;
                                          product.quantity =
                                              productQuantities[product.id]!;
                                          _saveCartData();
                                        }
                                      });
                                    },
                                    padding: const EdgeInsets.all(0),
                                    iconSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                productQuantities[product.id].toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.mainColor, width: 1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          productQuantities[product.id] =
                                              productQuantities[product.id]! +
                                                  1;
                                          product.quantity =
                                              productQuantities[product.id]!;
                                          _saveCartData();
                                        });
                                      },
                                      padding: const EdgeInsets.all(0),
                                      iconSize: 10,
                                      icon: const Icon(
                                        Icons.add,
                                        color: AppColors.mainColor,
                                      )),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outlined,
                                  color: AppColors.mainColor,
                                ),
                                onPressed: () {
                                  removeProduct(product);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                        side: const BorderSide(
                            color: AppColors.mainColor, width: 1.0),
                        activeColor: AppColors.mainColor,
                        value: selectAll,
                        onChanged: toggleSelectAll),
                    const Text(
                      'Select All',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          final selectedProductList = cartProducts
                              .where((product) =>
                                  selectedProducts[product.id] == true)
                              .toList();

                          final productQuantities = {
                            for (var product in selectedProductList)
                              product.id: product.quantity
                          };

                          if (selectedProductList.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please select at least one product')));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BillingPage(
                                        selectedProducts: selectedProductList,
                                        productQuantities: productQuantities,
                                        totalPrice: getTotalPrice()))).then(
                                (_) {
                              setState(() {
                                cartProducts.removeWhere((product) =>
                                    selectedProducts[product.id] == true);
                                selectedProducts.removeWhere(
                                    (id, selected) => selected == true);

                                productQuantities.removeWhere((id, quantity) =>
                                    selectedProducts.containsKey(id));
                                _saveCartData();
                              });
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor),
                        child: const Text(
                          'Place the Order',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
