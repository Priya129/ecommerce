import 'package:ecommerce_app_example/auth/signup_page.dart';
import 'package:ecommerce_app_example/global/preferences_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const  SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
         title: const Text(
           "Sign In",
           style: TextStyle(
             color: AppColors.mainColor,
             fontSize: 20,
             fontWeight: FontWeight.bold
           ),
         ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon:const Icon(Icons.arrow_back, color: AppColors.mainColor,)
        ),
     ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.mainColor)
                )
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16,),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.mainColor)
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off
                  ),
                  onPressed: (){
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              ),
            ),
            const SizedBox(height: 24,),
            _isLoading
            ? const CircularProgressIndicator()
                : ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )

                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ) ),
            const SizedBox(height: 16,),
            TextButton(
              onPressed: (){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()));
              },
              child: const Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(
                  color: AppColors.mainColor,
                  fontSize: 18
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await PreferencesManager.setSignedIn(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in successful!")));
      Navigator.pop(context);
     /* Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductListScreen()));*/
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Error: ${e.toString()}")));

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}