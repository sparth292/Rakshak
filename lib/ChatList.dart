import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'ZoneManager.dart';
import 'ChatScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Location _location = Location();
  final ZoneManager _zoneManager = ZoneManager();
  LatLng? _currentLocation;
  List<String> _nearbyZoneNames = [];
  bool _isFetchingLocation = true;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  /// Fetches the user's real-time location and finds nearby zones
  Future<void> _fetchUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    // Request location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    try {
      // Get current location
      LocationData locationData = await _location.getLocation();
      _updateUserLocation(locationData);

      // Listen for location updates
      _location.onLocationChanged.listen((newLocation) {
        _updateUserLocation(newLocation);
      });
    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  /// Updates the user's location and finds nearby chat zones
  void _updateUserLocation(LocationData locationData) {
    if (locationData.latitude != null && locationData.longitude != null) {
      LatLng newLocation = LatLng(locationData.latitude!, locationData.longitude!);
      List<Map<String, dynamic>> newZones = _zoneManager.getNearbyZones(newLocation);

      setState(() {
        _currentLocation = newLocation;
        _nearbyZoneNames = newZones.map((zone) => zone['name'] as String).toList();
        _isFetchingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF78143C),
        title: Center(
          child: Text(
            'SheConnect',
            style: GoogleFonts.italiana(
              fontSize: 25,
              color: Colors.pink.shade50,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _isFetchingLocation
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chat_groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chat groups available.'));
          }

          // Filter chat groups based on nearby zones
          var chats = snapshot.data!.docs
              .where((chat) => _nearbyZoneNames.contains(chat['name']))
              .toList();

          if (chats.isEmpty) {
            return const Center(child: Text('No chats available in your area.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.pink.shade50,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.chat_bubble, color: Colors.pink),
                  title: Text(
                    chat['name'] ?? 'Unnamed Chat',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(chat['description'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
