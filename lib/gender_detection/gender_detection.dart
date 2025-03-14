import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:photo_analyzer/photo_analyzer.dart';
import 'package:flutter/services.dart';
import 'package:rakshak_backup_final/splashscreen.dart'; // Import for SystemNavigator.pop()

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const GenderVerification());
}

class GenderVerification extends StatelessWidget {
  const GenderVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gender Classification App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  CameraController? cameraController;
  String? capturedImagePath;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || cameraController?.value.isInitialized == false) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  Future<void> _setupCameraController() async {
    if (cameras != null && cameras!.isNotEmpty) {
      setState(() {
        cameraController = CameraController(
          cameras!.last,
          ResolutionPreset.high,
        );
      });
      cameraController?.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      }).catchError((Object e) {
        debugPrint(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/redbull.png',
                  width: 100,
                  height: 100,
                ),
                Text(
                  "Because every detail matters...",
                  style: GoogleFonts.comfortaa(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            ClipOval(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 0.9,
                child: CameraPreview(cameraController!),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.pink),
                      onPressed: () async {
                        try {
                          final XFile imageFile = await cameraController!.takePicture();
                          setState(() {
                            capturedImagePath = imageFile.path;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Picture captured successfully!')),
                          );
                        } catch (e) {
                          debugPrint('Error capturing image: $e');
                        }
                      },
                    ),
                    Text(
                      "Take Picture",
                      style: GoogleFonts.comfortaa(fontSize: 12, color: Colors.pinkAccent),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      iconSize: 70,
                      icon: const Icon(Icons.arrow_circle_right_rounded, color: Colors.pink),
                      onPressed: () {
                        if (capturedImagePath != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewScreen(imagePath: capturedImagePath!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please take a picture first!')),
                          );
                        }
                      },
                    ),
                    Text(
                      "Next",
                      style: GoogleFonts.comfortaa(fontSize: 12, color: Colors.pinkAccent),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _photoAnalyzerPlugin = PhotoAnalyzer();
  String _genderResult = "Verifying gender...";

  @override
  void initState() {
    super.initState();
    _detectGender();
  }

  Future<void> _detectGender() async {
    try {
      final imageBytes = await File(widget.imagePath).readAsBytes();
      final result = await _photoAnalyzerPlugin.genderPrediction(image: imageBytes);
      setState(() {
        _genderResult = result.toString(); // Adjust based on plugin's output
      });
    } catch (e) {
      setState(() {
        _genderResult = "Error detecting gender: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verify your gender...",
          style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ClipOval(
              child: Image.file(
                File(widget.imagePath),
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 0.9,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(80, 50),
                  ),
                  onPressed: () async {
                    await _detectGender();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gender: $_genderResult")),
                    );
                  },
                  child: Text(
                    "Verify Gender",
                    style: GoogleFonts.comfortaa(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_right_rounded, color: Colors.pink),
                      iconSize: 70,
                      onPressed: () async {
                        if (_genderResult.toLowerCase() == 'female') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ),
                          );
                          Future.delayed(const Duration(milliseconds: 500), () {
                            SystemNavigator.pop(); // Close the app
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gender is not female. Cannot proceed.")),
                          );
                        }
                      },
                    ),
                    Text(
                      "Proceed",
                      style: GoogleFonts.comfortaa(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navbar Screen"),
      ),
      body: const Center(
        child: Text("Welcome to Navbar Screen!"),
      ),
    );
  }
}
