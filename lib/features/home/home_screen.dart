import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/services/directions_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/tile_cache.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/presence_mode_ui.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/icon_3d.dart';
import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';
import '../circle/circle_management_screen.dart';
import '../location/location_permission_sheet.dart';
import '../member/member_detail_sheet.dart';
import '../notifications/notifications_screen.dart';
import '../shell/shell_tab_provider.dart';
import 'widgets/animated_members_layer.dart';
import 'widgets/distance_eta_pill.dart';
import 'widgets/home_sheet.dart';
import 'widgets/sos_marker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  int _styleIndex = 2;
  int _category = 0;
  String? _selectedUid;
  bool _tipDismissed = false;
  bool _centeredOnMe = false;
  bool _showSkeleton = true;
  bool _modeSaving = false;
  RouteInfo? _route;
  String? _routeUid;
  LatLng? _routeFrom;
  LatLng? _routeTo;
  bool _routeLoading = false;
  int _routeRequest = 0;
  Timer? _staleTimer;

  static const double _sheetPeek = 0.22;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAskLocationPermission();
      _ensureTracking();
    });
    _staleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _staleTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensureTracking();
    }
  }

  Future<void> _ensureTracking() async {
    if (AppConfig.useMockData || !mounted) return;
    final circle =
        ref.read(myCircleProvider).value ?? ref.read(sessionProvider).circle;
    if (circle == null) return;
    if (ref.read(trackingControllerProvider).status == TrackingStatus.active) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    await ref
        .read(trackingControllerProvider.notifier)
        .start(
          circleId: circle.id,
          foregroundTitle: l10n.sharingNotificationTitle,
          foregroundText: l10n.sharingNotificationBody,
        );
  }

  Future<void> _maybeAskLocationPermission() async {
    if (AppConfig.useMockData || !mounted) return;
    if (!await shouldShowLocationPrompt()) {
      await _ensureTracking();
      return;
    }
    if (!mounted) return;
    await markLocationPromptSeen();
    if (!mounted) return;
    await showLocationPermissionSheet(context);
    await _ensureTracking();
  }

  String get _tileUrl => switch (_styleIndex) {
    1 => AppConfig.tileStandardUrl,
    2 => AppConfig.tileSatelliteUrl,
    _ => AppConfig.tileLightUrl,
  };

  List<String> _styleLabels(AppLocalizations l10n) => [
    l10n.lightMap,
    l10n.standardMap,
    l10n.mapRealistic,
  ];

  List<IconData> get _styleIcons => const [
    Icons.light_mode_rounded,
    Icons.map_rounded,
    Icons.satellite_alt_rounded,
  ];

  void _switchTab(int index) =>
      ref.read(shellTabProvider.notifier).select(index);

  void _onMapReady() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showSkeleton = false);
    });
  }

  List<CircleMember> _located(List<CircleMember> members, String? uid) =>
      members
          .where(
            (m) =>
                m.lat != null &&
                m.lng != null &&
                (m.uid == uid || !m.ghostMode),
          )
          .toList();

  CircleMember? _byUid(List<CircleMember> members, String? uid) {
    for (final m in members) {
      if (m.uid == uid) return m;
    }
    return null;
  }

  CircleMember _selfFallback({
    required String uid,
    required AppUser? user,
    required Position livePos,
    required TrackingState tracking,
    required DateTime now,
    required String fallbackName,
  }) {
    final name = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name
        : fallbackName;
    return CircleMember(
      uid: uid,
      name: name,
      relation: 'self',
      photoUrl: user?.photoUrl,
      role: 'member',
      sharingLocation: tracking.enabled,
      ghostMode: tracking.ghost,
      lat: livePos.latitude,
      lng: livePos.longitude,
      batteryLevel: tracking.batteryLevel,
      placeLabel: tracking.placeLabel,
      lastUpdated: now,
      isMoving: livePos.speed > 1.5,
      speedKmh: livePos.speed * 3.6,
      headingDeg: livePos.heading,
    );
  }

  LatLng? _selfLatLng() {
    final position = ref.read(mapPositionProvider).value;
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    final uid = ref.read(currentUidProvider);
    final self = _byUid(ref.read(liveMembersProvider), uid);
    if (self?.lat != null && self?.lng != null) {
      return LatLng(self!.lat!, self.lng!);
    }
    return null;
  }

  void _clearRoute() {
    if (_route == null && _routeUid == null && !_routeLoading) return;
    setState(() {
      _route = null;
      _routeUid = null;
      _routeFrom = null;
      _routeTo = null;
      _routeLoading = false;
    });
  }

  Future<void> _updateRoute(
    CircleMember member,
    LatLng from, {
    bool force = false,
  }) async {
    final to = LatLng(member.lat!, member.lng!);
    if (!force &&
        _routeUid == member.uid &&
        _routeFrom != null &&
        _routeTo != null &&
        haversineMeters(_routeFrom!, from) < 150 &&
        haversineMeters(_routeTo!, to) < 150) {
      return;
    }
    final request = ++_routeRequest;
    final changedTarget = _routeUid != member.uid;
    setState(() {
      _routeUid = member.uid;
      _routeFrom = from;
      _routeTo = to;
      _routeLoading = true;
      if (changedTarget) _route = null;
    });
    final info = await ref
        .read(directionsServiceProvider)
        .routeFor(from: from, to: to, activity: member.activity);
    if (!mounted || request != _routeRequest || _selectedUid != member.uid) {
      return;
    }
    setState(() {
      _route = info;
      _routeLoading = false;
    });
  }

  Future<void> _refreshRouteForSelected({bool force = false}) async {
    final uid = ref.read(currentUidProvider);
    final selected = _byUid(ref.read(liveMembersProvider), _selectedUid);
    if (selected == null ||
        selected.uid == uid ||
        selected.lat == null ||
        selected.lng == null) {
      _clearRoute();
      return;
    }
    final from = _selfLatLng();
    if (from == null) return;
    await _updateRoute(selected, from, force: force);
  }

  void _focusSos(CircleMember member) {
    if (!member.hasActiveSos) return;
    setState(() {
      _selectedUid = null;
      _route = null;
      _routeUid = null;
      _routeFrom = null;
      _routeTo = null;
      _routeLoading = false;
    });
    _mapController.move(LatLng(member.sosLat!, member.sosLng!), 16.5);
    showMemberDetailSheet(
      context,
      member,
      selfPosition: _selfLatLng(),
      selfUid: ref.read(currentUidProvider),
    );
  }

  void _selectAndShow(CircleMember member) {
    setState(() => _selectedUid = member.uid);
    if (member.lat != null && member.lng != null) {
      final zoom = _mapController.camera.zoom;
      _mapController.move(
        LatLng(member.lat!, member.lng!),
        zoom < 14 ? 15 : zoom,
      );
    }
    unawaited(_refreshRouteForSelected(force: true));
    showMemberDetailSheet(
      context,
      member,
      selfPosition: _selfLatLng(),
      selfUid: ref.read(currentUidProvider),
    );
  }

  void _recenter(Position? livePos, List<CircleMember> members, String? uid) {
    if (livePos != null) {
      _mapController.move(
        LatLng(livePos.latitude, livePos.longitude),
        _mapController.camera.zoom < 15.5 ? 16.5 : _mapController.camera.zoom,
      );
      return;
    }
    final me = members.where((m) => m.uid == uid && m.lat != null).toList();
    if (me.isNotEmpty) {
      _mapController.move(
        LatLng(me.first.lat!, me.first.lng!),
        _mapController.camera.zoom < 15.5 ? 16.5 : _mapController.camera.zoom,
      );
    }
  }

  void _fitAll(List<CircleMember> located) {
    if (located.length < 2) return;
    final points = located.map((m) => LatLng(m.lat!, m.lng!)).toList();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(70),
      ),
    );
  }

  Future<void> _shareInvite(FamilyCircle? circle) async {
    final l10n = AppLocalizations.of(context);
    final code = circle?.inviteCode;
    if (code == null || code.isEmpty) {
      _snack(l10n.comingSoon);
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        text: l10n.shareInviteMessage(
          code,
          '${AppConfig.defaultInviteBase}$code',
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLayers(List<CircleMember> located) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final labels = _styleLabels(l10n);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AhlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AhlColors.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.mapLayers,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (var i = 0; i < labels.length; i++)
              ListTile(
                leading: Icon(_styleIcons[i]),
                title: Text(labels[i]),
                trailing: _styleIndex == i
                    ? const Icon(Icons.check_rounded, color: AhlColors.primary)
                    : null,
                onTap: () {
                  setState(() => _styleIndex = i);
                  Navigator.of(context).pop();
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.zoom_out_map_rounded),
              title: Text(l10n.fitAllMembers),
              onTap: () {
                Navigator.of(context).pop();
                _fitAll(located);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _switchCircle(FamilyCircle circle) async {
    await ref.read(activeCircleIdProvider.notifier).select(circle.id);
    await ref.read(sessionProvider.notifier).adoptCircle(circle);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await ref
        .read(trackingControllerProvider.notifier)
        .start(
          circleId: circle.id,
          foregroundTitle: l10n.sharingNotificationTitle,
          foregroundText: l10n.sharingNotificationBody,
        );
  }

  Future<void> _openCircleSwitcher(FamilyCircle? circle) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    var circles = <FamilyCircle>[];
    final uid = ref.read(currentUidProvider);
    if (uid != null && !AppConfig.useMockData) {
      try {
        circles = await ref
            .read(circleRepositoryProvider)
            .findMyCircles(uid)
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Offline: fall back to the live provider / active circle.
      }
    }
    if (circles.isEmpty) {
      circles = ref.read(myCirclesProvider).value ?? const <FamilyCircle>[];
    }
    if (circles.isEmpty && circle != null) circles = [circle];
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AhlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myCircle,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (circles.length > 1)
                for (final item in circles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item.id == circle?.id
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: item.id == circle?.id
                          ? AhlColors.primary
                          : AhlColors.inkMedium,
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.memberUids.length} · ${item.inviteCode}',
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(color: AhlColors.inkMedium),
                    ),
                    onTap: item.id == circle?.id
                        ? () => Navigator.of(sheetContext).pop()
                        : () {
                            Navigator.of(sheetContext).pop();
                            unawaited(_switchCircle(item));
                          },
                  )
              else
                Text(
                  circle == null
                      ? l10n.loading
                      : '${circle.memberUids.length} · ${circle.inviteCode}',
                  style: Theme.of(sheetContext).textTheme.bodyMedium
                      ?.copyWith(color: AhlColors.inkMedium),
                ),
              const SizedBox(height: 20),
              AhlButton(
                label: l10n.manageCircle,
                icon: Icons.settings_rounded,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CircleManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              AhlButton(
                label: l10n.shareInvite,
                icon: Icons.share_rounded,
                gradient: false,
                onPressed: () => _shareInvite(circle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openModePicker(CircleMember? self) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PresenceMode? current = self?.presenceMode;
    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AhlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        final double tileWidth =
            (MediaQuery.sizeOf(sheetContext).width - 48 - 10) / 2;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AhlColors.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.setMode,
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.modeSubtitle,
                  style: Theme.of(sheetContext).textTheme.bodyMedium
                      ?.copyWith(color: AhlColors.inkMedium),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ModeTile(
                      width: tileWidth,
                      icon: Icons.auto_awesome_rounded,
                      asset: 'clock',
                      color: AhlColors.inkMedium,
                      label: l10n.modeAuto,
                      selected: current == null,
                      onTap: () => Navigator.of(sheetContext).pop('auto'),
                    ),
                    for (final mode in PresenceMode.values)
                      _ModeTile(
                        width: tileWidth,
                        icon: mode.icon,
                        asset: mode.icon3d,
                        color: mode.color,
                        label: mode.label(l10n),
                        selected: current == mode,
                        onTap: () => Navigator.of(sheetContext).pop(mode.name),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    if (result == null || !mounted) return;
    await _setPresenceMode(
      result == 'auto' ? null : presenceModeFromString(result),
    );
  }

  Future<void> _setPresenceMode(PresenceMode? mode) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final circle = ref.read(myCircleProvider).value;
    final uid = ref.read(currentUidProvider);
    if (circle == null || uid == null) return;
    setState(() => _modeSaving = true);
    try {
      await ref
          .read(circleRepositoryProvider)
          .updatePresenceMode(circleId: circle.id, uid: uid, mode: mode);
      if (!mounted) return;
      _snack(mode == null ? l10n.modeCleared : l10n.modeUpdated);
    } catch (_) {
      if (mounted) _snack(l10n.modeSaveError);
    } finally {
      if (mounted) setState(() => _modeSaving = false);
    }
  }

  Future<void> _openAddPlace() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AhlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.addPlace,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: l10n.placeNameHint),
            ),
            const SizedBox(height: 16),
            AhlButton(
              label: l10n.save,
              onPressed: () {
                Navigator.of(context).pop();
                _snack(l10n.comingSoon);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final circle = ref.watch(myCircleProvider).value;
    final circleName = circle?.name ?? l10n.myCircle;
    final tracking = ref.watch(trackingControllerProvider);
    final uid = ref.watch(currentUidProvider);

    ref.listen<AsyncValue<FamilyCircle?>>(myCircleProvider, (previous, next) {
      if (AppConfig.useMockData) return;
      final active = next.value;
      if (active != null) {
        final localizations = AppLocalizations.of(context);
        ref
            .read(trackingControllerProvider.notifier)
            .start(
              circleId: active.id,
              foregroundTitle: localizations.sharingNotificationTitle,
              foregroundText: localizations.sharingNotificationBody,
            );
        return;
      }
      final session = ref.read(sessionProvider);
      if (previous?.value != null && session.isLoggedIn && session.hasCircle) {
        ref.read(trackingControllerProvider.notifier).stop(writePaused: false);
        ref.read(sessionProvider.notifier).clearCircle();
        if (mounted) context.go('/circle');
      }
    });

    final Position? livePos = ref.watch(mapPositionProvider).value;
    ref.listen(mapPositionProvider, (previous, next) {
      final p = next.value;
      if (p != null && !_centeredOnMe) {
        _centeredOnMe = true;
        _mapController.move(LatLng(p.latitude, p.longitude), 16);
      }
      if (p != null && _selectedUid != null) {
        final from = LatLng(p.latitude, p.longitude);
        if (_routeFrom == null || haversineMeters(_routeFrom!, from) > 150) {
          unawaited(_refreshRouteForSelected());
        }
      }
    });

    ref.listen<MapFocus?>(mapFocusProvider, (previous, next) {
      if (next == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(next.point, 16.5);
        } catch (_) {
          // The map can still be attaching on a cold start.
        }
      });
      ref.read(mapFocusProvider.notifier).consume();
    });

    ref.listen<List<CircleMember>>(liveMembersProvider, (previous, next) {
      final selectedUid = _selectedUid;
      if (selectedUid == null) return;
      final member = _byUid(next, selectedUid);
      if (member == null || member.lat == null || member.lng == null) {
        _clearRoute();
        return;
      }
      final to = LatLng(member.lat!, member.lng!);
      if (_routeTo == null || haversineMeters(_routeTo!, to) > 150) {
        unawaited(_refreshRouteForSelected());
      }
    });

    final now = DateTime.now();
    final membersLoading = ref.watch(circleMembersProvider).isLoading;
    final rawMembers = ref.watch(liveMembersProvider);
    final sessionUser = ref.watch(
      sessionProvider.select((value) => value.user),
    );
    final members = <CircleMember>[
      for (final m in rawMembers)
        if (livePos != null && m.uid == uid)
          m.copyWith(
            lat: livePos.latitude,
            lng: livePos.longitude,
            lastUpdated: now,
            isMoving: livePos.speed > 1.5,
            speedKmh: livePos.speed * 3.6,
            headingDeg: livePos.heading,
            ghostMode: tracking.ghost ? true : m.ghostMode,
            sharingLocation: tracking.status == TrackingStatus.idle
                ? m.sharingLocation
                : tracking.enabled,
          )
        else
          m,
    ];
    if (uid != null && livePos != null && _byUid(members, uid) == null) {
      members.add(
        _selfFallback(
          uid: uid,
          user: sessionUser,
          livePos: livePos,
          tracking: tracking,
          now: now,
          fallbackName: l10n.you,
        ),
      );
    }
    final located = _located(members, uid);
    final sosMembers = located
        .where((member) => member.hasActiveSos)
        .toList(growable: false);
    final mapMembers = located
        .where((member) => member.uid == uid || !member.sosActive)
        .toList(growable: false);
    final sheetPx = MediaQuery.of(context).size.height * _sheetPeek;

    final LatLng? cachedCenter = ref.read(lastKnownCenterProvider);
    final selfMember = _byUid(members, uid);
    final selectedMember = _byUid(members, _selectedUid);
    final LatLng? selfPosition = livePos != null
        ? LatLng(livePos.latitude, livePos.longitude)
        : (selfMember != null &&
                  selfMember.lat != null &&
                  selfMember.lng != null
              ? LatLng(selfMember.lat!, selfMember.lng!)
              : null);
    final RouteInfo? route = _route;
    final String? routeDistance = route == null
        ? null
        : formatDistance(l10n, route.distanceMeters);
    final String? routeEta = route == null
        ? null
        : formatDurationShort(l10n, route.duration);
    final LatLng initialCenter =
        cachedCenter ??
        (selfMember?.lat != null
            ? LatLng(selfMember!.lat!, selfMember.lng!)
            : located.isNotEmpty
            ? LatLng(located.first.lat!, located.first.lng!)
            : const LatLng(24.7136, 46.6753));

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.5,
              onMapReady: _onMapReady,
              backgroundColor: const Color(0xFFF2F1F6),
              onTap: (tapPosition, point) {
                if (_selectedUid == null) return;
                setState(() {
                  _selectedUid = null;
                  _route = null;
                  _routeUid = null;
                  _routeFrom = null;
                  _routeTo = null;
                  _routeLoading = false;
                });
              },
            ),
            children: [
              TileLayer(
                key: ValueKey('tiles_$_styleIndex'),
                urlTemplate: _tileUrl,
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
              if (route != null && route.points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route.points,
                      strokeWidth: 11,
                      color: AhlColors.primary.withValues(alpha: 0.14),
                    ),
                    Polyline(
                      points: route.points,
                      strokeWidth: 4.5,
                      color: AhlColors.primary,
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              if (livePos != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(livePos.latitude, livePos.longitude),
                      radius: livePos.accuracy.clamp(5, 500).toDouble(),
                      useRadiusInMeter: true,
                      color: AhlColors.primary.withValues(alpha: 0.10),
                      borderColor: AhlColors.primary.withValues(alpha: 0.30),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              if (sosMembers.isNotEmpty)
                CircleLayer(
                  circles: [
                    for (final member in sosMembers)
                      CircleMarker(
                        point: LatLng(member.sosLat!, member.sosLng!),
                        radius: 55,
                        useRadiusInMeter: true,
                        color: AhlColors.danger.withValues(alpha: 0.14),
                        borderColor: AhlColors.danger.withValues(alpha: 0.45),
                        borderStrokeWidth: 1.5,
                      ),
                  ],
                ),
              AnimatedMembersLayer(
                located: mapMembers,
                selfUid: uid ?? '',
                selectedUid: _selectedUid,
                onSelect: _selectAndShow,
                selectedDistanceText: routeDistance,
                selectedEtaText: routeEta,
                selectedIsEstimate: route?.isEstimate ?? false,
              ),
              if (sosMembers.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (final member in sosMembers)
                      Marker(
                        point: LatLng(member.sosLat!, member.sosLng!),
                        width: SosMarker.width,
                        height: SosMarker.height,
                        alignment: Alignment.topCenter,
                        child: RepaintBoundary(
                          child: SosMarker(
                            member: member,
                            onTap: () => _focusSos(member),
                          ),
                        ),
                      ),
                  ],
                ),
              if (route != null && selectedMember != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: route.midpoint,
                      width: 210,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: DistanceEtaPill(
                        distanceText: routeDistance!,
                        etaText: routeEta!,
                        isEstimate: route.isEstimate,
                        loading: _routeLoading,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 210,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showSkeleton)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: const Color(0xFFF2F1F6),
                alignment: Alignment.center,
                child:
                    Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AhlColors.placeholder,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1100.ms, color: Colors.white),
              ),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoundButton(
                  icon: Icons.settings_rounded,
                  onTap: () => _switchTab(4),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CirclePill(
                          label: circleName,
                          onTap: () => _openCircleSwitcher(circle),
                        ),
                        if (!AppConfig.useMockData) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              _SharingChip(
                                tracking: tracking,
                                onTap: () =>
                                    showLocationPermissionSheet(context),
                              ),
                              _ModeChip(
                                mode: selfMember?.presenceMode,
                                saving: _modeSaving,
                                onTap: () => _openModePicker(selfMember),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    _RoundButton(
                      asset: 'bell',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RoundButton(
                      asset: 'chat-bubble',
                      onTap: () => _switchTab(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.30,
          child: Column(
            children: [
              _RoundButton(asset: 'star', onTap: _openAddPlace),
              const SizedBox(height: 10),
              _RoundButton(
                asset: 'map-pin',
                onTap: () => _recenter(livePos, members, uid),
              ),
              const SizedBox(height: 10),
              _RoundButton(
                asset: 'folder-new',
                onTap: () => _openLayers(located),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: sheetPx + 12,
          child: Row(
            children: [
              _ActionPill(
                icon: Icons.verified_user_rounded,
                label: l10n.checkIn,
                onTap: () => _snack(l10n.checkInSent),
              ),
              const SizedBox(width: 10),
              _ActionPill(
                icon: Icons.emergency_rounded,
                label: l10n.sos,
                danger: true,
                onTap: () => _switchTab(2),
              ),
            ],
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: _sheetPeek,
          minChildSize: 0.18,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.22, 0.5, 0.9],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: AhlColors.sheetShadow,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: HomeSheet(
                  scrollController: scrollController,
                  circleName: circleName,
                  members: members,
                  membersLoading: membersLoading,
                  selfUid: uid ?? '',
                  selfPosition: selfPosition,
                  category: _category,
                  onCategoryChanged: (i) => setState(() => _category = i),
                  onMemberTap: _selectAndShow,
                  onAddPerson: () => _shareInvite(circle),
                  onShareInvite: () => _shareInvite(circle),
                  onPremiumTap: () => _snack(l10n.comingSoon),
                  tipDismissed: _tipDismissed,
                  onDismissTip: () => setState(() => _tipDismissed = true),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({this.icon, this.asset, required this.onTap});

  final IconData? icon;
  final String? asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AhlColors.softShadowSmall,
        ),
        child: asset != null
            ? Center(child: Icon3D(asset!, size: 31))
            : Icon(icon, size: 22, color: AhlColors.primary),
      ),
    );
  }
}

class _CirclePill extends StatelessWidget {
  const _CirclePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(999)),
          boxShadow: AhlColors.softShadowSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AhlColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color foreground = danger ? Colors.white : AhlColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: danger ? null : Colors.white,
          gradient: danger
              ? const LinearGradient(
                  colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: danger
              ? Border.all(color: Colors.white.withValues(alpha: 0.24))
              : null,
          boxShadow: [
            BoxShadow(
              color: danger ? const Color(0x44E11D48) : const Color(0x0F000000),
              blurRadius: danger ? 18 : 14,
              offset: Offset(0, danger ? 7 : 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.mode,
    required this.saving,
    required this.onTap,
  });

  final PresenceMode? mode;
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color color = mode?.color ?? AhlColors.primary;
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 9, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.22)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (saving)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: color,
                ),
              )
            else
              Icon3D(mode?.icon3d ?? 'clock', size: 20),
            const SizedBox(width: 5),
            Text(
              mode?.label(l10n) ?? l10n.setMode,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: AhlColors.ink, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: AhlColors.inkLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.width,
    required this.icon,
    this.asset,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String? asset;
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : AhlColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: asset != null
                  ? Center(child: Icon3D(asset!, size: 31))
                  : Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AhlColors.ink,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 17, color: color),
          ],
        ),
      ),
    );
  }
}

class _SharingChip extends StatelessWidget {
  const _SharingChip({required this.tracking, required this.onTap});

  final TrackingState tracking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color color = tracking.enabled
        ? AhlColors.success
        : tracking.ghost
        ? AhlColors.inkMedium
        : AhlColors.danger;
    final String label = tracking.enabled
        ? l10n.sharingActive
        : tracking.ghost
        ? l10n.sharingPaused
        : l10n.locationOff;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(999)),
          boxShadow: AhlColors.softShadowSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AhlColors.inkMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
