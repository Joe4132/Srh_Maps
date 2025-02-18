import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart'; // For hashing the map file

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
        // Navigate to the MapScreen when a floor is selected
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
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

// Map Navigation Components (Copied from the original file)

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ValueNotifier<String> selectedRoomNotifier = ValueNotifier('Room 1');
  List<String> rooms = [];
  ui.Image? mapImage;
  ui.Image? mapViewImage;
  Offset? startPoint;
  List<Offset> roomPositions = [];
  final TransformationController _transformationController = TransformationController();
  List<Offset> roadPixels = [];
  Size? screenSize;

  // Map to store precomputed paths
  final Map<String, List<Offset>> precomputedPaths = {};

  @override
  void initState() {
    super.initState();
    _initializePaths();
  }

  void _initializePaths() async {
    // Check if the points-paths.json file exists in assets
    final pointsPathsExist = await _checkIfPointsPathsExistInAssets();

    if (pointsPathsExist) {
      // Load data from assets/points-paths.json
      final loadedData = await loadPointsPathsFromAssets();
      if (loadedData != null) {
        setState(() {
          startPoint = loadedData['startPoint'];
          roomPositions = loadedData['roomPositions'];
          roadPixels = loadedData['roadPixels'];
          precomputedPaths.addAll(loadedData['precomputedPaths']);
          rooms = List.generate(roomPositions.length, (index) => 'Room ${index + 1}');
        });

        // Debug logs
        print('Data loaded from assets/points-paths.json:');
        print('Start Point: $startPoint');
        print('Room Positions: $roomPositions');
        print('Road Pixels: $roadPixels');
        print('Precomputed Paths: $precomputedPaths');

        _loadImagesByLoadedFile();
        return;
      }
    }

    // If the file does not exist in assets, proceed with the original logic
    final mapChanged = await hasMapFileChanged();

    if (!mapChanged) {
      final loadedData = await loadPointsPathsFromFile();
      if (loadedData != null) {
        setState(() {
          startPoint = loadedData['startPoint'];
          roomPositions = loadedData['roomPositions'];
          roadPixels = loadedData['roadPixels'];
          precomputedPaths.addAll(loadedData['precomputedPaths']);
          rooms = List.generate(roomPositions.length, (index) => 'Room ${index + 1}');
        });

        // Debug logs
        print('Data loaded from file:');
        print('Start Point: $startPoint');
        print('Room Positions: $roomPositions');
        print('Road Pixels: $roadPixels');
        print('Precomputed Paths: $precomputedPaths');

        _loadImagesByLoadedFile();
        return;
      }
    }

    // If the map has changed or no paths file exists, recalculate paths
    print('Recalculating paths...');
    _loadImages();
  }

  Future<bool> _checkIfPointsPathsExistInAssets() async {
    try {
      // Try to load the file from assets
      await rootBundle.load('assets/points-paths.json');
      return true; // File exists
    } catch (e) {
      print('File assets/points-paths.json does not exist: $e');
      return false; // File does not exist
    }
  }

  Future<Map<String, dynamic>?> loadPointsPathsFromAssets() async {
    try {
      // Load the file from assets
      final jsonString = await rootBundle.loadString('assets/points-paths.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Debug logs
      print('File loaded successfully from assets:');
      print('Start Point: ${jsonData['startPoint']}');
      print('Room Positions: ${jsonData['roomPositions']}');
      print('Road Pixels: ${jsonData['roadPixels']}');
      print('Precomputed Paths: ${jsonData['precomputedPaths']}');

      // Convert JSON back to data
      final startPoint = Offset(jsonData['startPoint']['dx'], jsonData['startPoint']['dy']);
      final roomPositions = (jsonData['roomPositions'] as List).map((offset) => Offset(offset['dx'], offset['dy'])).toList();
      final roadPixels = (jsonData['roadPixels'] as List).map((offset) => Offset(offset['dx'], offset['dy'])).toList();
      final precomputedPaths = (jsonData['precomputedPaths'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as List).map((offset) => Offset(offset['dx'], offset['dy'])).toList()));

      return {
        'startPoint': startPoint,
        'roomPositions': roomPositions,
        'roadPixels': roadPixels,
        'precomputedPaths': precomputedPaths,
      };
    } catch (e) {
      print('Error loading points and paths from assets: $e');
      return null;
    }
  }

  void _loadImagesByLoadedFile() async {
    try {
      final image = await loadImage('assets/map.png');
      final viewImage = await loadImage('assets/map-view.png');
      setState(() {
        mapImage = image;
        mapViewImage = viewImage;
      });

      // Debug logs
      print('Map images loaded successfully:');
      print('mapImage: $mapImage');
      print('mapViewImage: $mapViewImage');
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  void _loadImages() async {
    try {
      final image = await loadImage('assets/map.png');
      final viewImage = await loadImage('assets/map-view.png');
      setState(() {
        mapImage = image;
        mapViewImage = viewImage;
      });

      // Debug logs
      print('Map images loaded successfully:');
      print('mapImage: $mapImage');
      print('mapViewImage: $mapViewImage');

      _detectPoints(image);
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _detectPoints(ui.Image image) async {
    final byteData = await image.toByteData();
    if (byteData == null) {
      print('Failed to get pixel data from the image.');
      return;
    }

    final pixels = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    // Debug logs
    print('Detecting points...');
    print('Image width: $width, height: $height');

    // Define the start point color (#692020) in ARGB format
    const startPointColor1 = 0xFF692020; // Dark red color
    const startPointColor2 = 0xFF0000ff; // Blue color
    const startPointColor3 = 0xFF00ffff; // Cyan color
    const startPointColor4 = 0xFFffff00; // Yellow color

    // Define the room point color (#00ff00) in ARGB format
    const roomPointColor = 0xFF00FF00; // Green color

    // Define the road color (#ff00ff) in ARGB format
    const roadColor = 0xFFFF00FF; // Magenta color

    // Scan the image for the start point, room pixels, and road pixels
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixelOffset = (y * width + x) * 4;
        final a = pixels[pixelOffset + 3];
        final r = pixels[pixelOffset + 2];
        final g = pixels[pixelOffset + 1];
        final b = pixels[pixelOffset + 0];
        final pixelColor = (a << 24) | (r << 16) | (g << 8) | b;

        if ((pixelColor == startPointColor1 || pixelColor == startPointColor2 || pixelColor == startPointColor3 || pixelColor == startPointColor4) && startPoint == null) {
          // Start point pixel found
          setState(() {
            startPoint = Offset(x.toDouble(), y.toDouble());
            roadPixels.add(Offset(x.toDouble(), y.toDouble())); // Add start point to roadPixels
          });
          print('Start point detected at: ($x, $y)');
        } else if (pixelColor == roomPointColor) {
          // Room pixel found
          setState(() {
            roomPositions.add(Offset(x.toDouble(), y.toDouble()));
            rooms.add('Room ${roomPositions.length}'); // Add room to the list
            roadPixels.add(Offset(x.toDouble(), y.toDouble())); // Add room position to roadPixels
          });
          print('Room detected at: ($x, $y)');
        } else if (pixelColor == roadColor) {
          // Road pixel found
          setState(() {
            roadPixels.add(Offset(x.toDouble(), y.toDouble()));
          });
        }
      }
    }

    if (startPoint == null) {
      print('No start point pixel found in the image.');
    }
    if (roomPositions.isEmpty) {
      print('No room pixels found in the image.');
    }
    if (roadPixels.isEmpty) {
      print('No road pixels found in the image.');
    }

    // Precompute paths for all rooms
    _precomputePaths();
  }

  void _precomputePaths() async {
    if (startPoint == null || roomPositions.isEmpty) return;

    for (var i = 0; i < roomPositions.length; i++) {
      final roomName = 'Room ${i + 1}';
      final path = _findPath(startPoint!, roomPositions[i]);
      precomputedPaths[roomName] = path;
    }

    print('Precomputed paths for all rooms.');
    await savePointsPathsToFile(); // Save all data to file
  }

  List<Offset> _findPath(Offset start, Offset end) {
    if (roadPixels.isEmpty) {
      print('Road pixels are not detected or empty.');
      return [];
    }

    // Check if the start and end points are on the road
    if (!roadPixels.contains(start)) {
      print('Start point is not on the road.');
      return [];
    }
    if (!roadPixels.contains(end)) {
      print('End point is not on the road.');
      return [];
    }

    // If start and end points are the same, return the start point
    if (start == end) {
      return [start];
    }

    final queue = Queue<Offset>();
    final visited = <Offset, Offset>{};
    queue.add(start);
    visited[start] = start;

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == end) {
        break;
      }

      final neighbors = [
        Offset(current.dx + 1, current.dy),
        Offset(current.dx - 1, current.dy),
        Offset(current.dx, current.dy + 1),
        Offset(current.dx, current.dy - 1),
      ];

      for (final neighbor in neighbors) {
        if (roadPixels.contains(neighbor) && !visited.containsKey(neighbor)) {
          visited[neighbor] = current;
          queue.add(neighbor);
          print('Visited: $neighbor, Parent: $current');
        }
      }
    }

    // Reconstruct the path
    final path = <Offset>[];
    Offset? current = end;
    while (current != start) {
      if (current == null || !visited.containsKey(current)) {
        print('Path reconstruction failed: current is null or not in visited map.');
        return [];
      }
      path.add(current);
      current = visited[current];
    }
    path.add(start);
    return path.reversed.toList();
  }

  Future<void> savePointsPathsToFile() async {
    try {
      // Convert all data to JSON
      final Map<String, dynamic> jsonData = {
        'startPoint': {'dx': startPoint!.dx, 'dy': startPoint!.dy},
        'roomPositions': roomPositions.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList(),
        'roadPixels': roadPixels.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList(),
        'precomputedPaths': precomputedPaths.map((key, value) => MapEntry(key, value.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList())),
      };

      // Get the app's local directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/points-paths.json');

      // Write JSON to file
      await file.writeAsString(jsonEncode(jsonData));
      print('Points and paths saved to file: ${file.path}');
    } catch (e) {
      print('Error saving points and paths to file: $e');
    }
  }

  Future<Map<String, dynamic>?> loadPointsPathsFromFile() async {
    try {
      // Get the app's local directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/points-paths.json');

      if (await file.exists()) {
        // Read JSON from file
        final jsonString = await file.readAsString();
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        // Debug logs
        print('File loaded successfully: ${file.path}');
        print('Start Point: ${jsonData['startPoint']}');
        print('Room Positions: ${jsonData['roomPositions']}');
        print('Road Pixels: ${jsonData['roadPixels']}');
        print('Precomputed Paths: ${jsonData['precomputedPaths']}');

        // Convert JSON back to data
        final startPoint = Offset(jsonData['startPoint']['dx'], jsonData['startPoint']['dy']);
        final roomPositions = (jsonData['roomPositions'] as List).map((offset) => Offset(offset['dx'], offset['dy'])).toList();
        final roadPixels = (jsonData['roadPixels'] as List).map((offset) => Offset(offset['dx'], offset['dy'])).toList();
        final precomputedPaths = (jsonData['precomputedPaths'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as List).map((offset) => Offset(offset['dx'], offset['dy'])).toList()));

        return {
          'startPoint': startPoint,
          'roomPositions': roomPositions,
          'roadPixels': roadPixels,
          'precomputedPaths': precomputedPaths,
        };
      } else {
        print('No points-paths file found.');
        return null;
      }
    } catch (e) {
      print('Error loading points and paths from file: $e');
      return null;
    }
  }

  Future<String> calculateFileHash(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    return sha256.convert(bytes).toString();
  }

  Future<bool> hasMapFileChanged() async {
    final directory = await getApplicationDocumentsDirectory();
    final hashFile = File('${directory.path}/map_hash.txt');

    final currentHash = await calculateFileHash('assets/map.png');

    if (await hashFile.exists()) {
      final savedHash = await hashFile.readAsString();
      if (savedHash == currentHash) {
        print('Map file has not changed.');
        return false;
      }
    }

    // Save the new hash
    await hashFile.writeAsString(currentHash);
    print('Map file has changed. New hash saved.');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text('Map Navigation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder<String>(
              valueListenable: selectedRoomNotifier,
              builder: (context, selectedRoom, _) {
                return DropdownButton<String>(
                  value: selectedRoom,
                  onChanged: (String? newValue) {
                    selectedRoomNotifier.value = newValue!;
                  },
                  items: rooms.map((room) {
                    return DropdownMenuItem(value: room, child: Text(room));
                  }).toList(),
                );
              },
            ),
          ),
          Expanded(
            child: mapViewImage == null
                ? Center(child: CircularProgressIndicator())
                : InteractiveViewer(
              boundaryMargin: EdgeInsets.all(double.infinity), // Allow panning beyond the edges
              minScale: 0.1,
              maxScale: 4.0,
              transformationController: _transformationController,
              child: SizedBox(
                width: mapViewImage!.width.toDouble(),
                height: mapViewImage!.height.toDouble(),
                child: ValueListenableBuilder<String>(
                  valueListenable: selectedRoomNotifier,
                  builder: (context, selectedRoom, _) {
                    final path = precomputedPaths[selectedRoom] ?? [];
                    print('Selected Room: $selectedRoom, Path: $path'); // Debug log
                    return CustomPaint(
                      size: Size(mapViewImage!.width.toDouble(), mapViewImage!.height.toDouble()),
                      painter: MapPainter(selectedRoom, mapViewImage!, startPoint, roomPositions, path),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final String selectedRoom;
  final ui.Image mapViewImage;
  final Offset? startPoint;
  final List<Offset> roomPositions;
  final List<Offset> path;

  MapPainter(this.selectedRoom, this.mapViewImage, this.startPoint, this.roomPositions, this.path) {
    print('Path for $selectedRoom: $path'); // Debug log
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImage(mapViewImage, Offset.zero, paint); // Draw the map-view image

    if (startPoint != null) {
      paint.color = Color(0xFF692020);
      canvas.drawCircle(startPoint!, 10, paint);
    }

    paint.color = Color(0xFF00FF00);
    for (var roomPosition in roomPositions) {
      canvas.drawRect(Rect.fromCenter(center: roomPosition, width: 0, height: 0), paint);
    }

    if (path.isNotEmpty) {
      paint.color = Colors.red;
      paint.style =  PaintingStyle.stroke;
      paint.strokeWidth = 10;

      for (var i = 0; i < path.length - 1; i++) {
        canvas.drawLine(path[i], path[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // Always repaint
}