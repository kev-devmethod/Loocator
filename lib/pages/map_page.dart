import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(32.785811, -79.936280);
  final LatLng _BerryHall = const LatLng(32.785513, -79.937533);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Loocator'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 17.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId('_BerryHall'),
              icon: BitmapDescriptor.defaultMarker,
              position: _BerryHall,
            )
          },
        ),
      ),
    );
  }
}