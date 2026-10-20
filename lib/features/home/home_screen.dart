import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/services/location_service.dart';
import '../../core/services/tile_cache.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/gradient_border_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import '../member/member_detail_sheet.dart';

final membersProvider = Provider<List<CircleMember>>((ref) => MockData.members);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();
  int _tab = 0;
  int _styleIndex = 0;
  String? _selectedUid;
  bool _showTrail = false;
  bool _centeredOnMe = false;
  bool _showSkeleton = true;

  static const double _sheetSize = 0.42;

  void _onMapReady() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showSkeleton = false);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<CircleMember> _located(List<CircleMember> members) => members
      .where((m) => m.lat != null && m.lng != null && m.sharingLocation && !m.ghostMode)
      .toList();

  CircleMember? _memberById(List<CircleMember> members, String? uid) {
    if (uid == null) return null;
    for (final m in members) {
      if (m.uid == uid) return m;
    }
    return null;
  }

  String get _tileUrl {
    final token = AppConfig.mapboxToken;
    if (token.isEmpty) {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
    final style = AppConfig.mapboxStyles[_styleIndex % AppConfig.mapboxStyles.length];
    return 'https://api.mapbox.com/styles/v1/mapbox/$style/tiles/512/{z}/{x}/{y}@2x?access_token=$token';
  }

  void _selectMember(CircleMember m) {
    setState(() {
      if (_selectedUid == m.uid) {
        _selectedUid = null;
        _showTrail = false;
      } else {
        _selectedUid = m.uid;
        _showTrail = false;
      }
    });
    if (m.lat != null && m.lng != null) {
      _mapController.move(LatLng(m.lat!, m.lng!), 15);
    }
  }

  List<LatLng> _trailFor(CircleMember m) {
    final lat = m.lat!;
    final lng = m.lng!;
    const r = 0.006;
    return [
      for (var i = 8; i >= 0; i--)
        LatLng(
          lat + r * math.sin(i * 0.8) * (i / 8),
          lng + r * math.cos(i * 0.7) * (i / 8),
        ),
      LatLng(lat, lng),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<CircleMember> rawMembers = ref.watch(membersProvider);
    final Position? livePos = ref.watch(livePositionProvider).value;

    ref.listen(livePositionProvider, (previous, next) {
      final p = next.value;
      if (p != null && !_centeredOnMe) {
        _centeredOnMe = true;
        _mapController.move(LatLng(p.latitude, p.longitude), 15);
      }
    });

    final List<CircleMember> members = [
      for (final m in rawMembers)
        (livePos != null && m.uid == MockData.currentUser.id)
            ? m.copyWith(lat: livePos.latitude, lng: livePos.longitude)
            : m,
    ];
    final located = _located(members);
    final CircleMember? selected = _memberById(members, _selectedUid);
    final double sheetPx = MediaQuery.of(context).size.height * _sheetSize;

    final LatLng? cachedCenter = ref.read(lastKnownCenterProvider);
    final LatLng initialCenter = cachedCenter ??
        (located.isNotEmpty
            ? LatLng(located.first.lat!, located.first.lng!)
            : const LatLng(24.7136, 46.6753));
    final List<LatLng>? trail =
        (_showTrail && selected?.lat != null && selected?.lng != null)
            ? _trailFor(selected!)
            : null;

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12.5,
              onMapReady: _onMapReady,
              backgroundColor: const Color(0xFF0D0A14),
            ),
            children: [
              TileLayer(
                key: ValueKey('tiles_$_styleIndex'),
                urlTemplate: _tileUrl,
                userAgentPackageName: 'com.wefamily.wefamily',
                tileProvider: CachedTileProvider(),
              ),
              if (livePos != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(livePos.latitude, livePos.longitude),
                      radius: livePos.accuracy.clamp(5, 500).toDouble(),
                      useRadiusInMeter: true,
                      color: AhlColors.primary.withValues(alpha: 0.12),
                      borderColor: AhlColors.primary.withValues(alpha: 0.35),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              if (trail != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: trail,
                      strokeWidth: 12,
                      color: AhlColors.primary.withValues(alpha: 0.25),
                    ),
                    Polyline(
                      points: trail,
                      strokeWidth: 4.5,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final m in located)
                    Marker(
                      point: LatLng(m.lat!, m.lng!),
                      width: (m.uid == _selectedUid) ? 150 : 92,
                      height: (m.uid == _selectedUid) ? 104 : 92,
                      child: RepaintBoundary(
                        child: _MemberMarker(
                          member: m,
                          selected: m.uid == _selectedUid,
                          onTap: () => _selectMember(m),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_showSkeleton)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: const Color(0xFF0D0A14),
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1100.ms, color: Colors.white24),
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 170,
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xB3000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GlassChip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.family_restroom_rounded,
                              size: 18, color: AhlColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            MockData.circle.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AhlColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${members.length}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AhlColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _GlassIconButton(
                      icon: Icons.layers_rounded,
                      onTap: () => setState(() => _styleIndex++),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: located.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final m = located[i];
                      final active = m.uid == _selectedUid;
                      return GestureDetector(
                        onTap: () => _selectMember(m),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active ? AhlColors.gold : Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AvatarCircle(
                                name: m.name,
                                size: 44,
                                showOnlineDot: true,
                                isOnline: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (livePos == null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => ref.invalidate(livePositionProvider),
                    child: _GlassChip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_off_rounded, size: 15, color: AhlColors.danger),
                          const SizedBox(width: 6),
                          Text(
                            l10n.locationOff,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AhlColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: sheetPx + 14,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            offset: selected == null ? const Offset(0, 1.4) : Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected == null ? 0 : 1,
              child: selected == null
                  ? const SizedBox.shrink()
                  : _MemberPulseCard(
                      member: selected,
                      showTrail: _showTrail,
                      onRoute: () => setState(() => _showTrail = !_showTrail),
                      onDetails: () => showMemberDetailSheet(context, selected),
                      onClose: () => setState(() {
                        _selectedUid = null;
                        _showTrail = false;
                      }),
                    ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: sheetPx + 14,
          child: _GlassIconButton(
            icon: Icons.my_location_rounded,
            onTap: () {
              if (livePos != null) {
                _mapController.move(LatLng(livePos.latitude, livePos.longitude), 15);
                return;
              }
              final me = located.where((m) => m.uid == MockData.currentUser.id).toList();
              final target = me.isNotEmpty ? me.first : located.firstOrNull;
              if (target != null) _selectMember(target);
            },
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: _sheetSize,
          minChildSize: 0.18,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A2B2433), blurRadius: 24, offset: Offset(0, -6)),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(top: 8),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AhlColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GradientBorderCard(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  gradient: AhlColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.premiumBanner, style: Theme.of(context).textTheme.titleMedium),
                                    Text(
                                      l10n.premiumBannerSub,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AhlColors.inkMedium,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: AhlColors.inkLight),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                MockData.circle.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AhlColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AhlColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.sharingActive,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AhlColors.success,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      PillTabs(
                        tabs: [
                          l10n.people,
                          l10n.places,
                          '${l10n.pets} (${l10n.comingSoon})',
                          '${l10n.keys} (${l10n.comingSoon})',
                        ],
                        selectedIndex: _tab,
                        onSelected: (i) => setState(() => _tab = i),
                      ),
                      const SizedBox(height: 16),
                      if (_tab == 0) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              for (final m in members) ...[
                                _MemberCard(
                                  member: m,
                                  onTap: () {
                                    _selectMember(m);
                                    showMemberDetailSheet(context, m);
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                              _AddPersonCard(label: l10n.addPerson),
                            ],
                          ),
                        ),
                      ] else if (_tab == 1) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AhlCard(
                            child: Center(
                              child: Text(
                                l10n.comingSoon,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AhlColors.inkMedium,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AhlCard(
                            child: Center(
                              child: Text(
                                l10n.comingSoon,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AhlColors.inkMedium,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(icon, size: 22, color: AhlColors.ink),
      ),
    );
  }
}

class _MemberMarker extends StatelessWidget {
  const _MemberMarker({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  final CircleMember member;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AhlColors.ink.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                member.name,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (member.uid == MockData.currentUser.id)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.9, 1.9), duration: 1900.ms, curve: Curves.easeOut)
                      .fadeOut(duration: 1900.ms),
                Container(
                  padding: EdgeInsets.all(selected ? 2.5 : 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AhlColors.gold : Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: AvatarCircle(name: member.name, size: selected ? 46 : 40, showOnlineDot: true, isOnline: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberPulseCard extends StatelessWidget {
  const _MemberPulseCard({
    required this.member,
    required this.showTrail,
    required this.onRoute,
    required this.onDetails,
    required this.onClose,
  });

  final CircleMember member;
  final bool showTrail;
  final VoidCallback onRoute;
  final VoidCallback onDetails;
  final VoidCallback onClose;

  String _lastSeen() {
    final t = member.lastUpdated;
    if (t == null) return '—';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }

  @override
  Widget build(BuildContext context) {
    final paused = !member.sharingLocation || member.ghostMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AvatarCircle(name: member.name, size: 42, showOnlineDot: true, isOnline: !paused),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          paused ? 'sharing paused' : '${member.placeLabel ?? '—'} · ${_lastSeen()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AhlColors.inkMedium),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (member.batteryLevel != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            member.batteryLevel! <= 20 ? Icons.battery_alert : Icons.battery_std,
                            size: 16,
                            color: member.batteryLevel! <= 20 ? AhlColors.danger : AhlColors.inkMedium,
                          ),
                          Text(
                            '${member.batteryLevel}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: member.batteryLevel! <= 20 ? AhlColors.danger : AhlColors.inkMedium,
                                ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.close_rounded, size: 20, color: AhlColors.inkLight),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ActionPill(
                    icon: Icons.route_rounded,
                    label: 'Route',
                    active: showTrail,
                    onTap: onRoute,
                  ),
                  const SizedBox(width: 8),
                  _ActionPill(
                    icon: Icons.person_rounded,
                    label: 'Details',
                    active: false,
                    onTap: onDetails,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? AhlColors.primaryGradient : null,
          color: active ? null : AhlColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AhlColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: active ? Colors.white : AhlColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap});

  final CircleMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool paused = !member.sharingLocation || member.ghostMode;

    return AhlCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarCircle(
            name: member.name,
            size: 52,
            showOnlineDot: true,
            isOnline: !paused,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.batteryLevel != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            member.batteryLevel! <= 20
                                ? Icons.battery_alert
                                : Icons.battery_std,
                            size: 16,
                            color: member.batteryLevel! <= 20
                                ? AhlColors.danger
                                : AhlColors.inkMedium,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${member.batteryLevel}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: member.batteryLevel! <= 20
                                      ? AhlColors.danger
                                      : AhlColors.inkMedium,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  paused
                      ? l10n.sharingPaused
                      : '${member.placeLabel ?? '—'} · ${member.relation}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AhlColors.inkMedium),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AhlColors.inkLight),
        ],
      ),
    );
  }
}

class _AddPersonCard extends StatelessWidget {
  const _AddPersonCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO(circle): add person flow
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AhlColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AhlColors.primary.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AhlColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AhlColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AhlColors.primary)),
          ],
        ),
      ),
    );
  }
}
