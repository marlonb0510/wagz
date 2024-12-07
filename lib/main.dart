import 'package:flutter/material.dart';
import 'pages/help_page.dart';
import 'pages/home_page.dart';
import 'pages/calendar_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'Wagz', // App name is Wagz
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color to blue
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Title color is white for contrast
          ),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Wagz',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Title color
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700, // Soft blue for the AppBar background
          bottom: TabBar(
            indicatorColor: Colors.white, // Indicator color set to white for contrast
            indicatorWeight: 4.0, // Slightly thicker indicator for better visibility
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.white70, // Unselected tabs have a faded color
            tabs: [
              Tab(
                icon: Icon(Icons.help, color: Colors.white),
                text: 'Help',
              ),
              Tab(
                icon: Icon(Icons.home, color: Colors.white),
                text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.calendar_today, color: Colors.white),
                text: 'Calendar',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Help tab background with soft baby blue color
            Container(
              color: Colors.blue.shade100, // Baby blue for the Help tab background
              child: HelpPage(),
            ),
            // Home tab background with a softer blue color
            Container(
              color: Colors.blue.shade200, // Light blue for the Home tab background
              child: HomePage(),
            ),
            // Calendar tab background with an even lighter blue color
            Container(
              color: Colors.blue.shade300, // Even lighter blue for the Calendar tab background
              child: CalendarPage(),
            ),
          ],
        ),
      ),
    );
  }
}
