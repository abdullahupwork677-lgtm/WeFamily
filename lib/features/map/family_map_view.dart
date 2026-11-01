import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/services/directions_service.dart';
import '../../core/services/tile_cache.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/session_provider.dart';
import '../../data/models/models.dart';

class FamilyMapView extends ConsumerStatefulWidget {
  const FamilyMapView({super.key});

  @override
  ConsumerState<FamilyMapView> createState() => _FamilyMapViewState();
}

class _FamilyMapViewState extends ConsumerState<FamilyMapView>
    with TickerProviderStateMixin {
  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);
  static const double _routeRefreshMeters = 25;
  static const double _pinWidth = 124;
  static const double _pinHeight = 112;
  static const double _groundX = 62;
  static const double _groundY = 76;

  final MapController _mapController = MapController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  late final AnimationController _comet = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  late final AnimationController _live = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  Timer? _ageTimer;
  bool _mapReady = false;
  bool _shouldFit = true;
  bool _loadingRoutes = false;
  int _routeToken = 0;
  String? _originUid;
  String? _hotUid;
  List<CircleMember> _members = const <CircleMember>[];
  Map<String, RouteInfo> _routes = const <String, RouteInfo>{};
  Map<String, LatLng> _routeTargets = const <String, LatLng>{};
  LatLng? _originPoint;

  static final Alignment _pinAlignment = Marker.computePixelAlignment(
    width: _pinWidth,
    height: _pinHeight,
    left: _groundX,
    top: _groundY,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncMembers(ref.read(liveMembersProvider));
    });
    _ageTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ageTimer?.cancel();
    _pulse.dispose();
    _comet.dispose();
    _live.dispose();
    _shimmer.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<CircleMember> _locatedFrom(List<CircleMember> members, String? uid) {
    return [
      for (final member in members)
        if (member.lat != null &&
            member.lng != null &&
            (member.uid == uid || !member.ghostMode))
          member,
    ];
  }

  List<CircleMember> get _located =>
      _locatedFrom(_members, ref.read(currentUidProvider));

  List<CircleMember> _withLiveSelf(
    List<CircleMember> raw,
    String? selfUid,
    LatLng? livePoint,
  ) {
    if (selfUid == null || livePoint == null) return raw;
    final now = DateTime.now();
    var found = false;
    final merged = <CircleMember>[];
    for (final member in raw) {
      if (member.uid != selfUid) {
        merged.add(member);
        continue;
      }
      found = true;
      merged.add(
        member.copyWith(
          lat: livePoint.latitude,
          lng: livePoint.longitude,
          lastUpdated: now,
        ),
      );
    }
    if (!found) {
      final session = ref.read(sessionProvider).user;
      final name = session?.name.trim() ?? '';
      merged.add(
        CircleMember(
          uid: selfUid,
          name: name.isEmpty ? 'You' : name,
          relation: 'self',
          photoUrl: session?.photoUrl,
          lat: livePoint.latitude,
          lng: livePoint.longitude,
          lastUpdated: now,
        ),
      );
    }
    return merged;
  }

  CircleMember? _byUid(List<CircleMember> members, String? uid) {
    if (uid == null) return null;
    for (final member in members) {
      if (member.uid == uid) return member;
    }
    return null;
  }

  void _syncMembers(List<CircleMember> raw) {
    final selfUid = ref.read(currentUidProvider);
    final live = ref.read(mapPositionProvider).value;
    final livePoint = live == null
        ? null
        : LatLng(live.latitude, live.longitude);
    final merged = _withLiveSelf(raw, selfUid, livePoint);
    final located = _locatedFrom(merged, selfUid);

    var origin = _byUid(located, _originUid);
    if (origin == null) {
      _originUid = _byUid(located, selfUid)?.uid;
      _originUid ??= located.isNotEmpty ? located.first.uid : null;
      origin = _byUid(located, _originUid);
    }

    final originPoint = origin == null
        ? null
        : LatLng(origin.lat!, origin.lng!);
    final targets = <String, LatLng>{
      for (final member in located)
        if (member.uid != _originUid)
          member.uid: LatLng(member.lat!, member.lng!),
    };

    var refresh =
        originPoint != null &&
        (!_routes.keys.toSet().containsAll(targets.keys));
    if (!refresh &&
        _originPoint != null &&
        originPoint != null &&
        haversineMeters(_originPoint!, originPoint) > _routeRefreshMeters) {
      refresh = true;
    }
    if (!refresh) {
      for (final entry in targets.entries) {
        final previous = _routeTargets[entry.key];
        if (previous == null ||
            !_routes.containsKey(entry.key) ||
            haversineMeters(previous, entry.value) > _routeRefreshMeters) {
          refresh = true;
          break;
        }
      }
    }

    setState(() {
      _members = merged;
      _originPoint = originPoint;
      _routeTargets = targets;
    });

    if (originPoint == null) {
      if (_routes.isNotEmpty || _loadingRoutes) {
        setState(() {
          _routes = const <String, RouteInfo>{};
          _loadingRoutes = false;
        });
      }
      return;
    }

    if (refresh) _refreshRoutes(originPoint);
    if (_shouldFit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll());
    }
  }

  Future<void> _refreshRoutes(LatLng originPoint) async {
    final token = ++_routeToken;
    final fromUid = _originUid;
    final targets = [
      for (final member in _located)
        if (member.uid != fromUid) member,
    ];
    final seeded = <String, RouteInfo>{
      for (final member in targets)
        member.uid: DirectionsService.estimate(
          from: originPoint,
          to: LatLng(member.lat!, member.lng!),
          activity: MemberActivity.driving,
        ),
    };

    setState(() {
      _routes = seeded;
      _loadingRoutes = targets.isNotEmpty;
    });
    if (targets.isEmpty) return;

    final service = ref.read(directionsServiceProvider);
    try {
      final entries = await Future.wait([
        for (final member in targets)
          service
              .routeFor(
                from: originPoint,
                to: LatLng(member.lat!, member.lng!),
                activity: MemberActivity.driving,
              )
              .then((route) => MapEntry(member.uid, route)),
      ]);
      if (!mounted || token != _routeToken) return;
      setState(() {
        _routes = Map<String, RouteInfo>.fromEntries(entries);
        _loadingRoutes = false;
      });
    } catch (_) {
      if (!mounted || token != _routeToken) return;
      setState(() => _loadingRoutes = false);
    }
  }

  void _setOrigin(CircleMember member) {
    if (_originUid == member.uid || member.lat == null || member.lng == null) {
      return;
    }
    setState(() {
      _originUid = member.uid;
      _hotUid = null;
      _originPoint = LatLng(member.lat!, member.lng!);
    });
    _refreshRoutes(_originPoint!);
  }

  void _fitAll() {
    if (!mounted || !_mapReady || !_shouldFit) return;
    final located = _located;
    if (located.isEmpty) return;
    _shouldFit = false;
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          for (final member in located) LatLng(member.lat!, member.lng!),
        ],
        padding: const EdgeInsets.fromLTRB(56, 52, 56, 56),
        maxZoom: 15.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selfUid = ref.watch(currentUidProvider);
    final livePos = ref.watch(mapPositionProvider).value;
    final livePoint = livePos == null
        ? null
        : LatLng(livePos.latitude, livePos.longitude);
    final rawMembers = ref.watch(liveMembersProvider);
    final members = _withLiveSelf(rawMembers, selfUid, livePoint);

    ref.listen<List<CircleMember>>(liveMembersProvider, (_, next) {
      _syncMembers(next);
    });
    ref.listen(mapPositionProvider, (_, next) {
      if (next.value == null) return;
      _syncMembers(ref.read(liveMembersProvider));
    });
    ref.listen<MapFocus?>(mapFocusProvider, (_, next) {
      if (next == null) return;
      if (next.fromSos) {
        setState(() => _hotUid = next.uid);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(next.point, 15.5);
        } catch (_) {}
      });
      ref.read(mapFocusProvider.notifier).consume();
    });

    final located = _locatedFrom(members, selfUid);
    var origin = _byUid(located, _originUid);
    origin ??= _byUid(located, selfUid);
    origin ??= located.isNotEmpty ? located.first : null;

    final paletteByUid = <String, List<Color>>{
      for (var i = 0; i < members.length; i++)
        members[i].uid: AhlColors
            .mapAvatarGradients[i % AhlColors.mapAvatarGradients.length],
    };

    final rows = <CircleMember>[
      for (final member in members)
        if (origin == null || member.uid != origin.uid) member,
    ];
    rows.sort((a, b) {
      final ad = _routes[a.uid]?.distanceMeters ?? double.infinity;
      final bd = _routes[b.uid]?.distanceMeters ?? double.infinity;
      final byDistance = ad.compareTo(bd);
      return byDistance != 0 ? byDistance : a.name.compareTo(b.name);
    });

    final sheetMaxHeight = MediaQuery.sizeOf(context).height * 0.46;

    return SafeArea(
      bottom: false,
      child: ColoredBox(
        color: AhlColors.background,
        child: Column(
          children: [
            _buildHeader(l10n, members.length),
            Expanded(child: _buildMap(l10n, located, origin, paletteByUid)),
            _DistancesSheet(
              l10n: l10n,
              rows: rows,
              routes: _routes,
              origin: origin,
              isOriginSelf: origin != null && origin.uid == selfUid,
              hotUid: _hotUid,
              paletteByUid: paletteByUid,
              onHot: (uid) {
                setState(() => _hotUid = _hotUid == uid ? null : uid);
              },
              maxHeight: sheetMaxHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, int memberCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerTitle(text: l10n.familyMapTitle, animation: _shimmer),
                const SizedBox(height: 2),
                Text(
                  l10n.familyMapMembersHint(memberCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AhlColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _LivePill(label: l10n.familyMapLive, animation: _live),
        ],
      ),
    );
  }

  Widget _buildMap(
    AppLocalizations l10n,
    List<CircleMember> located,
    CircleMember? origin,
    Map<String, List<Color>> paletteByUid,
  ) {
    final originUid = origin?.uid;
    final routeMembers =
        [
          for (final member in located)
            if (member.uid != originUid && _routes[member.uid] != null) member,
        ]..sort(
          (a, b) =>
              (a.uid == _hotUid ? 1 : 0).compareTo(b.uid == _hotUid ? 1 : 0),
        );

    final pins = [
      for (final member in located)
        if (member.uid != originUid) member,
      ?origin,
    ];

    final center = origin != null
        ? LatLng(origin.lat!, origin.lng!)
        : (located.isNotEmpty
              ? LatLng(located.first.lat!, located.first.lng!)
              : _fallbackCenter);

    final polylines = <Polyline>[];
    for (final member in routeMembers) {
      final route = _routes[member.uid]!;
      final hot = member.uid == _hotUid;
      final colors = hot
          ? const [AhlColors.gold, AhlColors.goldLight]
          : const [AhlColors.primary, AhlColors.primaryGradientEnd];
      polylines.add(
        Polyline(
          points: route.points,
          strokeWidth: 10,
          color: AhlColors.surface.withValues(alpha: 0.95),
        ),
      );
      polylines.add(
        Polyline(
          points: route.points,
          strokeWidth: hot ? 6.5 : 5,
          color: colors.first,
          gradientColors: colors,
        ),
      );
      polylines.add(
        Polyline(
          points: route.points,
          strokeWidth: 1.8,
          color: AhlColors.surface.withValues(alpha: 0.9),
          pattern: StrokePattern.dashed(
            segments: const [4, 10],
            patternFit: PatternFit.none,
          ),
        ),
      );
    }

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                backgroundColor: AhlColors.mapStage,
                onMapReady: () {
                  _mapReady = true;
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _fitAll(),
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConfig.tileLightUrl,
                  userAgentPackageName: 'com.wefamily.wefamily',
                  tileProvider: CachedTileProvider(),
                ),
                const RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  showFlutterMapAttribution: false,
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                    TextSourceAttribution('Mapbox'),
                  ],
                ),
                if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                if (routeMembers.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      for (final member in routeMembers)
                        Marker(
                          point: _pointAtFraction(
                            _routes[member.uid]!.points,
                            .5,
                          ),
                          width: 220,
                          height: 30,
                          child: _RouteLabel(
                            text: _routeLabel(l10n, _routes[member.uid]!),
                            color: member.uid == _hotUid
                                ? AhlColors.gold
                                : AhlColors.primary,
                          ),
                        ),
                    ],
                  ),
                if (routeMembers.isNotEmpty)
                  AnimatedBuilder(
                    animation: _comet,
                    builder: (context, _) {
                      final t = _comet.value;
                      return MarkerLayer(
                        markers: [
                          for (var i = 0; i < routeMembers.length; i++)
                            Marker(
                              point: _pointAtFraction(
                                _routes[routeMembers[i].uid]!.points,
                                (t + i * 0.27) % 1,
                              ),
                              width: 14,
                              height: 14,
                              child: _RouteComet(
                                color: routeMembers[i].uid == _hotUid
                                    ? AhlColors.gold
                                    : AhlColors.primary,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                if (pins.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      for (final member in pins)
                        Marker(
                          point: LatLng(member.lat!, member.lng!),
                          width: _pinWidth,
                          height: _pinHeight,
                          alignment: _pinAlignment,
                          child: FamilyMapPin(
                            member: member,
                            selected: member.uid == originUid,
                            pulse: _pulse,
                            palette:
                                paletteByUid[member.uid] ??
                                AhlColors.mapAvatarGradients.first,
                            onTap: () => _setOrigin(member),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _MapLegend(
              label: l10n.familyMapLegend,
              loading: _loadingRoutes,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistancesSheet extends StatelessWidget {
  const _DistancesSheet({
    required this.l10n,
    required this.rows,
    required this.routes,
    required this.origin,
    required this.isOriginSelf,
    required this.hotUid,
    required this.paletteByUid,
    required this.onHot,
    required this.maxHeight,
  });

  final AppLocalizations l10n;
  final List<CircleMember> rows;
  final Map<String, RouteInfo> routes;
  final CircleMember? origin;
  final bool isOriginSelf;
  final String? hotUid;
  final Map<String, List<Color>> paletteByUid;
  final ValueChanged<String> onHot;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    int? firstRoute;
    int? lastRoute;
    for (var i = 0; i < rows.length; i++) {
      if (routes[rows[i].uid] != null) {
        firstRoute ??= i;
        lastRoute = i;
      }
    }
    final twoOrMore = firstRoute != null && firstRoute != lastRoute;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AhlColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: AhlColors.sheetShadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AhlColors.line.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  l10n.familyMapFrom,
                  style: const TextStyle(fontSize: 12, color: AhlColors.muted),
                ),
                const Spacer(),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    origin == null
                        ? '—'
                        : isOriginSelf
                        ? '${origin!.name} (${l10n.you})'
                        : origin!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AhlColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final member = rows[index];
                final route = routes[member.uid];
                final palette =
                    paletteByUid[member.uid] ??
                    AhlColors.mapAvatarGradients.first;
                final badge = index == firstRoute
                    ? _DistanceBadge(
                        label: l10n.familyMapNearest,
                        background: AhlColors.gold,
                        foreground: AhlColors.ink,
                      )
                    : twoOrMore && index == lastRoute
                    ? _DistanceBadge(
                        label: l10n.familyMapFarthest,
                        background: AhlColors.orbitChip,
                        foreground: AhlColors.primary,
                      )
                    : null;
                return _DistanceRow(
                  l10n: l10n,
                  member: member,
                  route: route,
                  palette: palette,
                  badge: badge,
                  selected: member.uid == hotUid,
                  onTap: route == null ? null : () => onHot(member.uid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceRow extends StatelessWidget {
  const _DistanceRow({
    required this.l10n,
    required this.member,
    required this.route,
    required this.palette,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final CircleMember member;
  final RouteInfo? route;
  final List<Color> palette;
  final Widget? badge;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final relation = member.relation.trim();
    final seen = _seenLabel(l10n, member.lastUpdated);
    final subtitle = relation.isEmpty ? seen : '$relation · $seen';
    final minutes = route == null
        ? null
        : (route!.duration.inMinutes < 1 ? 1 : route!.duration.inMinutes);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AhlColors.orbitChip : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: AhlColors.gold, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: palette,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _initial(member.name),
                style: const TextStyle(
                  color: AhlColors.surface,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AhlColors.ink,
                          ),
                        ),
                      ),
                      ?badge,
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AhlColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    route == null
                        ? '—'
                        : formatDistance(l10n, route!.distanceMeters),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: route == null
                          ? AhlColors.muted
                          : AhlColors.primary,
                    ),
                  ),
                  Text(
                    route == null ? '—' : l10n.familyMapMinDrive(minutes!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AhlColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.label, required this.loading});

  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AhlColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 5,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              gradient: AhlColors.primaryGradient,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AhlColors.ink,
            ),
          ),
          if (loading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: AhlColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShimmerTitle extends StatelessWidget {
  const _ShimmerTitle({required this.text, required this.animation});

  final String text;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              AhlColors.primary,
              AhlColors.primaryGradientEnd,
              AhlColors.primary,
            ],
            stops: const [0, .5, 1],
            begin: Alignment(-1.5 + 3 * t, 0),
            end: Alignment(1.5 + 3 * t, 0),
          ).createShader(bounds),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
              color: AhlColors.surface,
            ),
          ),
        );
      },
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.label, required this.animation});

  final String label;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AhlColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = animation.value;
              return Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AhlColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AhlColors.success.withValues(alpha: .55 * (1 - t)),
                      spreadRadius: 8 * t,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AhlColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyMapPin extends StatelessWidget {
  const FamilyMapPin({
    super.key,
    required this.member,
    required this.selected,
    required this.pulse,
    required this.palette,
    required this.onTap,
  });

  final CircleMember member;
  final bool selected;
  final Animation<double> pulse;
  final List<Color> palette;
  final VoidCallback onTap;

  static const double _groundX = _FamilyMapViewState._groundX;
  static const double _groundY = _FamilyMapViewState._groundY;

  @override
  Widget build(BuildContext context) {
    final bubble = selected ? 46.0 : 40.0;
    final gradient = LinearGradient(
      colors: palette,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final t = pulse.value;
          final bob = selected ? -4 * math.sin(t * 2 * math.pi) : 0.0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _groundX - 7,
                top: _groundY - 7,
                child: Transform.scale(
                  scale: 1 + 3 * t,
                  child: Opacity(
                    opacity: (1 - t) * .4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AhlColors.primaryGradientEnd,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _groundX - bubble / 2,
                top: _groundY - 12 - bubble + bob,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: bubble,
                      height: bubble,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                        border: Border.all(
                          color: selected ? AhlColors.gold : AhlColors.surface,
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: palette.first.withValues(alpha: .35),
                            blurRadius: selected ? 16 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initial(member.name),
                        style: TextStyle(
                          color: AhlColors.surface,
                          fontSize: selected ? 17 : 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(16, 12),
                      painter: _PinTailPainter(palette),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: _groundY + 3,
                child: _OutlinedName(name: member.name, selected: selected),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

class _OutlinedName extends StatelessWidget {
  const _OutlinedName({required this.name, required this.selected});

  final String name;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );
    return SizedBox(
      width: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.5
                ..strokeJoin = StrokeJoin.round
                ..color = AhlColors.surface,
            ),
          ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: base.copyWith(
              color: selected ? AhlColors.primary : AhlColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLabel extends StatelessWidget {
  const _RouteLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AhlColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
          boxShadow: AhlColors.softShadowSmall,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: AhlColors.ink,
          ),
        ),
      ),
    );
  }
}

class _RouteComet extends StatelessWidget {
  const _RouteComet({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AhlColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

String _routeLabel(AppLocalizations l10n, RouteInfo route) {
  final km = l10n.kmValue((route.distanceMeters / 1000).toStringAsFixed(1));
  final minutes = route.duration.inMinutes < 1 ? 1 : route.duration.inMinutes;
  return '$km · ${l10n.minValue(minutes.toString())}';
}

String _seenLabel(AppLocalizations l10n, DateTime? updated) {
  if (updated == null) return l10n.familyMapNow;
  final difference = DateTime.now().difference(updated);
  if (difference.inMinutes < 1) return l10n.familyMapNow;
  if (difference.inHours < 1) return l10n.familyMapMinAgo(difference.inMinutes);
  if (difference.inDays < 1) return l10n.familyMapHourAgo(difference.inHours);
  return l10n.familyMapDayAgo(difference.inDays);
}

String _initial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, 1).toUpperCase();
}

LatLng _pointAtFraction(List<LatLng> points, double fraction) {
  if (points.isEmpty) return _FamilyMapViewState._fallbackCenter;
  if (points.length == 1) return points.first;
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += haversineMeters(points[i - 1], points[i]);
  }
  final target = total * fraction.clamp(0.0, 1.0);
  var travelled = 0.0;
  for (var i = 1; i < points.length; i++) {
    final segment = haversineMeters(points[i - 1], points[i]);
    if (travelled + segment >= target) {
      final f = segment == 0 ? 0.0 : (target - travelled) / segment;
      return LatLng(
        points[i - 1].latitude +
            (points[i].latitude - points[i - 1].latitude) * f,
        points[i - 1].longitude +
            (points[i].longitude - points[i - 1].longitude) * f,
      );
    }
    travelled += segment;
  }
  return points.last;
}
