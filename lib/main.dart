import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/constants/config.dart';
import 'core/services/location_service.dart';
import 'core/services/tile_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    if (!AppConfig.useMockData) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }
  } catch (_) {
    // Run without backend (mock mode) if Firebase config is unavailable.
  }
  await TileCacheService.initialise();

  LatLng? lastKnown;
  try {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_lat');
    final lng = prefs.getDouble('last_lng');
    if (lat != null && lng != null) lastKnown = LatLng(lat, lng);
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [lastKnownCenterProvider.overrideWithValue(lastKnown)],
      child: const WeFamilyApp(),
    ),
  );
}
