import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:loocator/api/routes_api.dart';
import 'package:loocator/utils/utils.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  List<LatLng> markers = [
    LatLng(latitude: 32.787971, longitude: -79.936245), // Camden Garage
    LatLng(latitude: 32.787118, longitude: -79.936853), // Hotel Bennett
    LatLng(latitude: 32.786573, longitude: -79.936916), // Marion Square Garage
  ];
  List<NavigationWaypoint> _waypoints = <NavigationWaypoint>[];

  LatLng? _userLocation = null;
  static const int _userLocationTimeoutMS = 1500;
  static const LatLng cameraLocationMIT =
      LatLng(latitude: 42.3601, longitude: -71.094013);

  bool _navigatorInitialized = false;

  bool _locationPermissionsAccepted = false;
  bool _termsAndConditionsAccepted = false;

  bool _errorOnSetDestinations = false;

  GoogleNavigationViewController? _navigationViewController;
  bool _navigatorInitializedAtLeastOnce = false;

  int _onRoadSnappedLocationUpdatedEventCallCount = 0;
  int _onRoadSnappedRawLocationUpdatedEventCallCount = 0;
  StreamSubscription<RoadSnappedLocationUpdatedEvent>?
      _roadSnappedLocationUpdatedSubscription;
  StreamSubscription<RoadSnappedRawLocationUpdatedEvent>?
      _roadSnappedRawLocationUpdatedSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _askLocationPermissinosIfNeeded();

    await _showTermsAndConditionsDialogIfNeeded();

    if (_locationPermissionsAccepted && _termsAndConditionsAccepted) {
      _initializeNavigator();
    }
  }

  Future<void> _initializeNavigator() async {
    assert(_termsAndConditionsAccepted, 'Terms must be accepted');
    assert(
        _locationPermissionsAccepted, 'Location permissions must be granted');

    if (!_navigatorInitialized) {
      debugPrint('Initializing new navigation session...');
      await GoogleMapsNavigator.initializeNavigationSession();
      await _setupListeners();
      await _updateNavigatorInitializationState();
      unawaited(_setDefaultUserLocationAfterDelay());
      debugPrint('Navigator has been initialized: $_navigatorInitialized');
    }
    setState(() {});
  }

  Future<void> _askLocationPermissinosIfNeeded() async {
    _locationPermissionsAccepted = await requestLocationDialogAcceptance();
    setState(() {});
  }

  Future<void> _showTermsAndConditionsDialogIfNeeded() async {
    _termsAndConditionsAccepted = await requestTermsAndConditionsAcceptance();
    setState(() {});
  }

  Future<void> _updateNavigatorInitializationState() async {
    _navigatorInitialized = await GoogleMapsNavigator.isInitialized();
    if (_navigatorInitialized) {
      _navigatorInitializedAtLeastOnce = true;
    }
    setState(() {});
  }

  Future<void> _setDefaultUserLocationAfterDelay() async {
    Future<void>.delayed(const Duration(milliseconds: _userLocationTimeoutMS),
        () async {
      if (mounted && _userLocation == null) {
        _userLocation = await _navigationViewController?.getMyLocation() ??
            cameraLocationMIT;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> _setupListeners() async {
    _roadSnappedLocationUpdatedSubscription =
        await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
            _onRoadSnappedLocationUpdatedEvent);
    _roadSnappedRawLocationUpdatedSubscription =
        await GoogleMapsNavigator.setRoadSnappedRawLocationUpdatedListener(
            _onRoadSnappedRawLocationUpdatedEvent);
  }

  void _onRoadSnappedLocationUpdatedEvent(
      RoadSnappedLocationUpdatedEvent event) {
    if (!mounted) {
      return;
    }

    setState(() {
      _userLocation = event.location;
      _onRoadSnappedLocationUpdatedEventCallCount += 1;
    });
  }

  // Note: Raw location updates are not available on iOS.
  void _onRoadSnappedRawLocationUpdatedEvent(
      RoadSnappedRawLocationUpdatedEvent event) {
    if (!mounted) {
      return;
    }

    setState(() {
      _userLocation = event.location;
      _onRoadSnappedRawLocationUpdatedEventCallCount += 1;
    });
  }

  ///Places predetermined markers in map when the map is creates
  Future<void> _placeMarkers() async {
    for (LatLng marker in markers) {
      await _navigationViewController!.addMarkers(<MarkerOptions>[
        MarkerOptions(
            infoWindow: const InfoWindow(title: 'Destination'),
            position:
                LatLng(latitude: marker.latitude, longitude: marker.longitude))
      ]);
    }
  }

  Future<void> _addWaypoint(String marker) async {
    List<Marker?> markers = await _navigationViewController!.getMarkers();

    Marker? waypointMarker;

    for (Marker? m in markers) {
      if (m!.markerId == marker) {
        waypointMarker = m;
      }
    }

    _waypoints.add(NavigationWaypoint(
        title: 'Waypoint ${waypointMarker!.markerId.split('_')[1]}',
        target: LatLng(
            latitude: waypointMarker.options.position.latitude,
            longitude: waypointMarker.options.position.longitude)));

    await _updateNavigationDestinationsAndNavigationViewState();
  }

  Future<void> _updateNavigationDestinationsAndNavigationViewState() async {
    final bool success = await _updateNavigationDestinations();
    if (success) await _navigationViewController!.setNavigationUIEnabled(true);
  }

  Future<bool> _updateNavigationDestinations() async {
    if (_navigationViewController == null || _waypoints.isEmpty) {
      return false;
    }
    if (!_navigatorInitialized) {
      await _initializeNavigator();
    }

    // Build destinations with Routes API
    final Destinations? destinations = await _buildDestinationsWithRoutesApi();

    if (destinations == null) {
      setState(() {
        _errorOnSetDestinations = true;
      });
      return false;
    }

    try {
      final NavigationRouteStatus navRouteStatus =
          await GoogleMapsNavigator.setDestinations(destinations);

      switch (navRouteStatus) {
        case NavigationRouteStatus.statusOk:
          // Route is valid. Return true as success.
          setState(() {
            _errorOnSetDestinations = false;
          });
          return true;
        case NavigationRouteStatus.internalError:
          debugPrint(
              'Unexpected internal error occured. Please restart the app.');
        case NavigationRouteStatus.routeNotFound:
          debugPrint('The route could not be calculated.');
        case NavigationRouteStatus.networkError:
          debugPrint(
              'Working network connection is required to calculate the route.');
        case NavigationRouteStatus.quotaExceeded:
          debugPrint('Insufficient API quota to use the navigation.');
        case NavigationRouteStatus.quotaCheckFailed:
          debugPrint(
              'API quota check failed, cannot authorize the navigation.');
        case NavigationRouteStatus.apiKeyNotAuthorized:
          debugPrint('A valid API key is required to use the navigation.');
        case NavigationRouteStatus.statusCanceled:
          debugPrint(
              'The route calculation was canceled in favor of a newer one.');
        case NavigationRouteStatus.duplicateWaypointsError:
          debugPrint(
              'The route could not be calculated because of duplicate waypoints.');
        case NavigationRouteStatus.noWaypointsError:
          debugPrint(
              'The route could not be calculated because no waypoints were provided.');
        case NavigationRouteStatus.locationUnavailable:
          debugPrint(
              'No user location is available. Did you allow location permission?');
        case NavigationRouteStatus.waypointError:
          debugPrint('Invalid waypoints provided.');
        case NavigationRouteStatus.travelModeUnsupported:
          debugPrint(
              'The route could not calculated for the given travel mode.');
        case NavigationRouteStatus.unknown:
          debugPrint(
              'The route could not be calculated due to an unknown error.');
        case NavigationRouteStatus.locationUnknown:
          debugPrint(
              'The route could not be calculated, because the user location is unknown.');
      }
    } on RouteTokenMalformedException catch (_) {
      debugPrint('Malformed route token');
    } on SessionNotInitializedException catch (_) {
      debugPrint('Cannot set destinations, session not initialized');
    }
    setState(() {
      _errorOnSetDestinations = true;
    });
    return false;
  }

  Future<Destinations?> _buildDestinationsWithRoutesApi() async {
    debugPrint('Using route token from Routes API.');

    List<String> routeTokens = <String>[];

    try {
      routeTokens = await getRouteToken(<NavigationWaypoint>[
        // Add user's location as start location for gettig route token.
        NavigationWaypoint.withLatLngTarget(
            title: 'Origin', target: _userLocation),
        ..._waypoints,
      ]);
    } catch (e) {
      debugPrint('Failed to get route tokens from Routes API.');
      return null;
    }

    if (routeTokens.isEmpty) {
      debugPrint('Failed to get route tokens from Routes API.');
      return null;
    } else if (routeTokens.length > 1) {
      debugPrint(
          'More than one route token received from Routes API. Using the first one.');
    }

    return Destinations(
        waypoints: _waypoints,
        displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
        routeTokenOptions: RouteTokenOptions(
            routeToken: routeTokens.first,
            travelMode: NavigationTravelMode.driving));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loocator'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _navigatorInitializedAtLeastOnce && _userLocation != null
          //? Text('hello')
          ? GoogleMapsNavigationView(
              onViewCreated: _onViewCreated,
              onMapClicked: _onMapClicked,
              onMarkerClicked: _onMarkerClicked,
              initialNavigationUIEnabledPreference:
                  NavigationUIEnabledPreference.disabled,
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 17,
              ),
              // Controls
              initialZoomControlsEnabled: false,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
    controller.setMyLocationEnabled(true);
    await _placeMarkers();
    // Additional setup can be added here.
  }

  Future<void> _onMapClicked(LatLng location) async {
    await _navigationViewController!.addMarkers(<MarkerOptions>[
      MarkerOptions(
          infoWindow: const InfoWindow(title: 'Destination'),
          position: LatLng(
              latitude: location.latitude, longitude: location.longitude))
    ]);
  }

  void _onMarkerClicked(String marker) {
    debugPrint(marker);
    _addWaypoint(marker);
  }

  @override
  void dispose() {
    if (_navigatorInitializedAtLeastOnce) {
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }

  // Implement this

  // void showMessage(String message) {
  //   if (isOverlayVisible) {
  //     showOverlayMessage(message);
  //   } else {
  //     final SnackBar snackBar = SnackBar(content: Text(message));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }
}
