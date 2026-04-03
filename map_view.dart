import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _positionStream;

  LatLng? _destination;
  bool _isSearchingNearby = false;
  String _activeType = "";
  double _distanceToDestination = 0.0;

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _getCurrentLocation();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateMarker(
            LatLng(position.latitude, position.longitude),
            "myLocation",
            "My Location",
            BitmapDescriptor.hueMagenta,
          );
          if (_destination != null) {
            _updatePath();
            _calculateDistance();
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateMarker(
            LatLng(position.latitude, position.longitude),
            "myLocation",
            "My Location",
            BitmapDescriptor.hueMagenta,
          );
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15,
          ),
        );
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }

  void _updateMarker(LatLng pos, String id, String title, double hue) {
    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: pos,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      ),
    );
  }

  void _updatePath() {
    if (_currentPosition == null || _destination == null) return;
    
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _destination!,
        ],
        color: Colors.pink,
        width: 6,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  void _calculateDistance() {
    if (_currentPosition == null || _destination == null) return;
    
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _destination!.latitude,
      _destination!.longitude,
    );
    
    setState(() {
      _distanceToDestination = distanceInMeters / 1000; // Convert to km
    });
  }

  void _shareLocation() {
    if (_currentPosition != null) {
      final String mapUrl =
          "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}";
      Share.share("🚨 Emergency Tracking: I am here! View my live location: $mapUrl");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to get current location")),
      );
    }
  }

  void _searchNearby(String type, Color color) {
    if (_currentPosition == null) {
      _getCurrentLocation();
      return;
    }

    setState(() {
      _isSearchingNearby = true;
      _activeType = type;
      _markers.removeWhere((m) => m.markerId.value.startsWith("nearby_"));
    });

    final double lat = _currentPosition!.latitude;
    final double lng = _currentPosition!.longitude;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _updateMarker(LatLng(lat + 0.004, lng + 0.004), "nearby_1", "Closest $type", BitmapDescriptor.hueCyan);
          _updateMarker(LatLng(lat - 0.003, lng + 0.006), "nearby_2", "Nearby $type", BitmapDescriptor.hueCyan);
          _isSearchingNearby = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Found nearby $type locations"),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _destination = position;
      _updateMarker(position, "destination", "Destination", BitmapDescriptor.hueAzure);
      _updatePath();
      _calculateDistance();
    });
  }

  void _clearRoute() {
    setState(() {
      _destination = null;
      _markers.removeWhere((m) => m.markerId.value == "destination");
      _polylines.clear();
      _distanceToDestination = 0.0;
    });
  }

  Future<void> _startNavigation() async {
    if (_destination == null) return;
    
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${_destination!.latitude},${_destination!.longitude}&travelmode=driving';
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch navigation app")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  polylines: _polylines,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),

                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildQuickSearchRow(),
                    ],
                  ),
                ),

                if (_destination != null)
                  Positioned(
                    bottom: 240,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.navigation_rounded, color: Colors.pink),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("Destination Set", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    "Distance: ${_distanceToDestination.toStringAsFixed(2)} km",
                                    style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _startNavigation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(80, 45),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("START", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 100,
                  right: 16,
                  child: Column(
                    children: [
                      if (_destination != null) ...[
                        FloatingActionButton.small(
                          heroTag: "clear",
                          backgroundColor: Colors.white,
                          onPressed: _clearRoute,
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FloatingActionButton.small(
                        heroTag: "loc",
                        backgroundColor: Colors.white,
                        onPressed: _getCurrentLocation,
                        child: const Icon(Icons.my_location, color: Colors.pink),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: "share",
                        backgroundColor: Colors.pink,
                        onPressed: _shareLocation,
                        child: const Icon(Icons.share_location, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                if (_isSearchingNearby)
                  const Center(child: CircularProgressIndicator(color: Colors.pink)),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.pink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _destination == null ? "Tap on map to set safety route" : "Live Path Active",
                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
            ),
            if (_destination != null)
              IconButton(onPressed: _clearRoute, icon: const Icon(Icons.cancel, color: Colors.grey, size: 20))
            else
              const Icon(Icons.touch_app, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildNearbyBtn("Police", Icons.local_police, Colors.blue),
          _buildNearbyBtn("Hospital", Icons.local_hospital, Colors.green),
          _buildNearbyBtn("Fire", Icons.fire_truck, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildNearbyBtn(String label, IconData icon, Color color) {
    final bool isActive = _activeType == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isActive,
        showCheckmark: false,
        avatar: Icon(icon, size: 16, color: isActive ? Colors.white : color),
        label: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        selectedColor: color,
        onSelected: (_) => _searchNearby(label, color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withOpacity(0.2))),
        elevation: 2,
      ),
    );
  }
}
