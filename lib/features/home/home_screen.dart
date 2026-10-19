import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<CircleMember> members = ref.watch(membersProvider);

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(24.7136, 46.6753),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.wefamily.wefamily',
            ),
            MarkerLayer(
              markers: members
                  .where((m) => m.lat != null && m.lng != null && m.sharingLocation && !m.ghostMode)
                  .map(
                    (m) => Marker(
                      point: LatLng(m.lat!, m.lng!),
                      width: 48,
                      height: 48,
                      child: AvatarCircle(name: m.name, size: 44, showOnlineDot: true, isOnline: true),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AhlColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Color(0x1A2B2433), blurRadius: 20, offset: Offset(0, -4)),
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
                                onTap: () => showMemberDetailSheet(context, m),
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
              );
            },
          ),
        ),
      ],
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
