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
import '../../core/services/location_service.dart';
import '../../core/services/tile_cache.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';
import '../../data/models/models.dart';
import '../circle/circle_management_screen.dart';
import '../location/location_permission_sheet.dart';
import '../member/member_detail_sheet.dart';
import '../notifications/notifications_screen.dart';
import '../shell/shell_tab_provider.dart';
import 'widgets/animated_members_layer.dart';
import 'widgets/home_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();
  int _styleIndex = 0;
  int _category = 0;
  String? _selectedUid;
  bool _tipDismissed = false;
  bool _centeredOnMe = false;
  bool _showSkeleton = true;

  static const double _sheetPeek = 0.22;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAskLocationPermission();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _maybeAskLocationPermission() async {
    if (AppConfig.useMockData || !mounted) return;
    if (!await shouldShowLocationPrompt()) return;
    if (!mounted) return;
    await markLocationPromptSeen();
    if (!mounted) return;
    await showLocationPermissionSheet(context);
    final circle = ref.read(myCircleProvider).value;
    if (circle != null && mounted) {
      final l10n = AppLocalizations.of(context);
      await ref.read(trackingControllerProvider.notifier).start(
            circleId: circle.id,
            foregroundTitle: l10n.sharingNotificationTitle,
            foregroundText: l10n.sharingNotificationBody,
          );
    }
  }

  String get _tileUrl => switch (_styleIndex) {
        1 => AppConfig.tileStandardUrl,
        2 => AppConfig.tileSatelliteUrl,
        _ => AppConfig.tileLightUrl,
      };

  List<String> _styleLabels(AppLocalizations l10n) =>
      [l10n.lightMap, l10n.standardMap, l10n.satelliteMap];

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

  List<CircleMember> _located(List<CircleMember> members) => members
      .where((m) =>
          m.lat != null &&
          m.lng != null &&
          m.sharingLocation &&
          !m.ghostMode)
      .toList();

  CircleMember? _byUid(List<CircleMember> members, String? uid) {
    for (final m in members) {
      if (m.uid == uid) return m;
    }
    return null;
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
    showMemberDetailSheet(context, member);
  }

  void _recenter(Position? livePos, List<CircleMember> members, String? uid) {
    if (livePos != null) {
      _mapController.move(
        LatLng(livePos.latitude, livePos.longitude),
        _mapController.camera.zoom < 14 ? 15 : _mapController.camera.zoom,
      );
      return;
    }
    final me = members.where((m) => m.uid == uid && m.lat != null).toList();
    if (me.isNotEmpty) {
      _mapController.move(LatLng(me.first.lat!, me.first.lng!),
          _mapController.camera.zoom < 14 ? 15 : _mapController.camera.zoom);
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
            Text(l10n.mapLayers,
                style: Theme.of(context).textTheme.titleMedium),
            for (var i = 0; i < labels.length; i++)
              ListTile(
                leading: Icon(_styleIcons[i]),
                title: Text(labels[i]),
                trailing: _styleIndex == i
                    ? const Icon(Icons.check_rounded,
                        color: AhlColors.primary)
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

  Future<void> _openCircleSwitcher(FamilyCircle? circle) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AhlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(circle?.name ?? l10n.myCircle,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                circle == null
                    ? l10n.loading
                    : '${circle.memberUids.length} • ${circle.inviteCode}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 20),
              AhlButton(
                label: l10n.manageCircle,
                icon: Icons.settings_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
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
            Text(l10n.addPlace,
                style: Theme.of(context).textTheme.headlineSmall),
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
        ref.read(trackingControllerProvider.notifier).start(
              circleId: active.id,
              foregroundTitle: localizations.sharingNotificationTitle,
              foregroundText: localizations.sharingNotificationBody,
            );
        return;
      }
      final session = ref.read(sessionProvider);
      if (previous?.value != null && session.isLoggedIn && session.hasCircle) {
        ref
            .read(trackingControllerProvider.notifier)
            .stop(writePaused: false);
        ref.read(sessionProvider.notifier).clearCircle();
        if (mounted) context.go('/circle');
      }
    });

    final Position? livePos = ref.watch(mapPositionProvider).value;
    ref.listen(mapPositionProvider, (previous, next) {
      final p = next.value;
      if (p != null && !_centeredOnMe) {
        _centeredOnMe = true;
        _mapController.move(LatLng(p.latitude, p.longitude), 14.5);
      }
    });

    final now = DateTime.now();
    final rawMembers = ref.watch(liveMembersProvider);
    final members = [
      for (final m in rawMembers)
        if (livePos != null && m.uid == uid)
          m.copyWith(
            lat: livePos.latitude,
            lng: livePos.longitude,
            lastUpdated: now,
            isMoving: livePos.speed > 1.5,
            speedKmh: livePos.speed * 3.6,
            headingDeg: livePos.heading,
          )
        else
          m,
    ];
    final located = _located(members);
    final sheetPx = MediaQuery.of(context).size.height * _sheetPeek;

    final LatLng? cachedCenter = ref.read(lastKnownCenterProvider);
    final selfMember = _byUid(members, uid);
    final LatLng initialCenter = cachedCenter ??
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
              initialZoom: 13.5,
              onMapReady: _onMapReady,
              backgroundColor: const Color(0xFFF2F1F6),
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
                  TextSourceAttribution('CARTO'),
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
              AnimatedMembersLayer(
                located: located,
                selfUid: uid ?? '',
                selectedUid: _selectedUid,
                onSelect: _selectAndShow,
              ),
            ],
          ),
        ),
        if (_showSkeleton)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: const Color(0xFFF2F1F6),
                alignment: Alignment.center,
                child: Container(
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
                          _SharingChip(
                            tracking: tracking,
                            onTap: () => showLocationPermissionSheet(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    _RoundButton(
                      icon: Icons.mail_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RoundButton(
                      icon: Icons.chat_bubble_rounded,
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
              _RoundButton(
                icon: Icons.add_rounded,
                onTap: _openAddPlace,
              ),
              const SizedBox(height: 10),
              _RoundButton(
                icon: Icons.my_location_rounded,
                onTap: () => _recenter(livePos, members, uid),
              ),
              const SizedBox(height: 10),
              _RoundButton(
                icon: Icons.layers_rounded,
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
                icon: Icons.support_rounded,
                label: l10n.sos,
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: HomeSheet(
                  scrollController: scrollController,
                  circleName: circleName,
                  members: members,
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
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
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
        child: Icon(icon, size: 22, color: AhlColors.primary),
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
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: AhlColors.primary),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(999)),
          boxShadow: AhlColors.softShadowSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AhlColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AhlColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
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