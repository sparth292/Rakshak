import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rakshak_backup_final/ChatList.dart';
import 'package:rakshak_backup_final/WaySecure.dart';
import 'package:rakshak_backup_final/addContacts.dart';
import 'package:rakshak_backup_final/profile_page.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rakshak_backup_final/services/pharmacy.dart';
import 'package:rakshak_backup_final/services/police_station.dart';
import 'package:rakshak_backup_final/services/hospital.dart';
import 'package:rakshak_backup_final/services/bus_station.dart';
import 'package:rakshak_backup_final/services/railway_station.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakshak_backup_final/splashscreen.dart';
import 'contactsm.dart';
import 'dbservices.dart';
import 'screens/ai_chat_screen.dart';

// import 'package:firebase_auth/firebase_auth.dart';
void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rakshak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// signout()async{
//   await FirebaseAuth.instance.signOut();
// }

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    CustomCardsScreen(),
    SettingsPage(),
    ProfilePage(),
  ];

  final _telephonySMS = TelephonySMS();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initVoiceCommand(context); // Start voice recognition when app launches
  }

  Future<LatLng?> _getUserLocation() async {
    // Check location permissions using permission_handler
    if (await Permission.locationWhenInUse.request().isGranted) {
      try {
        // Use Geolocator or any location service to fetch current location
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        return LatLng(position.latitude, position.longitude);
      } catch (e) {
        print('Error fetching location: $e');
        return null;
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Location permission denied.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink.shade50,
        textColor: Color(0xFF78143C),
        fontSize: 16.0,
      );
      return null;
    }
  }

  Future<void> _sendLocationSMS(BuildContext context) async {
    Fluttertoast.showToast(
      msg: 'Preparing to send SMS...',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.pink.shade50,
      textColor: Colors.pinkAccent,
      fontSize: 16.0,
    );

    _userLocation = await _getUserLocation();
    String message;

    if (_userLocation != null) {
      String currentLocation =
          "https://www.google.com/maps?q=${_userLocation!.latitude},${_userLocation!.longitude}";
      message = "HELP! My current location is: $currentLocation";
    } else {
      message = "HELP! Unable to fetch my location right now.";
    }

    try {
      await _telephonySMS.requestPermission();

      DatabaseHelper databaseHelper = DatabaseHelper();
      List<TContact> contactList = await databaseHelper.getContactList();

      if (contactList.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No contacts found to send SMS.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink.shade50,
          textColor: Colors.pinkAccent,
          fontSize: 16.0,
        );
        return;
      }

      await Future.wait(contactList.map((contact) async {
        try {
          await _telephonySMS.sendSMS(phone: contact.number, message: message);
        } catch (e) {
          Fluttertoast.showToast(
            msg: 'Failed to send SMS to ${contact.name}: $e',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade50,
            textColor: Colors.red,
            fontSize: 14.0,
          );
        }
      }));

      Fluttertoast.showToast(
        msg: _userLocation != null
            ? 'Location sent to all contacts via SMS!'
            : 'Fallback message sent to all contacts via SMS!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink.shade50,
        textColor: Colors.pinkAccent,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to send SMS: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink.shade50,
        textColor: Colors.pinkAccent,
        fontSize: 16.0,
      );
    }
  }

  void _triggerSOS(BuildContext context) async {
    await _sendLocationSMS(context);
  }

  void _initVoiceCommand(BuildContext context) async {
    SpeechToText speechToText = SpeechToText();

    // Request microphone permissions
    if (await Permission.microphone.request().isDenied) {
      Fluttertoast.showToast(
        msg: "Microphone permission denied.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Initialize SpeechToText
    bool isInitialized = await speechToText.initialize(
      onStatus: (status) {
        print("Speech status: $status");
        if (status == "notListening") {
          // Restart listening automatically after a brief delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (!speechToText.isListening) {
              speechToText.listen(onResult: _onSpeechResult);
            }
          });
        }
      },
      onError: (error) {
        print("Speech error: ${error.errorMsg}");
        // Fluttertoast.showToast(
        //   msg: "Speech error: ${error.errorMsg}",
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.BOTTOM,
        // );

        // Retry listening after a short delay to resolve "error busy"
        Future.delayed(Duration(seconds: 1), () {
          if (!speechToText.isListening) {
            speechToText.listen(onResult: _onSpeechResult);
          }
        });
      },
    );

    if (!isInitialized) {
      Fluttertoast.showToast(
        msg: "Speech recognition initialization failed.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Start continuous listening
    speechToText.listen(onResult: _onSpeechResult);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print("Recognized words: ${result.recognizedWords}");
    if (result.recognizedWords.toLowerCase().contains("sos") ||
        result.recognizedWords.toLowerCase().contains("bachao") ||
        result.recognizedWords.toLowerCase().contains("help")) {
      Fluttertoast.showToast(
        msg: "Voice recognized: ${result.recognizedWords}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      _triggerSOS(context);
    } else {
      print("Unrecognized command: ${result.recognizedWords}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display current page
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        color: Color(0xFF78143C),
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Icon(Icons.home, color: Colors.pink.shade50, size: 30),
          Icon(Icons.settings, color: Colors.pink.shade50, size: 30),
          Icon(Icons.person, color: Colors.pink.shade50, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class Locators extends StatelessWidget {
  const Locators({super.key});

  static Future<void> openMap(String location) async {
    String googleUrl = 'https://www.google.com/maps/search/$location';
    final Uri url = Uri.parse(googleUrl);
    try {
      await launchUrl(url);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something Went Wrong!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 25),
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: const [
          PoliceStationCard(onMapFunction: openMap),
          SizedBox(width: 25),
          HospitalCard(onMapFunction: openMap),
          SizedBox(width: 25),
          RailwayStationCard(onMapFunction: openMap),
          SizedBox(width: 25),
          BusStationCard(onMapFunction: openMap),
          SizedBox(width: 25),
          PharmacyCard(onMapFunction: openMap),
        ],
      ),
    );
  }
}

class CustomCardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Center(
              child: Text(
                'Rakshak',
                style: GoogleFonts.italiana(
                  fontSize: 30,
                  color: Color(0xFF78143C),
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        },
        backgroundColor: Color(0xFF78143C),
        child: Icon(Icons.smart_toy, color: Colors.pink.shade50),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Locators(),
                SizedBox(height: 10),
                customCard(
                  context: context,
                  title: 'WaySecure',
                  description1: 'Detects location',
                  description2: 'for user safety',
                  imagePath: 'RImages/mapping.png',
                  onTapPage: WaySecure(),
                ),
                SizedBox(height: 9),
                customCard(
                  context: context,
                  title: 'SHEConnect',
                  description1: 'Enables users to',
                  description2: 'stay connected',
                  imagePath: 'RImages/communitychat.png',
                  onTapPage: ChatListScreen(),
                ),
                SizedBox(height: 9),
                customCard(
                  context: context,
                  title: 'CareConnect',
                  description1: 'Enables users to',
                  description2: 'add contacts',
                  imagePath: 'RImages/careConnect.png',
                  onTapPage: AddContacts(),
                ),
                // customCard(
                //   context: context,
                //   title: 'Scream Alert',
                //   description1: 'Detects scream',
                //   description2: 'to send alerts',
                //   imagePath: 'images/screamalert.png',
                //   onTapPage: CommunityChatPage(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customCard({
    required BuildContext context,
    required String title,
    required String description1,
    required String description2,
    required String imagePath,
    required Widget onTapPage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => onTapPage),
        );
      },
      child: Container(
        height: 150,
        width: 350,
        child: Card(
          color: Colors.white,
          elevation: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description1,
                    style: GoogleFonts.comfortaa(
                      fontSize: 15,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  Text(
                    description2,
                    style: GoogleFonts.comfortaa(
                      fontSize: 15.5,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 40),
              Image.asset(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  Future<void> requestPermission(
      BuildContext context, Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Permission Granted"),
          content: Text("${permission.toString()} has already been granted."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else if (status.isDenied) {
      final newStatus = await permission.request();
      if (newStatus.isGranted) {
        print("${permission.toString()} granted");
      } else if (newStatus.isDenied) {
        print("${permission.toString()} denied");
      } else if (newStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Settings',
            style: GoogleFonts.italiana(
              fontSize: 30,
              color: Color(0xFF78143C),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   "Manage Permissions",
              //   style: GoogleFonts.comfortaa(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black,
              //   ),
              // ),
              // Text(
              //   "To ensure the best user experience, please grant the following permissions",
              //   style: GoogleFonts.comfortaa(
              //     fontSize: 15,
              //     color: Colors.grey,
              //   ),
              // ),
              SizedBox(height: 10),
              buildPermissionTile(
                context,
                icon: Icons.camera_alt,
                title: 'Camera',
                description: 'Used for gender detection in app.',
                onPressed: () => requestPermission(context, Permission.camera),
              ),
              SizedBox(
                height: 2,
              ),
              buildPermissionTile(
                context,
                icon: Icons.mic,
                title: 'Microphone',
                description: 'Required for voice recognition.',
                onPressed: () =>
                    requestPermission(context, Permission.microphone),
              ),
              SizedBox(
                height: 2,
              ),
              buildPermissionTile(
                context,
                icon: Icons.location_on,
                title: 'Location',
                description: 'Required for real-time location tracking.',
                onPressed: () =>
                    requestPermission(context, Permission.location),
              ),
              SizedBox(
                height: 2,
              ),
              buildPermissionTile(
                context,
                icon: Icons.notifications,
                title: 'Notification',
                description: 'Required to send notifications.',
                onPressed: () =>
                    requestPermission(context, Permission.notification),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPermissionTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF78143C), size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: GoogleFonts.comfortaa(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 4,
          ),
          customButton(
            onPressed: onPressed,
            title: "Request",
          ),
        ],
      ),
    );
  }
}

class ScreamAlertPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scream Alert')),
      body: Center(child: Text('Scream Alert Details')),
    );
  }
}

class MappingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mapping')),
      body: Center(child: Text('Mapping Details')),
    );
  }
}

class CommunityChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Chat')),
      body: Center(child: Text('Community Chat Details')),
    );
  }
}

class customButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  customButton({required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Color(0xFF78143C),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.comfortaa(fontSize: 14, color: Colors.white),
      ),
    );
  }
}
