import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../global/app_colors.dart';
import '../global/preferences_manager.dart';
import 'home_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _extractedName;
  List<Map<String, dynamic>> _orders = [];
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _extractNameFromEmail();
      _fetchUserOrders();
      _loadProfileImage();
    }
  }

  void _extractNameFromEmail() {
    if (_user != null && _user!.email != null) {
      final email = _user!.email!;
      _extractedName = email.split('@').first;
    }
  }

  Future<void> _fetchUserOrders() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User is not signed in.');
        return;
      }

      final QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _orders = orderSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', pickedImage.path);
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('profileImagePath');
    if (savedImagePath != null) {
      setState(() {
        _profileImage = File(savedImagePath);
      });
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await PreferencesManager.setSignedIn(false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.mainColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _user == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage, // Trigger image picker when tapped
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider
                        : NetworkImage(
                      _user!.photoURL ??
                          'https://imgs.search.brave.com/YfyNSZIduSszrOd2DIfVpcEZXVPxARydF3-FOuI_1pA/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/dzNzY2hvb2xzLmNv/bS9ob3d0by9pbWdf/YXZhdGFyLnBuZw',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _extractedName ?? 'Name not available',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _user!.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Your Orders:',
              style: TextStyle(
                color: AppColors.mainColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _orders.isEmpty
                  ? const Center(child: Text('No orders available'))
                  : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Image.network(
                          order['image'] ??
                              'https://www.example.com/default-image.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(order['title'] ?? 'No Title'),
                        subtitle: Text(
                            'Price: \$${order['totalPrice']} x${order['quantity']}'),
                        trailing: Text(_formatDate(order['timestamp'])),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
