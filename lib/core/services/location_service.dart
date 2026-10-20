import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const LocationSettings settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 15,
  );

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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }
}

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

/// Live device position. Emits null when permission is denied or GPS is off.
final livePositionProvider = StreamProvider<Position?>((ref) async* {
  final service = ref.watch(locationServiceProvider);
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
    if (first != null) yield first;
    yield* service.watch();
  } catch (_) {
    yield null;
  }
});
