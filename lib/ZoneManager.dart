import 'package:latlong2/latlong.dart';

class ZoneManager {
  final List<Map<String, dynamic>> zones = [
    {
      'location': LatLng(19.1168, 72.8582),
      'radius': 5000.0,
      'name': 'Mumbai: Western',
      'description': 'Join the conversation for Western Mumbai',
    },
    {
      'location': LatLng(18.9784, 72.8309),
      'radius': 5000.0,
      'name': 'Mumbai: S & C',
      'description': 'Discuss topics from South & Central Mumbai',
    },
    {
      'location': LatLng(19.0325, 73.0263),
      'radius': 5000.0,
      'name': 'Navi Mumbai',
      'description': 'Stay connected in Navi Mumbai',
    },
    {
      'location': LatLng(19.2161, 72.9814),
      'radius': 5000.0,
      'name': 'Thane',
      'description': 'Connect with people in Thane',
    },
    {
      'location': LatLng(19.2404, 73.1286),
      'radius': 5000.0,
      'name': 'Kalyan',
      'description': 'Engage with the Kalyan community',
    },
    {
      'location': LatLng(19.2967, 73.2031),
      'radius': 5000.0,
      'name': 'Titwala',
      'description': 'Join discussions from Titwala',
    },
    {
      'location': LatLng(19.17620091973311, 72.86278286768196), // Goregaon
      'radius': 5000.0,
      'name': 'Goregaon',
      'description': 'Connect with the Goregaon community',
    },
    {
      'location': LatLng(19.0728634001876, 72.89884087031837), // KJ Somaiya Polytechnic
      'radius': 3000.0,
      'name': 'KJ Somaiya Polytechnic',
      'description': 'Stay connected with KJ Somaiya Polytechnic students',
    },
  ];

  List<Map<String, dynamic>> getNearbyZones(LatLng userLocation) {
    List<Map<String, dynamic>> nearbyZones = [];
    for (var zone in zones) {
      double distance = Distance().as(
        LengthUnit.Meter,
        userLocation,
        zone['location'],
      );

      if (distance <= zone['radius']) {
        nearbyZones.add(zone);
      }
    }
    return nearbyZones;
  }
}
