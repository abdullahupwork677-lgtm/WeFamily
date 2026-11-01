import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/circle_repository.dart';
import '../constants/config.dart';
import '../utils/locale_provider.dart';
import 'location_service.dart';

enum TrackingStatus { idle, active, paused, denied, error }

class TrackingState {
  const TrackingState({
    this.status = TrackingStatus.idle,
    this.permission = LocationPermission.denied,
    this.ghost = false,
    this.placeLabel = '',
    this.batteryLevel,
    this.error,
  });

  final TrackingStatus status;
  final LocationPermission permission;
  final bool ghost;
  final String placeLabel;
  final int? batteryLevel;
  final String? error;

  bool get enabled => status == TrackingStatus.active;
  bool get foregroundGranted =>
      permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
  bool get backgroundGranted => permission == LocationPermission.always;
  bool get permanentlyDenied => permission == LocationPermission.deniedForever;

  TrackingState copyWith({
    TrackingStatus? status,
    LocationPermission? permission,
    bool? ghost,
    String? placeLabel,
    int? batteryLevel,
    String? error,
    bool clearError = false,
  }) {
    return TrackingState(
      status: status ?? this.status,
      permission: permission ?? this.permission,
      ghost: ghost ?? this.ghost,
      placeLabel: placeLabel ?? this.placeLabel,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Owns the only live GPS stream, decides when Firestore needs a write
/// (15 m moved, 30 s while moving, 2 min heartbeat) and keeps the foreground
/// service awake for background sharing.
class TrackingController extends Notifier<TrackingState> {
  static const String _ghostPrefKey = 'ghost_mode';
  static const String _pausedPrefKey = 'sharing_paused';

  final StreamController<Position> _positions =
      StreamController<Position>.broadcast();
  final Battery _battery = Battery();
  final Distance _distance = const Distance();
  bool? _savedGhost;
  bool? _savedPaused;

  StreamSubscription<Position>? _sub;
  StreamSubscription<BatteryState>? _batterySub;
  Timer? _heartbeat;
  Position? _lastPosition;
  LatLng? _anchor;
  DateTime? _anchorAt;
  LatLng? _geocodeAnchor;
  String _placeLabel = '';
  DateTime? _lastWriteAt;
  LatLng? _lastWriteAtPosition;
  DateTime? _lastBatteryRead;
  int? _batteryLevel;
  DateTime? _lastEmit;
  String? _circleId;
  bool _writing = false;
  bool _starting = false;
  bool _geocoding = false;
  bool _disposed = false;

  Stream<Position> get positions => _positions.stream;

  @override
  TrackingState build() {
    ref.onDispose(() {
      _disposed = true;
      _cancelSubscriptions();
      _positions.close();
    });
    return const TrackingState();
  }

  bool _hasPermission(LocationPermission permission) =>
      permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;

  Future<bool> _ghostEnabled() async {
    final saved = _savedGhost;
    if (saved != null) return saved;
    var ghost = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      ghost = prefs.getBool(_ghostPrefKey) ?? false;
    } catch (_) {
      // Default to sharing when storage is unavailable.
    }
    _savedGhost = ghost;
    return ghost;
  }

  Future<void> _saveGhost(bool ghost) async {
    _savedGhost = ghost;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_ghostPrefKey, ghost);
    } catch (_) {
      // Keep the in-memory value when storage fails.
    }
  }

  Future<bool> _sharingPaused() async {
    final saved = _savedPaused;
    if (saved != null) return saved;
    var paused = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      paused = prefs.getBool(_pausedPrefKey) ?? false;
    } catch (_) {
      // Default to sharing when storage is unavailable.
    }
    _savedPaused = paused;
    return paused;
  }

  Future<void> _savePaused(bool paused) async {
    _savedPaused = paused;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pausedPrefKey, paused);
    } catch (_) {
      // Keep the in-memory value when storage fails.
    }
  }

  Future<void> start({
    required String circleId,
    String? foregroundTitle,
    String? foregroundText,
  }) async {
    if (AppConfig.useMockData) return;
    _circleId = circleId;
    if (await _ghostEnabled()) {
      _setState(state.copyWith(status: TrackingStatus.paused, ghost: true));
      return;
    }
    if (await _sharingPaused()) {
      _setState(state.copyWith(status: TrackingStatus.paused));
      return;
    }
    if (_sub != null || _starting) return;
    _starting = true;
    try {
      final permission = await Geolocator.checkPermission();
      if (_disposed) return;
      if (!_hasPermission(permission)) {
        _setState(
          state.copyWith(status: TrackingStatus.denied, permission: permission),
        );
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (_disposed) return;
      if (!serviceEnabled) {
        _setState(state.copyWith(status: TrackingStatus.denied, error: 'gps'));
        return;
      }
      if (_sub != null) return;

      _setState(
        state.copyWith(
          status: TrackingStatus.active,
          permission: permission,
          clearError: true,
        ),
      );
      unawaited(_refreshBattery());
      _startBatteryListener();
      _heartbeat ??= Timer.periodic(
        const Duration(seconds: 60),
        (_) => _heartbeatTick(),
      );

      final cached = await Geolocator.getLastKnownPosition();
      final cachedFresh =
          cached != null &&
          DateTime.now().difference(cached.timestamp).inSeconds <= 90;
      if (cachedFresh && _sub == null) {
        _onPosition(cached);
      }

      _sub =
          Geolocator.getPositionStream(
            locationSettings: _locationSettings(
              foregroundTitle,
              foregroundText,
            ),
          ).listen(
            _onPosition,
            onError: (Object error) {
              _setState(
                state.copyWith(status: TrackingStatus.error, error: '$error'),
              );
            },
            cancelOnError: false,
          );
    } finally {
      _starting = false;
    }
  }

  Future<void> pause() async {
    await _cancelSubscriptions();
    await _savePaused(true);
    _setState(state.copyWith(status: TrackingStatus.paused));
    await _writeSharing(sharingLocation: false, ghostMode: state.ghost);
  }

  Future<void> resume() async {
    final circleId = _circleId;
    if (circleId == null) return;
    await _savePaused(false);
    await _saveGhost(false);
    await _writeSharing(sharingLocation: true, ghostMode: false);
    _setState(state.copyWith(ghost: false));
    await start(circleId: circleId);
  }

  Future<void> setGhost(bool ghost) async {
    if (ghost) {
      await _cancelSubscriptions();
      _setState(state.copyWith(ghost: true, status: TrackingStatus.paused));
      await _saveGhost(true);
      await _savePaused(false);
      await _writeSharing(sharingLocation: true, ghostMode: true);
    } else {
      _setState(state.copyWith(ghost: false));
      await _saveGhost(false);
      await _savePaused(false);
      await _writeSharing(sharingLocation: true, ghostMode: false);
      final circleId = _circleId;
      if (circleId != null) await start(circleId: circleId);
    }
  }

  /// Stops tracking on logout/leave; by default others see "Paused".
  Future<void> stop({bool writePaused = true}) async {
    await _cancelSubscriptions();
    if (writePaused) {
      await _writeSharing(sharingLocation: false, ghostMode: false);
    }
    await _saveGhost(false);
    await _savePaused(false);
    _circleId = null;
    _setState(const TrackingState(status: TrackingStatus.idle));
  }

  Future<LocationPermission> requestForegroundPermission() async {
    final permission = await Geolocator.requestPermission();
    _setState(state.copyWith(permission: permission));
    return permission;
  }

  Future<LocationPermission> requestBackgroundPermission() async {
    try {
      await ph.Permission.locationAlways.request();
    } catch (_) {}
    final permission = await Geolocator.checkPermission();
    _setState(state.copyWith(permission: permission));
    if (_hasPermission(permission)) {
      try {
        await ph.Permission.notification.request();
      } catch (_) {}
    }
    return permission;
  }

  Future<bool> requestBatteryOptimizationExemption() async {
    try {
      await ph.Permission.ignoreBatteryOptimizations.request();
      return (await ph.Permission.ignoreBatteryOptimizations.status).isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBatteryOptimizationIgnored() async {
    try {
      return (await ph.Permission.ignoreBatteryOptimizations.status).isGranted;
    } catch (_) {
      return true;
    }
  }

  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }

  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {}
  }

  Future<void> refreshPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      _setState(
        state.copyWith(
          permission: permission,
          status:
              _hasPermission(permission) &&
                  state.status == TrackingStatus.denied
              ? TrackingStatus.idle
              : null,
        ),
      );
    } catch (_) {}
  }

  LocationSettings _locationSettings(String? title, String? text) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        forceLocationManager: false,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: title ?? 'WeFamily',
          notificationText: text ?? 'Your family can see your live location',
          notificationIcon: const AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );
  }

  void _onPosition(Position position) {
    _lastPosition = position;
    unawaited(ref.read(locationServiceProvider).persist(position));
    _emit(position);
    _resolvePlace(position);
    _maybeWrite(position);
  }

  void _emit(Position position) {
    final now = DateTime.now();
    if (_lastEmit != null &&
        now.difference(_lastEmit!) < const Duration(seconds: 1)) {
      return;
    }
    _lastEmit = now;
    if (!_positions.isClosed) _positions.add(position);
  }

  void _maybeWrite(Position position, {bool force = false}) {
    if (_circleId == null) return;
    final current = LatLng(position.latitude, position.longitude);
    final now = DateTime.now();
    final moving = position.speed > 1.5;

    if (_anchor == null) {
      _anchor = current;
      _anchorAt = now;
    } else if (_distance(_anchor!, current) > 150) {
      _anchor = current;
      _anchorAt = now;
    }

    // At least 15 m of movement, but never more than one write per 10 s.
    final moved =
        (_lastWriteAtPosition == null ||
            _distance(_lastWriteAtPosition!, current) >= 15) &&
        (_lastWriteAt == null ||
            now.difference(_lastWriteAt!) >= const Duration(seconds: 10));
    final movingInterval =
        moving &&
        (_lastWriteAt == null ||
            now.difference(_lastWriteAt!) >= const Duration(seconds: 30));
    final heartbeat =
        _lastWriteAt == null ||
        now.difference(_lastWriteAt!) >= const Duration(seconds: 120);

    if (!force && !moved && !movingInterval && !heartbeat) return;
    _lastWriteAt = now;
    _lastWriteAtPosition = current;
    unawaited(_write(position, moving));
  }

  Future<void> _write(Position position, bool moving) async {
    if (_writing) return;
    final circleId = _circleId;
    final uid = _uid;
    if (circleId == null || uid == null || AppConfig.useMockData) return;
    _writing = true;
    try {
      final battery = await _readBattery();
      await ref
          .read(circleRepositoryProvider)
          .updateMyLocation(
            circleId: circleId,
            uid: uid,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            speed: position.speed,
            heading: position.heading,
            isMoving: moving,
            batteryLevel: battery,
            sinceAt: _anchorAt,
            placeLabel: _placeLabel,
          );
      if (!_disposed && state.error != null) {
        _setState(state.copyWith(clearError: true));
      }
    } catch (_) {
      if (!_disposed) {
        _setState(state.copyWith(error: 'sync'));
      }
    } finally {
      _writing = false;
    }
  }

  Future<void> _writeSharing({
    required bool sharingLocation,
    required bool ghostMode,
  }) async {
    final circleId = _circleId;
    final uid = _uid;
    if (circleId == null || uid == null || AppConfig.useMockData) return;
    try {
      await ref
          .read(circleRepositoryProvider)
          .updateSharingState(
            circleId: circleId,
            uid: uid,
            sharingLocation: sharingLocation,
            ghostMode: ghostMode,
          );
    } catch (_) {
      if (!_disposed) _setState(state.copyWith(error: 'sync'));
    }
  }

  Future<void> _resolvePlace(Position position) async {
    if (_geocoding) return;
    final current = LatLng(position.latitude, position.longitude);
    final needsGeocode =
        _geocodeAnchor == null || _distance(_geocodeAnchor!, current) > 200;
    if (!needsGeocode) return;
    _geocoding = true;
    _geocodeAnchor = current;
    try {
      final marks = await Geocoding(
        locale: Locale(ref.read(localeProvider).languageCode),
      ).placemarkFromCoordinates(position.latitude, position.longitude);
      if (marks.isNotEmpty) {
        final place = marks.first;
        final parts = [
          place.name,
          place.subLocality,
          place.locality,
        ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
        final label = parts.take(2).join(', ');
        if (label.isNotEmpty && label != _placeLabel) {
          _placeLabel = label;
          if (!_disposed) _setState(state.copyWith(placeLabel: label));
          final last = _lastPosition;
          if (last != null) _maybeWrite(last, force: true);
        }
      }
    } catch (_) {
      // Geocoding is best-effort; keep the previous label.
    } finally {
      _geocoding = false;
    }
  }

  Future<void> _heartbeatTick() async {
    if (_sub == null) return;
    final last = _lastPosition;
    if (last == null) return;
    final lastWrite = _lastWriteAt;
    if (lastWrite != null &&
        DateTime.now().difference(lastWrite) < const Duration(seconds: 110)) {
      return;
    }
    await _write(last, last.speed > 1.5);
  }

  Future<int?> _readBattery() async {
    final now = DateTime.now();
    if (_lastBatteryRead != null &&
        now.difference(_lastBatteryRead!) < const Duration(minutes: 2)) {
      return _batteryLevel;
    }
    await _refreshBattery();
    return _batteryLevel;
  }

  Future<void> _refreshBattery() async {
    try {
      final level = await _battery.batteryLevel;
      _batteryLevel = level;
      _lastBatteryRead = DateTime.now();
      if (!_disposed) _setState(state.copyWith(batteryLevel: level));
    } catch (_) {}
  }

  void _startBatteryListener() {
    _batterySub ??= _battery.onBatteryStateChanged.listen((_) {
      _refreshBattery();
    });
  }

  Future<void> _cancelSubscriptions() async {
    await _sub?.cancel();
    _sub = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    await _batterySub?.cancel();
    _batterySub = null;
  }

  String? get _uid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  void _setState(TrackingState next) {
    if (_disposed) return;
    state = next;
  }
}

final trackingControllerProvider =
    NotifierProvider<TrackingController, TrackingState>(TrackingController.new);

/// Position used to draw the current user: the live tracking stream in real
/// mode, the read-only stream in demo mode.
final mapPositionProvider = StreamProvider<Position?>((ref) {
  if (AppConfig.useMockData) {
    return ref.watch(livePositionStreamProvider);
  }
  return ref.watch(trackingControllerProvider.notifier).positions;
});

/// Persists whether the friendly permission sheet has been shown once.
const String kLocationPromptSeenKey = 'loc_prompt_seen';

Future<bool> shouldShowLocationPrompt() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(kLocationPromptSeenKey) == true) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever;
  } catch (_) {
    return false;
  }
}

Future<void> markLocationPromptSeen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLocationPromptSeenKey, true);
  } catch (_) {}
}
