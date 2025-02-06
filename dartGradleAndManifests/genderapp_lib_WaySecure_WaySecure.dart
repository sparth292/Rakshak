import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class WaySecure extends StatefulWidget {
  const WaySecure({Key? key}) : super(key: key);

  @override
  _WaySecureState createState() => _WaySecureState();
}

class _WaySecureState extends State<WaySecure> {
  final Location _location = Location();
  final _telephonySMS = TelephonySMS();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin(); // Declare plugin globally

  // List of unsafe zones
  final List<Map<String, dynamic>> unsafeZones = [
    {
      'location': LatLng(19.17604070346859, 72.86278331232963),
      'radius': 2000.0,
      'name': 'Zone 1',
      'newsLink':
      'https://indianexpress.com/article/cities/mumbai/mumbai-woman-assault-girl-arrested-9760005/'
    },
    {
      'location': LatLng(19.28083276510148, 72.85603712269305),
      'radius': 1000.0,
      'name': 'Zone 2',
      'newsLink':
      'https://indianexpress.com/article/cities/mumbai/mumbai-woman-assault-girl-arrested-9760005/'
    },
    {
      'location': LatLng(19.090849682000876, 72.90762644774279),
      'radius': 1000.0,
      'name': 'Zone 3',
      'newsLink':
      'https://indianexpress.com/article/cities/mumbai/mumbai-woman-assault-girl-arrested-9760005/'
    },
  ];

  LatLng? _currentLocation;
  final Set<String> _notifiedZones = {}; // Track zones where SMS was sent
  bool isNotifying = false; // Prevents multiple simultaneous notifications

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeNotifications();
    await _checkLocationPermission();
    await _fetchInitialLocation();
    _trackUserLocation();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> _fetchInitialLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final LatLng userLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        for (var zone in unsafeZones) {
          final LatLng zoneLocation = zone['location'];
          final double zoneRadius = zone['radius'];

          // Calculate distance between user and unsafe zone
          final double distance = Distance().as(
            LengthUnit.Meter,
            userLocation,
            zoneLocation,
          );

          final String zoneName = zone['name'];

          // Skip if already notified or a notification is in progress
          if (distance <= zoneRadius && !_notifiedZones.contains(zoneName)) {
            if (!isNotifying) {
              isNotifying = true; // Lock notifications to prevent overlap
              _sendLocationSMS(zone).then((_) {
                _sendLocalNotification(zone);
                _notifiedZones.add(zoneName); // Mark as notified
                Future.delayed(const Duration(seconds: 10), () {
                  isNotifying = false; // Unlock notifications after delay
                });
              });
            }
          }
        }

        // Update the current location for the map
        setState(() {
          _currentLocation = userLocation;
        });
      }
    });
  }

  Future<void> _sendLocalNotification(Map<String, dynamic> zone) async {
    await flutterLocalNotificationsPlugin.show(
      1,
      "Unsafe Zone Alert",
      "You have entered ${zone['name']}! Stay cautious.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "unsafe_zone_channel",
          "Unsafe Zone Notifications",
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _sendLocationSMS(Map<String, dynamic> zone) async {
    if (_currentLocation != null) {
      String message =
          "Alert! You have entered ${zone['name']}. This area is unsafe! Be safe.";
      try {
        await _telephonySMS.requestPermission();
        await _telephonySMS.sendSMS(phone: "9321486739", message: message);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location sent via SMS!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SMS: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch location.')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(188, 66, 107, 1),
        title: Center(
          child: Text(
            'WaySecure',
            style: GoogleFonts.cinzel(
              fontSize: 25,
              color: Colors.pink.shade50,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Map with Unsafe Zones
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(_currentLocation!.latitude,
                  _currentLocation!.longitude),
              maxZoom: 17.0,
              minZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              CircleLayer(
                circles: unsafeZones.map((zone) {
                  return CircleMarker(
                    point: zone['location'],
                    color: Colors.red.withOpacity(0.5),
                    radius: zone['radius'] / 10,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 80.0,
                      height: 80.0,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blueAccent,
                        size: 40.0,
                      ),
                    ),
                  ...unsafeZones.map((zone) {
                    return Marker(
                      point: zone['location'],
                      width: 100.0,
                      height: 120.0,
                      child: GestureDetector(
                        onTap: () {
                          _launchURL(zone['newsLink']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 30),
                              Flexible(
                                child: Text(
                                  zone['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _launchURL(zone['newsLink']);
                                },
                                child: const Text(
                                  'See News',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              )
            ],
          ),
          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showReportDialog();
              },
              backgroundColor: const Color.fromRGBO(188, 66, 107, 1),
              child: const Icon(
                Icons.report,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Firebase Integration and Dialog
  void showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isUnsafe = false; // Tracks user's response

        return StatefulBuilder( // Needed to update state within the dialog
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Report Current Location"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Is the location you are currently in safe or unsafe?"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          setState(() {
                            isUnsafe = false; // User marks the location as safe
                          });
                        },
                        child: const Text(
                          "Safe",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            isUnsafe =
                            true; // User marks the location as unsafe
                          });
                        },
                        child: const Text(
                          "Unsafe",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog without submitting
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isUnsafe && _currentLocation != null) {
                      _addZoneToFirestore(
                          _currentLocation!, "User Reported Zone");
                    }
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addZoneToFirestore(LatLng location, String name) async {
    try {
      await FirebaseFirestore.instance.collection('unsafe_zones').add({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'radius': 1000.0,
        'name': name,
        'reported_by': 'user123',
        'timestamp': DateTime.now(),
      });
      print("Zone added successfully!");
    } catch (e) {
      print("Error adding zone: $e");
    }
  }
}

