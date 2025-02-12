import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s_challenge/themes.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isEditingPassword = false;

  // Method to handle password update
  Future<void> _updatePassword() async {
    try {
      String newPassword = _passwordController.text;
      User? user = FirebaseAuth.instance.currentUser;

      if (newPassword.isNotEmpty) {
        await user!.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
        setState(() {
          _isEditingPassword = false; // Hide password field after update
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password cannot be empty')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('User data not found.'));
        }

        var userData = snapshot.data!;
        String userName = userData['name'] ?? 'No name available';
        String userEmail = user!.email ?? 'No email available';

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Name: $userName',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Email: $userEmail',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 30),
                    // Password Update Section
                    _isEditingPassword
                        ? Column(
                      children: [
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            labelStyle: TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Update Password', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    )
                        :   ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingPassword = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor, // Primary color from AppTheme
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Change password", style: TextStyle(fontSize: 18,color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
