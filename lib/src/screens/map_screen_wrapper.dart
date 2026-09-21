import 'package:flutter/material.dart';
import 'package:sports_chat_app/src/screens/map_screen.dart';

/// Platform-aware map screen wrapper
/// Uses OpenStreetMap
class MapScreenWrapper extends StatelessWidget {
  const MapScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // OpenStreetMap
    return const MapScreen();
  }
}
