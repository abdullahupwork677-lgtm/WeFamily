import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const LocationSettings settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 15,
  );

  DateTime _lastPersist = DateTime.fromMillisecondsSinceEpoch(0);

  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Stream<Position> watch() =>
      Geolocator.getPositionStream(locationSettings: settings);

  Future<Position?> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    if (!await ensurePermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Persists the last fix at most every 30 s so the next app launch can
  /// render the map at the right place immediately.
  Future<void> persist(Position position) async {
    final now = DateTime.now();
    if (now.difference(_lastPersist).inSeconds < 30) return;
    _lastPersist = now;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_lng', position.longitude);
    } catch (_) {}
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

/// Cached last known position (from the previous app run), if any.
/// Overridden in `main()` after reading SharedPreferences.
final lastKnownCenterProvider = Provider<LatLng?>((ref) => null);

const Duration _minPositionInterval = Duration(seconds: 1);

/// Raw stream of the live device position. Emits null when permission is
/// denied or GPS is off. Throttled to at most 1 event per second.
final livePositionStreamProvider = Provider<Stream<Position?>>((ref) {
  final service = ref.watch(locationServiceProvider);
  return () async* {
    try {
      if (!await service.ensurePermission()) {
        yield null;
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        yield null;
        return;
      }
      final first = await service.current();
      DateTime? lastEmitted;
      if (first != null) {
        lastEmitted = DateTime.now();
        unawaited(service.persist(first));
        yield first;
      }
      await for (final position in service.watch()) {
        final now = DateTime.now();
        if (lastEmitted != null &&
            now.difference(lastEmitted) < _minPositionInterval) {
          continue;
        }
        lastEmitted = now;
        unawaited(service.persist(position));
        yield position;
      }
    } catch (_) {
      yield null;
    }
  }();
});

/// Live device position for demo mode.
final livePositionProvider = StreamProvider<Position?>(
  (ref) => ref.watch(livePositionStreamProvider),
);
