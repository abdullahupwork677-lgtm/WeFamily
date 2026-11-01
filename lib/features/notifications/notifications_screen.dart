import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/icon_3d.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import '../shell/shell_tab_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String key) {
    switch (key) {
      case 'location_on':
        return Icons.location_on;
      case 'share_location':
        return Icons.share_location;
      case 'home':
        return Icons.home;
      default:
        return Icons.notifications;
    }
  }

  void _openSos(WidgetRef ref, BuildContext context, CircleMember member) {
    ref
        .read(mapFocusProvider.notifier)
        .show(
          MapFocus(
            uid: member.uid,
            point: LatLng(member.sosLat!, member.sosLng!),
            fromSos: true,
          ),
        );
    ref.read(shellTabProvider.notifier).select(0);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? uid = ref.watch(currentUidProvider);
    final List<CircleMember> members = ref.watch(liveMembersProvider);
    final alerts = members
        .where((member) => member.hasActiveSos)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBF7FF), AhlColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: alerts.isEmpty
              ? _EmptyAlerts(l10n: l10n)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.sosRecent,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    for (final member in alerts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SosNotificationCard(
                          member: member,
                          isSelf: member.uid == uid,
                          l10n: l10n,
                          onTap: () => _openSos(ref, context, member),
                        ),
                      ),
                    if (AppConfig.useMockData)
                      for (final n in MockData.notifications)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AhlCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AhlColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconFor(n.icon),
                                    color: AhlColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n.body,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AhlColors.inkMedium,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SosNotificationCard extends StatelessWidget {
  const _SosNotificationCard({
    required this.member,
    required this.isSelf,
    required this.l10n,
    required this.onTap,
  });

  final CircleMember member;
  final bool isSelf;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime((member.sosAt ?? DateTime.now()).toLocal()),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return AhlCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AhlColors.danger.withValues(alpha: 0.10), Colors.white],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AhlColors.danger.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
                AvatarCircle(
                  name: member.name,
                  photoUrl: member.photoUrl,
                  size: 42,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AhlColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelf
                        ? l10n.sosActiveTitle
                        : l10n.sosAlertTitle(member.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AhlColors.danger,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.sosSentAt(time)} · ${member.placeLabel ?? l10n.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AhlColors.inkMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AhlColors.danger,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.view,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon3D('bell', size: 88),
          const SizedBox(height: 14),
          Text(
            l10n.noAlerts,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AhlColors.inkMedium),
          ),
        ],
      ),
    );
  }
}
