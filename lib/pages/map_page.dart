import 'dart:async';

import 'package:loocator/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  final LatLng _center = const LatLng(32.785811, -79.936280);
  final LatLng _BerryHall = const LatLng(32.785513, -79.937533);
  final LatLng _EducationCenter = const LatLng(32.782801, -79.936165);
  LatLng? _currentP = null;

  Map<PolylineId, Polyline> polylines = Map<PolylineId, Polyline>();

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then((_) => {
          getPolylinePoints(
                  toPointLatLng(_BerryHall), toPointLatLng(_EducationCenter))
              .then((coordinates) => {
                    generatePolylineFromPoints(coordinates),
                  }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Loocator'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: _currentP == null
            ? const Center(
                child: Text("Loading..."),
              )
            : GoogleMap(
                onMapCreated: ((GoogleMapController controller) =>
                    _mapController.complete(controller)),
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 17.0,
                ),
                myLocationEnabled: true,
                markers: {
                  Marker(
                    markerId: MarkerId('_BerryHall'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _BerryHall,
                  ),
                  Marker(
                    markerId: MarkerId('_EducationCenter'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _EducationCenter,
                  ),
                },
                polylines: Set<Polyline>.of(polylines.values),
              ),
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 17.0);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();

    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints(
      PointLatLng origin, PointLatLng destination) async {
    List<LatLng> polylineCoodinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
          origin: origin, destination: destination, mode: TravelMode.walking),
      googleApiKey: GOOGLE_MAPS_API_KEY,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoodinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoodinates;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.lightBlueAccent,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  PointLatLng toPointLatLng(LatLng coordinates) {
    return PointLatLng(coordinates.latitude, coordinates.longitude);
  }
}
