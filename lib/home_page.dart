// File: lib/home_page.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'review_page.dart';
import 'settings_provider.dart';
import 'classifier_page.dart';
import 'tflite_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  File? image;
  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      image = File(pickedFile.path);
    });

    if (!mounted) return;
    _showClassificationDialog(pickedFile.path);
  }

  void _showClassificationDialog(String imagePath) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Classify Image?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(imagePath), height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            const Text("Do you want to classify this image?"),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              await TFLiteHelper.loadModel();
              final results = await TFLiteHelper.classifyImage(File(imagePath));
              TFLiteHelper.dispose();
              await _saveImage(imagePath);

              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    results.isNotEmpty
                        ? "Classified as: ${results.first.label} (${(results.first.score * 100).toStringAsFixed(1)}%)"
                        : "Classification failed.",
                  ),
                ),
              );
            },
            isDefaultAction: true,
            child: const Text("Classify"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> images = prefs.getStringList('uploaded_images') ?? [];
    String dateTaken = DateTime.now().toString();
    images.add(jsonEncode({'image': imagePath, 'classified': false, 'date': dateTaken}));
    await prefs.setStringList('uploaded_images', images);
  }

  void _openLeafScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ClassifierPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(settings),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: settings.isDarkMode
              ? const LinearGradient(
                  colors: [Colors.black87, Colors.black54],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFFFFEB3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomePage(),
            const ReviewPage(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        onPressed: _openLeafScanner,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Review'),
        ],
      ),
    );
  }

  Widget _buildDrawer(SettingsProvider settings) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade700),
            accountName: const Text("John Doe", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("johndoe@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Toggle Dark Mode"),
            onTap: () {
              settings.toggleDarkMode();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () { Navigator.pop(context); },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () { Navigator.pop(context); },
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: const Hero(
                tag: "leaf_icon",
                child: Icon(Icons.eco, size: 140, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tap the leaf icon to classify an image!",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}