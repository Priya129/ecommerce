import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final ImageProvider image;
  final String label;
  final VoidCallback onTap;

  CategoryItem({required this.image, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
