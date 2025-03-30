import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ScreenshotExampleScreen(),
    );
  }
}

class ScreenshotExampleScreen extends StatefulWidget {
  const ScreenshotExampleScreen({super.key});

  @override
  State<ScreenshotExampleScreen> createState() => _ScreenshotExampleScreenState();
}

class _ScreenshotExampleScreenState extends State<ScreenshotExampleScreen> {
  String? _screenshotPath;
  String _timestamp = "";
  final _screenshotPlugin = FlutterNativeScreenshotPlus();
  bool _isLoading = false;
  final GlobalKey _globalKey = GlobalKey(); // Key for RepaintBoundary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Screenshot Demo')),
      body: RepaintBoundary(
        key: _globalKey, // Assigning key
        child: Column(
          children: [
            Expanded(
              child: _buildScreenshotPreview(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Timestamp: $_timestamp",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.camera, size: 50, color: Colors.blue),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading ? null : _handleScreenshot,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('CAPTURE SCREENSHOT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotPreview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_screenshotPath == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No screenshot captured yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return FutureBuilder<File>(
      future: _getImageFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load image'));
        }

        return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red)
            ),
            child: Image.file(snapshot.data!, fit: BoxFit.contain));
      },
    );
  }

  Future<File> _getImageFile() async {
    final file = File(_screenshotPath!);
    if (await file.exists()) {
      return file;
    }
    throw Exception('File not found');
  }

  Future<void> _handleScreenshot() async {
    try {
      setState(() {
        _isLoading = true;
        _timestamp = DateTime.now().toString(); // Update timestamp before screenshot
      });

      // Ensure permissions
      await _requestPermissions();

      // Short delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 300));

      // Capture screenshot
      final path = await _screenshotPlugin.takeScreenshot();
      debugPrint('Screenshot path: $path');

      if (path == null || path.isEmpty) {
        _showSnackBar('Failed to capture screenshot');
        return;
      }

      setState(() {
        _screenshotPath = path;
      });

      _showSnackBar('Screenshot saved successfully!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid && await DeviceInfoPlugin().androidInfo.then((info) => info.version.sdkInt) >= 33) {
      final status = await [Permission.photos, Permission.videos].request();
      if (!status[Permission.photos]!.isGranted) {
        _showSnackBar('Photo library permission required');
      }
    } else {
      final status = await [
        Permission.storage,
        if (Platform.isIOS) Permission.photos,
      ].request();
      if (!status[Permission.storage]!.isGranted) {
        _showSnackBar('Storage permission required');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
