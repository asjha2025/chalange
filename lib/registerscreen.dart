import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s_challenge/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Homescreen.dart';
import 'loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String email = "";
  String password = "";
  bool _isRegistering = false;
  bool _isPasswordVisible = false;

  Future<void> registerUser(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isRegistering = true);  // Start the loading indicator
      try {
        // Check if the email is already in use
        var existingUser = await _auth.fetchSignInMethodsForEmail(email);
        if (existingUser.isNotEmpty) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Email already in use.")));
          setState(() => _isRegistering = false);  // Stop loading indicator
          return;
        }

        // Create the new user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
        });

        // Store login status and user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);  // Mark the user as logged in
        await prefs.setString('userId', userCredential.user!.uid);

        // Show success message
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Registration Successful!")));

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: userCredential.user!.uid),  // Pass the UID here
          ),
        );
      } catch (e) {
        String errorMessage = "Registration failed: ";
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              errorMessage += "Weak password.";
              break;
            case 'email-already-in-use':
              errorMessage += "Email already in use.";
              break;
            default:
              errorMessage += "Unknown error occurred.";
          }
        } else {
          errorMessage += e.toString();
        }
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        setState(() => _isRegistering = false);  // Stop loading indicator
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor, // Primary color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(child: Text("Register", textAlign: TextAlign.center)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.25, // Responsive Logo
                child: Image.asset('assets/s_challengepng.png', fit: BoxFit.contain),
              ),
              SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppTheme.secondaryColor.withOpacity(0.1), // Light Blue background
                      ),
                      onChanged: (value) => name = value,
                      validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppTheme.secondaryColor.withOpacity(0.1), // Light Blue background
                      ),
                      onChanged: (value) => email = value,
                      validator: (value) => value!.contains("@") ? null : "Please enter a valid email",
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppTheme.secondaryColor.withOpacity(0.1), // Light Blue background
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      onChanged: (value) => password = value,
                      validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    SizedBox(height: 20),

                    _isRegistering
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () => registerUser(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor, // Primary color
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          ),
                          child: Text("Login", style: TextStyle(color: AppTheme.accentColor)), // Accent color
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
