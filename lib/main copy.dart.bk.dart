import 'package:flutter/material.dart';

void main() {
  runApp(CampusNavigatorApp());
}

class CampusNavigatorApp extends StatelessWidget {
  const CampusNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Navigator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD8B1), // Pastel Orange Background
      appBar: AppBar(
        title: Text('Campus Navigator'),
        centerTitle: true,
        backgroundColor: Colors.orange, // Orange AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () {
              _showNavigationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSearchBar(), // Search Bar

          // Pushes buttons higher
          Expanded(
            flex: 2, // Adjusts spacing above buttons
            child: SizedBox(),
          ),

          // SHED and CUBE Buttons (Moved Higher)
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShedPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: Text(
                    'SHED',
                    style: TextStyle(color: Colors.black), // Changed to black
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: Text(
                    'CUBE',
                    style: TextStyle(color: Colors.black), // Changed to black
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3, // Adjusts spacing below buttons
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}

class ShedPage extends StatelessWidget {
  const ShedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD8B1),
      appBar: AppBar(
        title: Text('SHED'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () {
              _showNavigationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(), // Search Bar

          SizedBox(height: 100),
          Text(
            'Please select the floor:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Column(
            children: [
              _floorButton(context, '0'),
              SizedBox(height: 20),
              _floorButton(context, '1'),
              SizedBox(height: 20),
              _floorButton(context, '5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _floorButton(BuildContext context, String floor) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FloorPage(floorNumber: floor)),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(80, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white, // Matching the style in your screenshot
      ),
      child: Text(
        floor,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}

// Floor Page (Now Also Has Search Bar)
class FloorPage extends StatelessWidget {
  final String floorNumber;
  const FloorPage({super.key, required this.floorNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD8B1),
      appBar: AppBar(
        title: Text('Floor $floorNumber'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () {
              _showNavigationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(), // Search Bar

          SizedBox(height: 20),
          Center(
            child: Text(
              'Welcome to Floor $floorNumber',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Search Bar Widget (Reused on All Pages)
Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Search rooms...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );
}

// Navigation Dialog (Shared Across All Pages)
void _showNavigationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Navigate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'From :',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'To :',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add navigation logic here
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.orangeAccent,
              ),
              child: Text('Navigate'),
            ),
          ],
        ),
      );
    },
  );
}
