import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:genderapp/ChatScreen.dart';
import 'package:genderapp/SOS/dbservices.dart';
import 'package:genderapp/WaySecure/WaySecure.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:sqflite/sqflite.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:genderapp/services/pharmacy.dart';
import 'package:genderapp/services/police_station.dart';
import 'package:genderapp/services/hospital.dart';
import 'package:genderapp/services/bus_station.dart';
import 'package:genderapp/services/railway_station.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SOS/CustomButton.dart';
import 'SOS/contactsm.dart';
import 'package:genderapp/ProfilePage.dart';
import 'package:genderapp/WaySecure/WaySecure.dart';
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
        textColor: Colors.pinkAccent,
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
            : 'Fallback message sent to all contacts via SMS!'
        ,
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
    if (result.recognizedWords.toLowerCase().contains("sos")) {
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
        color: Color.fromRGBO(188, 66, 107, 1),
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
//navbar khtm
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
      padding: const EdgeInsets.only(left: 25,right: 25),
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
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        title: Column(
          children: [
            Center(
              child: Text('Rakshak',style: GoogleFonts.cinzel(
                fontSize: 25,
                color: Colors.pink.shade50,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Locators(),
                SizedBox(height: 5),
                customCard(
                  context: context,
                  title: 'WaySecure',
                  description1: 'Detects location',
                  description2: 'for user safety',
                  imagePath: 'RImages/mapping.png',
                  onTapPage: WaySecure(),
                ),
                SizedBox(height: 10),
                customCard(
                  context: context,
                  title: 'SHEConnect',
                  description1: 'Enables users to',
                  description2: 'stay connected',
                  imagePath: 'RImages/communitychat.png',
                  onTapPage: ChatScreen(),
                ),
                SizedBox(height: 10),
                customCard(
                  context: context,
                  title: 'CareConnect',
                  description1: 'Enables users to',
                  description2: 'add contacts',
                  imagePath: 'RImages/trust.png',
                  onTapPage: AddContacts(),
                ),
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
          color: Colors.pink.shade50,
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
  Future<void> requestPermission(BuildContext context, Permission permission) async {
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
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        title: Center(
          child: Text('Settings',style: GoogleFonts.cinzel(
            fontSize: 25,
            color: Colors.pink.shade50,
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

              Text(
                "Manage Permissions",
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "To ensure the best user experience, please grant the following permissions",
                style: GoogleFonts.comfortaa(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              buildPermissionTile(
                context,
                icon: Icons.camera_alt,
                title: 'Camera',
                description: 'Allows gender detection during user signup.',
                onPressed: () => requestPermission(context, Permission.camera),
              ),
              buildPermissionTile(
                context,
                icon: Icons.mic,
                title: 'Microphone',
                description: 'Required for recording audio during emergencies.',
                onPressed: () => requestPermission(context, Permission.microphone),
              ),
              buildPermissionTile(
                context,
                icon: Icons.location_on,
                title: 'Location',
                description: 'Required for real-time tracking and safe/danger zone mapping.',
                onPressed: () => requestPermission(context, Permission.location),
              ),
              buildPermissionTile(
                context,
                icon: Icons.notifications,
                title: 'Notification',
                description: 'Required to send alerts and important notifications.',
                onPressed: () => requestPermission(context, Permission.notification),
              ),
              SizedBox(height: 10,),
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
        color: Colors.pink.shade50,
      ),
      child: Row(
        children: [
          Icon(icon, color: Color.fromRGBO(188, 66, 107, 1), size: 30),
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
                SizedBox(height: 2,),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
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

// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // final user = FirebaseAuth.instance.currentUser;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color.fromRGBO(188, 66, 107, 1),
//         title: Center(
//           child: Text('Profile',style: GoogleFonts.cinzel(
//             fontSize: 25,
//             color: Colors.pink.shade50,
//             fontStyle: FontStyle.normal,
//             fontWeight: FontWeight.bold,
//           ),
//           ),
//         ),
//       ),
//
//     );
//   }
// }


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
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}
class AddContacts extends StatefulWidget {
  const AddContacts({super.key});

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<TContact> contactList = [];
  int count = 0;

  Future<void> showlist() async {
    Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<TContact>> contactListFuture = databaseHelper.getContactList();
      contactListFuture.then((value) {
        setState(() {
          this.contactList = value;
          this.count = value.length;
        });
      });
    });
  }
  void deleteContact(TContact contact) async{
    int result = await databaseHelper.deleteContact(contact.id);
    if(result != 0){
      Fluttertoast.showToast(msg: "Contact deleted.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink.shade50,
          textColor: Colors.pinkAccent,
          fontSize: 16.0);
    }
  }
  @override
  void initState() {
    showlist();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        title: Center(
          child: Text('Guardians',style: GoogleFonts.cinzel(
            fontSize: 25,
            color: Colors.pink.shade50,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
          ),
        ),
      ),
      backgroundColor: Colors.white, // Set your desired background color
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(50),
          child: Column(
            children: [
              Center(
                child: CustomButton(
                  title: "Add Trusted Contacts",
                  onPressed: () async {
                    bool result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactsPage()),
                    );
                    if (result == true) {
                      showlist();
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: count,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.transparent,
                          width: 2,
                        ),
                      ),
                      elevation: 4,
                      color: Colors.pink.shade50,
                      child: ListTile(
                        title: Text(contactList[index].name),
                        trailing: IconButton(
                          onPressed: () {
                            deleteContact(contactList[index]);
                          },
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    askPermissions();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  void filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = element.displayName.toLowerCase();
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch) {
          return true;
        }
        if (searchTermFlatten.isEmpty) {
          return false;
        }
        return element.phones?.any((p) {
          String phoneFlattened = flattenPhoneNumber(p.number ?? "");
          return phoneFlattened.contains(searchTermFlatten);
        }) ?? false;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermission();
    if (permissionStatus == PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    } else {
      handleInvalidPermission(permissionStatus);
    }
  }

  void handleInvalidPermission(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      // Handle denial of permission
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      // Handle permanent denial of permission
    }
  }

  Future<PermissionStatus> getContactsPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      return await Permission.contacts.request();
    }
    return permission;
  }

  Future<void> getAllContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> _contacts = await FlutterContacts.getContacts(
          withProperties: true,withThumbnail: false);
      setState(() {
        contacts = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listIsItemExist = contactsFiltered.isNotEmpty || contacts.isNotEmpty;
    DatabaseHelper _databaseHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        title: Center(
          child: Text(
            'Contacts',
            style: GoogleFonts.cinzel(
              fontSize: 25,
              color: Colors.pink.shade50,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              autofocus: true,
              style: TextStyle(fontSize: 18, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.pinkAccent),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
          listIsItemExist
              ? Expanded(
            child: ListView.builder(
              itemCount: isSearching
                  ? contactsFiltered.length
                  : contacts.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = isSearching
                    ? contactsFiltered[index]
                    : contacts[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: Colors.transparent, width: 2),
                  ),
                  elevation: 4,
                  color: Colors.pink.shade50,
                  child: ListTile(
                    onTap: (){
                      if(contact.phones!.length > 0){
                        final String phoneNum = contact.phones.elementAt(0).number!;
                        final String name = contact.displayName!;
                        _addContact(TContact(phoneNum, name));
                      }else{
                        Fluttertoast.showToast(msg : "oops! phone number of this contact does not exist.",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.pink.shade50,
                            textColor: Colors.pinkAccent,
                            fontSize: 16.0);
                      }
                    },
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    title: Text(
                      contact.displayName ?? '',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: (contact.phones?.isNotEmpty ?? false)
                        ? Text(contact.phones!.first.number ?? "No Number")
                        : null,
                    leading: (contact.photo != null)
                        ? CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: MemoryImage(contact.photo!),
                    )
                        : CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : "N/A",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              : Center(
            child: Text("No contacts found"),
          ),
        ],
      ),
    );
  }
  void _addContact(TContact newContact) async{
    int result = await _databaseHelper.insertContact(newContact);
    if(result!=0){
      Fluttertoast.showToast(msg : "Contact added successfully.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink.shade50,
          textColor: Colors.pinkAccent,
          fontSize: 16.0);
    }else{
      Fluttertoast.showToast(msg : "Failed to add contacts.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pinkAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Navigator.pop(context, TContact);  // Pass the contact object back, not a bool


  }
}
