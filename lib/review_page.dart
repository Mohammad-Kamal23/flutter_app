import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedData = prefs.getStringList('uploaded_images');
    if (storedData != null) {
      setState(() {
        _history = storedData.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
      });
    }
  }

  Future<void> _deleteImage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> images = prefs.getStringList('uploaded_images') ?? [];
    images.removeAt(index);
    await prefs.setStringList('uploaded_images', images);
    setState(() {
      _history.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Images"), backgroundColor: Colors.green.shade700),
      body: _history.isEmpty
          ? const Center(child: Text("No images uploaded yet.", style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white.withAlpha(230),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: _history[index]['image'] != null && File(_history[index]['image']!).existsSync()
                  ? Image.file(File(_history[index]['image']!), width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(
                "Classified: ${_history[index]['classified'] ? "Yes" : "No"}",
                style: TextStyle(color: _history[index]['classified'] ? Colors.green : Colors.red),
              ),
              subtitle: const Text("Tap to view details"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteImage(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
