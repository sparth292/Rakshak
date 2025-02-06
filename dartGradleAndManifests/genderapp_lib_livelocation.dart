import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveTrackingPage extends StatefulWidget {
  final String uuid;

  LiveTrackingPage({required this.uuid});

  @override
  _LiveTrackingPageState createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  late MapController mapController;
  late DatabaseReference _locationRef;

  GeoPoint? lastKnownLocation;
  bool isPhoneActive = true;

  @override
  void initState() {
    super.initState();

    // Initialize the map controller
    mapController = MapController.withPosition(
      GeoPoint(latitude: 0.0, longitude: 0.0), // Placeholder location
    );

    // Firebase reference to the location data
    _locationRef = FirebaseDatabase.instance.ref("locations/${widget.uuid}");

    // Listen for location updates
    _locationRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        try {
          final locationData = Map<String, dynamic>.from(data);

          final GeoPoint newLocation = GeoPoint(
            latitude: locationData['latitude'],
            longitude: locationData['longitude'],
          );

          setState(() {
            lastKnownLocation = newLocation;
            isPhoneActive = true;
          });

          // Update marker on the map
          _updateMarker(newLocation);
        } catch (e) {
          print("Error parsing location data: $e");
        }
      } else {
        // Phone is offline, maintain the last known location
        setState(() {
          isPhoneActive = false;
        });
      }
    });
  }

  Future<void> _updateMarker(GeoPoint newLocation) async {
    // Remove all previous markers and add a new one
    await mapController.clearAllMarkers();
    await mapController.addMarker(
      newLocation,
      markerIcon: MarkerIcon(
        icon: Icon(
          Icons.location_on,
          size: 48,
          color: Colors.red,
        ),
      ),
    );

    // Move the map camera to the updated location
    await mapController.moveCamera(GeoPoint(latitude: newLocation.latitude, longitude: newLocation.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Tracking"),
      ),
      body: Stack(
        children: [
          // Map widget
          OSMFlutter(
            controller: mapController,
            mapIsLoading: Center(
              child: CircularProgressIndicator(),
            ),
            initZoom: 12,
            // Default zoom level
          ),
          // Offline status notification
          if (!isPhoneActive && lastKnownLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Phone is offline. Showing last known location.",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
