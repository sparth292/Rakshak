import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:photo_analyzer/photo_analyzer.dart';
import 'package:image/image.dart' as img;
import 'package:rakshak_backup_final/userOrGuardian.dart';
import '../home_page.dart';
import '../welcome_screen.dart';
// import 'package:rakshak_backup_final/home_page.dart';  // Ensure Navbar is properly imported

List<CameraDescription>? cameras;

Future<void> setupCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    debugPrint("📷 Fetching available cameras...");
    cameras = await availableCameras();
    debugPrint("✅ Cameras fetched successfully: ${cameras?.length}");
  } catch (e) {
    debugPrint("❌ Error fetching cameras: $e");
  }
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    debugPrint("📷 Requesting Camera Permission...");

    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint("❌ Camera permission denied. Please allow it in settings.");
      return;
    }

    if (cameras == null || cameras!.isEmpty) {
      debugPrint("❌ Still no cameras detected! Restart the app.");
      return;
    }

    cameraController = CameraController(
      cameras!.last,
      ResolutionPreset.medium,
    );

    try {
      await cameraController!.initialize();
      debugPrint("✅ Camera initialized successfully");
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("❌ Camera initialization error: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _captureImage() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        final XFile imageFile = await cameraController!.takePicture();

        setState(() => capturedImagePath = imageFile.path); // 🔥 Just update state, no saving

        // 🔥 Show toast message after capture
        Fluttertoast.showToast(
          msg: "✅ Photo Captured Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );

      } catch (e) {
        // 🔥 Show error toast if capture fails
        Fluttertoast.showToast(
          msg: "❌ Error capturing photo: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Because every detail matters...",
              style: GoogleFonts.comfortaa(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            Expanded(
              child: cameraController == null || !cameraController!.value.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                borderRadius: BorderRadius.circular(150), // 🔴 Make it a perfect circle
                child: AspectRatio(
                  aspectRatio: 1, // Ensure perfect circle aspect ratio
                  child: CameraPreview(cameraController!),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 70,
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.pink),
                  onPressed: _captureImage,
                ),
                IconButton(
                  iconSize: 70,
                  icon: const Icon(Icons.arrow_circle_right_rounded, color: Colors.pink),
                  onPressed: () {
                    if (capturedImagePath != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PreviewScreen(imagePath: capturedImagePath!)),
                      );
                    }
                  },
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
  bool isFemale = false; // 🔥 Track if gender is female

  @override
  void initState() {
    super.initState();
    _detectGender();
  }

  Future<Uint8List> compressImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    return Uint8List.fromList(img.encodeJpg(image!, quality: 80));
  }

  Future<void> _detectGender() async {
    try {
      final compressedBytes = await compressImage(File(widget.imagePath));
      final result = await _photoAnalyzerPlugin.genderPrediction(image: compressedBytes);

      setState(() {
        _genderResult = result!;
        isFemale = _genderResult.toLowerCase() == "female"; // 🔥 Check if gender is Female
      });

      // 🔥 Show gender result in FlutterToast
      Fluttertoast.showToast(
        msg: "Detected Gender: $_genderResult",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // 🔥 Show error if not female
      if (!isFemale) {
        Fluttertoast.showToast(
          msg: "❌ Only Female Entry Allowed!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

    } catch (e) {
      setState(() => _genderResult = "Error detecting gender: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify your gender", style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white)),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.file(File(widget.imagePath), height: 300, width: 300, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, minimumSize: const Size(80, 50)),
            onPressed: _detectGender,
            child: Text("Verify Gender", style: GoogleFonts.comfortaa(fontSize: 15, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Text(
            _genderResult,
            style: GoogleFonts.comfortaa(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
          ),
          const SizedBox(height: 20),

          // 🔥 "Next" button only works if gender is Female
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFemale ? Colors.green : Colors.grey, // 🔥 Disable if not Female
              minimumSize: const Size(100, 50),
            ),
            onPressed: isFemale
                ? () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
            }
                : null, // 🔴 Button disabled if not Female
            child: const Text("Next", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}