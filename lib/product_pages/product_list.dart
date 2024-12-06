import 'dart:convert';
import 'package:ecommerce_app_example/cart_item/category_item.dart';
import 'package:ecommerce_app_example/product_pages/product.dart';
import 'package:ecommerce_app_example/product_pages/product_card.dart';
import 'package:ecommerce_app_example/product_pages/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../global/app_colors.dart';

final productBoxProvider = Provider<Box<Product>>((ref) {
  return Hive.box<Product>('productBox');
});

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late Future<List<Product>> _products;
  String _selectedCategory = 'all';
  TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'all', 'image': const AssetImage('assets/Images/product.png')},
    {
      'name': 'electronics',
      'image': const AssetImage('assets/Images/electronics.png')
    },
    {
      'name': 'jewelery',
      'image': const AssetImage('assets/Images/jwellery.png')
    },
    {
      'name': 'men\'s clothing',
      'image': const AssetImage('assets/Images/mens.png')
    },
    {
      'name': 'women\'s clothing',
      'image': const AssetImage('assets/Images/woman.png')
    },
    {'name': 'books', 'image': const AssetImage('assets/Images/book.png')},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndStoreProducts('all');
  }

  Future<List<Product>> fetchProducts({String? category}) async {
    final url = category == 'all'
        ? 'http://192.168.1.11:5000/products'  // Update this to the correct API URL if needed
        : 'http://192.168.1.11:5000/products/category/$category';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Product> products =
          data.map((json) => Product.fromJson(json)).toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _fetchAndStoreProducts(String category) async {
    setState(() {
      _isLoading = true;
    });

    List<Product> products = await fetchProducts(category: category);
    final box = ref.read(productBoxProvider);

    if (products.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    await box.clear();
    for (var product in products) {
      box.put(product.id, product);
    }

    setState(() {
      _allProducts = products;
      _filteredProducts = _allProducts;
      _isLoading = false;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
                product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Build shimmer placeholder
  Widget _buildShimmerProductGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
      delegate: SliverChildBuilderDelegate((context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.white,
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        );
      }, childCount: 6),
    );
  }

  Widget _buildProductGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product)));
            });
      }, childCount: _filteredProducts.length),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final category = _categories[index]['name'];
          final image = _categories[index]['image'];
          final isSelected = category == _selectedCategory;
          return CategoryItem(
              image: image,
              label: category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _fetchAndStoreProducts(category);
                });
              });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
              color: AppColors.mainColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: "Find what you need...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.mainColor,
                              width: 0.5,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.mainColor,
                          )),
                      cursorColor: AppColors.mainColor,
                      onChanged: (value) {
                        _filterProducts(value);
                      },
                    ),
                  ),
                  _buildCategoryList(),
                ],
              ),
            ),
            _isLoading ? _buildShimmerProductGrid() : _buildProductGrid()
          ],
        ),
      ),
    );
  }
}
