import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app_example/product_pages/product.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function() onTap;

  ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child:
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Hero(
                    tag: product.id,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          children: [
                            product.image.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.fitHeight
                            )
                                : const Placeholder(
                              fallbackHeight: 120,
                              fallbackWidth: double.infinity,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if(product.rating != null) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 16.0),
                    const SizedBox(width: 4.0,),
                    Text(
                      product.rating!.rate.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8.0,),
                    Text(
                      '(${product.rating!.count} reviews)',
                      style: const TextStyle(color: Colors.grey),
                    )
                  ]
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                product.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 18),),
            ),
            const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}