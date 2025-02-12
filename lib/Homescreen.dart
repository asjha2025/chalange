import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfilePage.dart';
import 'loginscreen.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(ProfilePage(userId: widget.userId));  // Add ProfilePage to list
    _pages.add(Center(child: Text('My Challenges')));
    _pages.add(Center(child: Text('Challenges of the Month')));
    _pages.add(Center(child: Text('Leaderboard')));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Clear login status in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all saved data, including the user ID and login status

    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Make sure you have a LoginScreen for navigation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Log out when the icon is pressed
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'My Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenges of the Month'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Leaderboard'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
