import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s_challenge/registerscreen.dart';
import 'Homescreen.dart';  // Import HomePage
import 'themes.dart'; // Import the AppTheme class
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences package

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoggingIn = true);
      try {
        // Sign in the user using Firebase Auth
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password
        );

        // Save login status in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userCredential.user!.uid);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful!")));

        // Pass the user ID (UID) to the HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: userCredential.user!.uid),  // Pass the UID here
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Login failed!";
        if (e.code == 'user-not-found') {
          errorMessage = "No account found for this email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  Future<void> resetPassword() async {
    if (email.isNotEmpty && email.contains("@")) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset email sent!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sending reset email.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a valid email first!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor, // Primary color from AppTheme
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(child: Text("Login", textAlign: TextAlign.center)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Responsive Logo
              Container(
                height: MediaQuery.of(context).size.height * 0.25, // 25% of screen height
                child: Image.asset('assets/s_challengepng.png', fit: BoxFit.contain),
              ),
              SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppTheme.secondaryColor.withOpacity(0.1), // Light Blue background from AppTheme
                      ),
                      onChanged: (value) => email = value,
                      validator: (value) => value!.contains("@") ? null : "Enter a valid email",
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppTheme.secondaryColor.withOpacity(0.1), // Light Blue background from AppTheme
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      onChanged: (value) => password = value,
                      validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resetPassword,
                        child: Text("Forgot Password?", style: TextStyle(color: AppTheme.primaryColor)), // Primary color from AppTheme
                      ),
                    ),
                    SizedBox(height: 20),

                    _isLoggingIn
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor, // Primary color from AppTheme
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Login", style: TextStyle(fontSize: 18,color: Colors.white)),
                    ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          ),
                          child: Text("Sign Up", style: TextStyle(color: AppTheme.accentColor)), // Accent color from AppTheme
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
