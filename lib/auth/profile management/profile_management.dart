import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileManagementPage extends StatefulWidget {
  @override
  _ProfileManagementPageState createState() => _ProfileManagementPageState();
}

class _ProfileManagementPageState extends State<ProfileManagementPage> {
  final TextEditingController _displayNameController = TextEditingController();

  void _updateUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        String displayName = _displayNameController.text.trim();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'displayName': displayName,
        });

        // Profile update successful. You can show a success message here.
      }
    } catch (e) {
      print('Error updating user profile: $e');
      // Handle profile update errors here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

