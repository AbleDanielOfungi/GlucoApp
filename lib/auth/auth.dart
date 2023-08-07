import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile management/profile_management.dart';

class SignInSignUpPage extends StatefulWidget {
  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Sign-in successful. You can navigate to the next screen here.
    } catch (e) {
      print('Error during sign in: $e');
      // Handle sign-in errors here.
    }
  }

  Future<void> _signUpWithEmailPassword() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Sign-up successful. You can create a user profile in Firestore here if needed.
      ProfileManagementPage();
    } catch (e) {
      print('Error during sign up: $e');
      // Handle sign-up errors here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In / Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signInWithEmailPassword,
              child: Text('Sign In'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _signUpWithEmailPassword,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignInSignUpPage(),
  ));
}
