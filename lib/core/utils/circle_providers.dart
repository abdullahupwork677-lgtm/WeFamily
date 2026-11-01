import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';
import '../../data/repositories/mock_data.dart';
import '../constants/config.dart';
import '../services/auth_service.dart';

/// Circle selected by the user when they belong to more than one circle.
const String kActiveCircleIdKey = 'circle_id';

class ActiveCircleIdNotifier extends Notifier<String?> {
  bool _disposed = false;

  @override
  String? build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_restore());
    return null;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(kActiveCircleIdKey);
      if (!_disposed && state == null && stored != null && stored.isNotEmpty) {
        state = stored;
      }
    } catch (_) {
      // Storage unavailable: fall back to the first circle.
    }
  }

  Future<void> select(String circleId) async {
    if (_disposed || circleId.isEmpty) return;
    state = circleId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kActiveCircleIdKey, circleId);
    } catch (_) {
      // Keep the in-memory selection even when storage fails.
    }
  }
}

final activeCircleIdProvider =
    NotifierProvider<ActiveCircleIdNotifier, String?>(
      ActiveCircleIdNotifier.new,
    );

/// UID of the signed-in user (mock user in demo mode).
final currentUidProvider = Provider<String?>((ref) {
  if (AppConfig.useMockData) return MockData.currentUser.id;
  final user = ref.watch(authStateProvider).value;
  return user?.uid;
});

/// Every circle the signed-in user belongs to, live from Firestore.
final myCirclesProvider = StreamProvider<List<FamilyCircle>>((ref) {
  if (AppConfig.useMockData) return Stream.value([MockData.circle]);
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <FamilyCircle>[]);
  return ref.watch(circleRepositoryProvider).watchMyCircles(uid);
});

/// The active circle: the explicitly selected one, else the first membership.
final myCircleProvider = StreamProvider<FamilyCircle?>((ref) {
  if (AppConfig.useMockData) return Stream.value(MockData.circle);
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  final activeId = ref.watch(activeCircleIdProvider);
  return ref.watch(circleRepositoryProvider).watchMyCircles(uid).map((circles) {
    if (circles.isEmpty) return null;
    for (final circle in circles) {
      if (circle.id == activeId) return circle;
    }
    return circles.first;
  });
});

/// Members of the current circle, live from Firestore.
final circleMembersProvider = StreamProvider<List<CircleMember>>((ref) {
  if (AppConfig.useMockData) return Stream.value(MockData.members);
  final circle = ref.watch(myCircleProvider).value;
  if (circle == null) return Stream.value(const <CircleMember>[]);
  return ref.watch(circleRepositoryProvider).watchMembers(circle.id);
});

/// Synchronous member list for the map/sheet (empty while loading).
final liveMembersProvider = Provider<List<CircleMember>>((ref) {
  return ref.watch(circleMembersProvider).value ?? const <CircleMember>[];
});

/// Cross-tab instruction to zoom the map to an SOS (or member) location.
class MapFocus {
  const MapFocus({
    required this.uid,
    required this.point,
    this.fromSos = false,
  });

  final String uid;
  final LatLng point;
  final bool fromSos;
}

class MapFocusNotifier extends Notifier<MapFocus?> {
  @override
  MapFocus? build() => null;

  void show(MapFocus focus) => state = focus;

  void consume() => state = null;
}

final mapFocusProvider = NotifierProvider<MapFocusNotifier, MapFocus?>(
  MapFocusNotifier.new,
);
