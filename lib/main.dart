import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:s_challenge/splash.dart';
import 'package:s_challenge/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBo8VDJxKIGeJ6brbch7VNUiZYiZgmowl0",
      appId: "1:9373226126:android:4855aee1433b0d192625df",
      messagingSenderId: "your-messaging-sesssssnder-id",
      projectId: "schallenge2025-6f525",
      storageBucket: "schallenge2025-6f525.firebasestorage.app",
    ),
  );// رط قواعد البيانات
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sustainability Challenge',
      theme: AppTheme.lightTheme,

      home: SplashScreen(),
    );
  }
}

