import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../data/models/models.dart';
import '../constants/config.dart';

/// A route between two points, used for the "distance / ETA" marker.
class RouteInfo {
  const RouteInfo({
    required this.distanceMeters,
    required this.duration,
    required this.points,
    this.isEstimate = false,
  });

  final double distanceMeters;
  final Duration duration;
  final List<LatLng> points;

  /// True when the route is a straight-line fallback (Mapbox unavailable).
  final bool isEstimate;

  LatLng get midpoint {
    if (points.isEmpty) return const LatLng(0, 0);
    if (points.length == 1) return points.first;
    return points[points.length ~/ 2];
  }
}

const Distance _geoDistance = Distance();

/// Great-circle distance in meters.
double haversineMeters(LatLng a, LatLng b) =>
    _geoDistance.as(LengthUnit.Meter, a, b);

class _CachedRoute {
  const _CachedRoute(this.info, this.at);

  final RouteInfo info;
  final DateTime at;
}

/// Fetches real road routes from the Mapbox Directions API with a cached,
/// offline-safe straight-line estimate as fallback.
class DirectionsService {
  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _ttl = Duration(minutes: 2);
  static const Duration _timeout = Duration(seconds: 8);

  final Map<String, _CachedRoute> _cache = {};
  final Map<String, Future<RouteInfo>> _inFlight = {};

  static String _profile(MemberActivity activity) => switch (activity) {
    MemberActivity.walking => 'walking',
    MemberActivity.cycling => 'cycling',
    _ => 'driving',
  };

  static String _coordKey(LatLng p) =>
      '${p.latitude.toStringAsFixed(4)},${p.longitude.toStringAsFixed(4)}';

  Future<RouteInfo> routeFor({
    required LatLng from,
    required LatLng to,
    required MemberActivity activity,
  }) {
    final profile = _profile(activity);
    final key = '$profile:${_coordKey(from)}:${_coordKey(to)}';

    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.at) < _ttl) {
      return Future.value(cached.info);
    }

    final pending = _inFlight[key];
    if (pending != null) return pending;

    final future = _fetch(from: from, to: to, profile: profile)
        .then((info) {
          if (!info.isEstimate) {
            _cache[key] = _CachedRoute(info, DateTime.now());
          }
          return info;
        })
        .whenComplete(() => _inFlight.remove(key));
    _inFlight[key] = future;
    return future;
  }

  Future<RouteInfo> _fetch({
    required LatLng from,
    required LatLng to,
    required String profile,
  }) async {
    try {
      final uri = Uri.https(
        'api.mapbox.com',
        '/directions/v5/mapbox/$profile/'
            '${from.longitude},${from.latitude};${to.longitude},${to.latitude}',
        const {
          'geometries': 'geojson',
          'overview': 'full',
          'access_token': AppConfig.mapboxToken,
        },
      );
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first as Map<String, dynamic>;
          final distance = (route['distance'] as num?)?.toDouble();
          final duration = (route['duration'] as num?)?.toDouble();
          final geometry = route['geometry'] as Map<String, dynamic>?;
          final coordinates = geometry?['coordinates'] as List<dynamic>?;
          final points = <LatLng>[
            if (coordinates != null)
              for (final coordinate in coordinates)
                if (coordinate is List && coordinate.length >= 2)
                  LatLng(
                    (coordinate[1] as num).toDouble(),
                    (coordinate[0] as num).toDouble(),
                  ),
          ];
          if (distance != null && duration != null && points.length >= 2) {
            return RouteInfo(
              distanceMeters: distance,
              duration: Duration(seconds: duration.round()),
              points: points,
            );
          }
        }
      }
    } catch (_) {
      // Fall through to the offline estimate.
    }
    return estimate(from: from, to: to, activity: _activityFor(profile));
  }

  static MemberActivity _activityFor(String profile) => switch (profile) {
    'walking' => MemberActivity.walking,
    'cycling' => MemberActivity.cycling,
    _ => MemberActivity.driving,
  };

  /// Straight-line fallback with a road factor and mode-based speed.
  static RouteInfo estimate({
    required LatLng from,
    required LatLng to,
    required MemberActivity activity,
  }) {
    final meters = haversineMeters(from, to) * 1.3;
    final speedKmh = switch (activity) {
      MemberActivity.walking => 4.5,
      MemberActivity.cycling => 14.0,
      _ => 30.0,
    };
    final seconds = meters / (speedKmh * 1000 / 3600);
    return RouteInfo(
      distanceMeters: meters,
      duration: Duration(seconds: seconds.round()),
      points: [from, to],
      isEstimate: true,
    );
  }
}

final directionsServiceProvider = Provider<DirectionsService>(
  (ref) => DirectionsService(),
);
