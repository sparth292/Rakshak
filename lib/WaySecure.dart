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
      'location': LatLng(19.072653011441478, 72.89883502349292),
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
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
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

          // Send SMS only once per zone
          if (distance <= zoneRadius && !_notifiedZones.contains(zoneName)) {
            _sendLocationSMS(zone);
            _notifiedZones.add(zoneName); // Mark zone as notified for SMS
          }

          // Send notifications continuously if within the zone
          if (distance <= zoneRadius) {
            _sendLocalNotification(zone);
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
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF78143C),
        title: Center(
          child: Text(
            'WaySecure',
            style: GoogleFonts.italiana(
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
          : Column(
        children: [
          Expanded(
            child: FlutterMap(
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
          ),
        ],
      ),
    );
  }
}
