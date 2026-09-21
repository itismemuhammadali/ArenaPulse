import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteStep {
  final String instruction;
  final String streetName;
  final String maneuverType; // depart, turn, new name, roundabout, arrive
  final String modifier; // left, right, slight left, slight right, straight, uturn
  final double distanceMeters;
  final double durationSeconds;
  final LatLng location;

  RouteStep({
    required this.instruction,
    required this.streetName,
    required this.maneuverType,
    required this.modifier,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
  });

  factory RouteStep.fromOsrm(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final type = maneuver['type'] as String? ?? 'turn';
    final mod = maneuver['modifier'] as String? ?? '';
    final street = (json['name'] as String?)?.trim() ?? '';
    final locList = (maneuver['location'] as List?)?.cast<num>() ?? [0, 0];
    final loc = LatLng(locList[1].toDouble(), locList[0].toDouble());

    String text;
    if (type == 'depart') {
      text = street.isNotEmpty ? 'Depart on $street' : 'Head towards destination';
    } else if (type == 'arrive') {
      text = 'Arrive at venue destination';
    } else if (mod.isNotEmpty) {
      final capitalizedMod = mod[0].toUpperCase() + mod.substring(1);
      text = street.isNotEmpty ? '$capitalizedMod onto $street' : capitalizedMod;
    } else {
      text = street.isNotEmpty ? 'Continue on $street' : 'Continue straight';
    }

    return RouteStep(
      instruction: text,
      streetName: street,
      maneuverType: type,
      modifier: mod,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (json['duration'] as num?)?.toDouble() ?? 0.0,
      location: loc,
    );
  }
}

class RoutePlan {
  final List<LatLng> polyline;
  final List<RouteStep> steps;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final String summary;

  RoutePlan({
    required this.polyline,
    required this.steps,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.summary,
  });
}

class OsrmRoutingService {
  static final OsrmRoutingService _instance = OsrmRoutingService._internal();
  factory OsrmRoutingService() => _instance;
  OsrmRoutingService._internal();

  /// Fetch full driving route from start to destination via OSRM
  Future<RoutePlan> getDrivingRoute({
    required LatLng start,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final geometry = route['geometry'] as Map<String, dynamic>;
          final coords = (geometry['coordinates'] as List)
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          final legs = route['legs'] as List;
          final List<RouteStep> steps = [];
          if (legs.isNotEmpty) {
            final legSteps = legs[0]['steps'] as List? ?? [];
            for (final s in legSteps) {
              steps.add(RouteStep.fromOsrm(s as Map<String, dynamic>));
            }
          }

          final distMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
          final durSecs = (route['duration'] as num?)?.toDouble() ?? 0.0;

          return RoutePlan(
            polyline: coords,
            steps: steps,
            totalDistanceKm: (distMeters / 1000.0),
            totalDurationMinutes: (durSecs / 60.0).round().clamp(1, 9999),
            summary: legs.isNotEmpty ? (legs[0]['summary'] ?? '') : '',
          );
        }
      }
    } catch (_) {
      // Fallback for offline or slow network: generate direct connecting route
    }

    return _generateFallbackPlan(start, destination);
  }

  RoutePlan _generateFallbackPlan(LatLng start, LatLng dest) {
    const distanceCalc = Distance();
    final distMeters = distanceCalc.as(LengthUnit.Meter, start, dest);
    final distKm = distMeters / 1000.0;
    // Estimate ~35 km/h urban driving speed
    final durationMins = ((distKm / 35.0) * 60).round().clamp(2, 240);

    return RoutePlan(
      polyline: [start, dest],
      steps: [
        RouteStep(
          instruction: 'Head towards venue destination',
          streetName: '',
          maneuverType: 'depart',
          modifier: 'straight',
          distanceMeters: distMeters,
          durationSeconds: durationMins * 60.0,
          location: start,
        ),
        RouteStep(
          instruction: 'Arrive at venue destination',
          streetName: '',
          maneuverType: 'arrive',
          modifier: '',
          distanceMeters: 0,
          durationSeconds: 0,
          location: dest,
        ),
      ],
      totalDistanceKm: distKm,
      totalDurationMinutes: durationMins,
      summary: 'Direct route',
    );
  }
}
