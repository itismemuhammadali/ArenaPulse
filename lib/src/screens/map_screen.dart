import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_chat_app/src/screens/create_club_screen.dart';
import 'package:sports_chat_app/src/screens/club_profile_screen.dart';
import 'package:sports_chat_app/src/screens/osm_location_picker_screen.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';
import 'package:sports_chat_app/src/screens/facility_details_screen.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController? _mapController;
  double _searchRadius = 5.0;
  String _selectedSport = 'All';

  LatLng _currentLocation = const LatLng(24.8607, 67.0011); // Karachi (safe default)
  final List<Marker> _markers = [];
  final List<CircleMarker> _circles = [];
  bool _isLoadingLocation = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _adminClubs = [];
  bool _isLoadingClubs = false;
  List<Map<String, dynamic>> _clubsInRadius = [];
  List<Facility> _facilitiesInRadius = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _updateSearchCircle() {
    if (!mounted) return;
    
    try {
      setState(() {
        _circles.clear();
        _circles.add(
          CircleMarker(
            point: _currentLocation,
            radius: _searchRadius * 1000,
            useRadiusInMeter: true,
            color: const Color(0xFFFF8C00).withValues(alpha: 0.15),
            borderStrokeWidth: 3,
            borderColor: const Color(0xFFFF8C00),
          ),
        );
      });
      
      // Adjust zoom level based on search radius
      if (_mapController != null) {
        double zoomLevel = 15.0 - (_searchRadius / 5.0);
        zoomLevel = zoomLevel.clamp(10.0, 18.0);
        _mapController!.move(_currentLocation, zoomLevel);
      }
    } catch (e) {
      debugPrint('Error updating search circle: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    debugPrint('🔍 Starting location request...');

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📡 Location services enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        debugPrint('❌ Location services disabled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable in Settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔐 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        debugPrint('🔐 Requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('🔐 Permission after request: $permission');
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        debugPrint('❌ Permission permanently denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Open Settings to enable.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        await Geolocator.openAppSettings();
        return;
      }
      
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        debugPrint('❌ Permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please enable in Settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      debugPrint('✅ Permission granted: $permission');
      debugPrint('🔍 Fetching current position...');
      
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint('✅ Got position: ${position.latitude}, ${position.longitude}');
      debugPrint('📍 Accuracy: ${position.accuracy}m');

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLocation;
        _isLoadingLocation = false;
      });

      debugPrint('🔄 State updated');

      await Future.delayed(const Duration(milliseconds: 300));

      if (_mapController != null && mounted) {
        debugPrint('🗺️ Moving map to: $newLocation');
        _mapController!.move(_currentLocation, 15.0);
      }

      _updateSearchCircle();
      await _loadClubMarkers();

      debugPrint('✅ Location update complete');
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      debugPrint('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadAdminClubs() async {
    setState(() => _isLoadingClubs = true);
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final snapshot = await _firestore
          .collection('clubs')
          .where('adminId', isEqualTo: currentUserId)
          .get();

      final clubs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'clubName': data['clubName'] ?? 'Unnamed Club',
          'location': data['location'] ?? '',
          'latitude': data['latitude'] as double?,
          'longitude': data['longitude'] as double?,
          ...data,
        };
      }).toList();

      setState(() {
        _adminClubs = clubs;
        _isLoadingClubs = false;
      });
    } catch (e) {
      setState(() => _isLoadingClubs = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading clubs: $e')),
        );
      }
    }
  }

  Future<void> _loadClubMarkers() async {
    try {
      final snapshot = await _firestore.collection('clubs').get();

      _markers.clear();
      _clubsInRadius = [];
      _facilitiesInRadius = [];

      // Add current location marker
      _markers.add(
        Marker(
          point: _currentLocation,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
        ),
      );

      // 1. Process Clubs
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final latitude = data['latitude'] as double?;
        final longitude = data['longitude'] as double?;
        final sport = data['sport'] as String?;
        final clubName = data['clubName'] as String?;

        if (latitude == null || longitude == null) continue;

        if (_selectedSport != 'All' && sport != null && sport != _selectedSport) {
          continue;
        }

        final distance = _calculateDistance(
          _currentLocation.latitude,
          _currentLocation.longitude,
          latitude,
          longitude,
        );

        if (distance > _searchRadius) continue;

        _clubsInRadius.add({
          'id': doc.id,
          'clubName': clubName ?? 'Unnamed Club',
          'sport': sport ?? 'No sport',
          'location': data['location'] ?? '',
          'latitude': latitude,
          'longitude': longitude,
          'memberCount': (data['memberIds'] as List?)?.length ?? 0,
          'distance': distance,
        });

        _markers.add(
          Marker(
            point: LatLng(latitude, longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showClubDetails(doc.id),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
            ),
          ),
        );
      }

      _clubsInRadius.sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));

      // 2. Process Facilities (Sports Nets & Venues)
      try {
        final facilitySnapshot = await _firestore.collection('facilities').get();
        for (var doc in facilitySnapshot.docs) {
          final facility = Facility.fromFirestore(doc);

          if (_selectedSport != 'All' &&
              !facility.sports.any((s) => s.toLowerCase() == _selectedSport.toLowerCase())) {
            continue;
          }

          final distance = _calculateDistance(
            _currentLocation.latitude,
            _currentLocation.longitude,
            facility.latitude,
            facility.longitude,
          );

          if (distance > _searchRadius) continue;

          _facilitiesInRadius.add(facility);

          _markers.add(
            Marker(
              point: LatLng(facility.latitude, facility.longitude),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _showFacilityModal(facility),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Emerald green for facilities
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sports_cricket, color: Colors.white, size: 22),
                ),
              ),
            ),
          );
        }
      } catch (fErr) {
        debugPrint('Facility loading note: $fErr');
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading map data: $e')),
        );
      }
    }
  }

  void _showFacilityModal(Facility facility) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    facility.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Cash on Arrival',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF38BDF8)),
                const SizedBox(width: 4),
                Text(
                  '${facility.city} • ${facility.address}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: facility.sports.map((s) => Chip(
                label: Text(s, style: const TextStyle(fontSize: 11, color: Colors.white)),
                backgroundColor: const Color(0xFF0F172A),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sports_baseball, color: Colors.white, size: 18),
                label: const Text(
                  'View Available Nets & Book',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacilityDetailsScreen(facility: facility),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _showClubDetails(String clubId) async {
    try {
      final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
      if (!clubDoc.exists) return;

      final club = clubDoc.data()!;
      final clubName = club['clubName'] ?? 'Unnamed Club';

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClubProfileScreen(
            clubId: clubId,
            clubName: clubName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading club: $e')),
        );
      }
    }
  }

  Future<void> _selectClubLocation(Map<String, dynamic> club) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OSMLocationPickerScreen(
          initialLatitude: club['latitude'],
          initialLongitude: club['longitude'],
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        await _firestore.collection('clubs').doc(club['id']).update({
          'location': result['locationName'],
          'latitude': result['latitude'],
          'longitude': result['longitude'],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _loadAdminClubs();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating location: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showClubsModal() async {
    await _loadAdminClubs();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Clubs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a club to edit its location',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingClubs
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8C00),
                      ),
                    )
                  : _adminClubs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No clubs yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _adminClubs.length,
                          itemBuilder: (context, index) {
                            final club = _adminClubs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  _selectClubLocation(club);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              club['clubName'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.edit_location,
                                            color: Color(0xFFFF8C00),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if ((club['location'] ?? '').isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                club['location'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                        else
                                          Text(
                                            'No location set',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateClubScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Your Own Club',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClubsListSheet() async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Clubs in Radius (${_clubsInRadius.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _clubsInRadius.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No clubs in this radius',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _clubsInRadius.length,
                      itemBuilder: (context, index) {
                        final club = _clubsInRadius[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _showClubDetails(club['id']);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          club['clubName'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.sports_soccer,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              club['sport'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.people,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${club['memberCount']} members',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8C00),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${(club['distance'] as double).toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }

  Future<void> _showFacilitiesListSheet() async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_cricket, color: Color(0xFF10B981), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Sports Nets & Venues (${_facilitiesInRadius.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _facilitiesInRadius.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stadium_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No sports nets found in this radius',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try expanding your search radius using the slider above',
                            style: TextStyle(fontSize: 12, color: Colors.white38),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _facilitiesInRadius.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final facility = _facilitiesInRadius[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      facility.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Cash on Arrival',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${facility.city} • ${facility.address}',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                children: facility.sports.map((s) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(s, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                                )).toList(),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                                  label: const Text(
                                    'View Nets & Book',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FacilityDetailsScreen(facility: facility),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sprintindex.app',
              ),
              CircleLayer(circles: _circles),
              MarkerLayer(markers: _markers),
            ],
          ),
          // Top controls
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Radius: ${_searchRadius.toInt()} km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  if (_searchRadius > 1) {
                                    _searchRadius--;
                                  }
                                });
                                _updateSearchCircle();
                                _loadClubMarkers();
                              },
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: const Color(0xFFFF8C00),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: const Color(0xFFFF8C00),
                                overlayColor:
                                    const Color(0xFFFF8C00).withValues(alpha: 0.2),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _searchRadius,
                                min: 1,
                                max: 50,
                                onChanged: (value) {
                                  setState(() {
                                    _searchRadius = value;
                                  });
                                  _updateSearchCircle();
                                  _loadClubMarkers();
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  if (_searchRadius < 50) {
                                    _searchRadius++;
                                  }
                                });
                                _updateSearchCircle();
                                _loadClubMarkers();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.sports_soccer,
                                  color: Color(0xFF2196F3),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedSport,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      size: 18),
                                  items: [
                                    'All',
                                    'Football',
                                    'Cricket',
                                    'Tennis',
                                    'Hockey',
                                    'Padel',
                                    'Basketball',
                                    'Rugby',
                                    'Athletics/Track & Field',
                                  ].map((sport) {
                                    return DropdownMenuItem(
                                      value: sport,
                                      child: Text(
                                        sport,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSport = value!;
                                    });
                                    _loadClubMarkers();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showClubsModal,
                              borderRadius: BorderRadius.circular(12),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu Button - Bottom Left (Clubs)
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'menuButton',
              onPressed: _showClubsListSheet,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.menu,
                color: Color(0xFFFF8C00),
              ),
            ),
          ),
          // Facilities & Nets Button - Bottom Left
          Positioned(
            left: 80,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'facilitiesButton',
              onPressed: _showFacilitiesListSheet,
              backgroundColor: const Color(0xFF10B981),
              icon: const Icon(Icons.sports_cricket, color: Colors.white, size: 20),
              label: Text(
                'Nets (${_facilitiesInRadius.length})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          // My Location Button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'locationButton',
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2196F3),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Color(0xFF2196F3),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
