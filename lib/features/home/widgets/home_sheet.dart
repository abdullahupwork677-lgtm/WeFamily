import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/services/directions_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/member_activity_ui.dart';
import '../../../core/utils/presence_mode_ui.dart';
import '../../../core/widgets/ahl_card.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/soft_illustration.dart';
import '../../../data/models/models.dart';

/// Draggable home sheet: premium banner, circle heading, category tabs,
/// member cards and the add-person card.
class HomeSheet extends StatelessWidget {
  const HomeSheet({
    super.key,
    required this.scrollController,
    required this.circleName,
    required this.members,
    required this.membersLoading,
    required this.category,
    required this.onCategoryChanged,
    required this.onMemberTap,
    required this.onAddPerson,
    required this.onShareInvite,
    required this.onPremiumTap,
    required this.tipDismissed,
    required this.onDismissTip,
    required this.selfUid,
    this.selfPosition,
  });

  final ScrollController scrollController;
  final String circleName;
  final List<CircleMember> members;
  final bool membersLoading;
  final int category;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<CircleMember> onMemberTap;
  final VoidCallback onAddPerson;
  final VoidCallback onShareInvite;
  final VoidCallback onPremiumTap;
  final bool tipDismissed;
  final VoidCallback onDismissTip;
  final String selfUid;
  final LatLng? selfPosition;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
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
        const SizedBox(height: 14),
        GradientBorderCard(
          padding: const EdgeInsets.all(16),
          onTap: onPremiumTap,
          child: Row(
            children: [
              const SoftIllustration(icon: Icons.lock_rounded, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.premiumTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.startFreeTrial,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AhlColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: AhlColors.border.withValues(alpha: 0.7)),
        const SizedBox(height: 18),
        Text(
          circleName,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _CategoryPill(
              icon: Icons.group_rounded,
              label: l10n.people,
              selected: category == 0,
              onTap: () => onCategoryChanged(0),
            ),
            const SizedBox(width: 10),
            _CategoryPill(
              icon: Icons.place_rounded,
              label: l10n.places,
              selected: category == 1,
              onTap: () => onCategoryChanged(1),
            ),
            const SizedBox(width: 10),
            _CategoryPill(
              icon: Icons.pets_rounded,
              label: l10n.pets,
              selected: category == 2,
              onTap: () => onCategoryChanged(2),
            ),
            const SizedBox(width: 10),
            _CategoryPill(
              icon: Icons.key_rounded,
              label: l10n.keys,
              selected: category == 3,
              onTap: () => onCategoryChanged(3),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (category == 0) ...[
          if (membersLoading && members.isEmpty)
            for (var i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonMemberTile(),
              )
          else
            for (final member in members)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MemberCard(
                  member: member,
                  selfUid: selfUid,
                  selfPosition: selfPosition,
                  onTap: () => onMemberTap(member),
                ),
              ),
          AhlCard(
            padding: const EdgeInsets.all(8),
            onTap: onAddPerson,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AhlColors.chip,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 20,
                    color: AhlColors.ink,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.addPerson,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ] else
          AhlCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const SoftIllustration(
                    icon: Icons.auto_awesome_rounded,
                    size: 52,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.comingSoon,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        if (!tipDismissed) ...[
          const SizedBox(height: 16),
          _TipCard(onDismiss: onDismissTip, onAction: onShareInvite),
        ],
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AhlColors.ink : AhlColors.surface,
              borderRadius: BorderRadius.circular(999),
              boxShadow: selected ? null : AhlColors.softShadowSmall,
            ),
            child: Icon(
              icon,
              size: 24,
              color: selected ? Colors.white : AhlColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.selfUid,
    required this.selfPosition,
    required this.onTap,
  });

  final CircleMember member;
  final String selfUid;
  final LatLng? selfPosition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MemberActivity activity = member.activity;
    final bool isSelf = member.uid == selfUid;
    final DateTime? updated = member.lastUpdated;
    final Duration? age = updated == null
        ? null
        : DateTime.now().difference(updated);
    final int? battery = member.batteryLevel;
    final bool hasLocation = member.lat != null && member.lng != null;
    String? distanceText;
    if (!isSelf && hasLocation && selfPosition != null && member.isLive) {
      distanceText = formatDistance(
        l10n,
        haversineMeters(selfPosition!, LatLng(member.lat!, member.lng!)),
      );
    }
    final String statusText = activity == MemberActivity.offline
        ? (hasLocation ? l10n.offline : l10n.noLocationYet)
        : member.placeLabel ?? l10n.location;
    final Color statusColor = member.isLive
        ? activity.color
        : AhlColors.inkMedium;

    return AhlCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          AvatarCircle(
            name: member.name,
            photoUrl: member.photoUrl,
            size: 56,
            showOnlineDot: true,
            isOnline: member.isLive,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ActivityPill(
                      activity: activity,
                      mode: member.presenceMode,
                      l10n: l10n,
                    ),
                    if (distanceText != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.awayFromYou(distanceText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AhlColors.inkMedium),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      member.ghostMode
                          ? Icons.visibility_off_rounded
                          : activity == MemberActivity.offline
                          ? Icons.location_off_rounded
                          : Icons.place_rounded,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        statusText,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: statusColor),
                      ),
                    ),
                    if (updated != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        age!.inMinutes < 1
                            ? l10n.justNow
                            : l10n.updatedAgo(age.inMinutes),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AhlColors.inkLight),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (battery != null) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                Icon(
                  battery < 20
                      ? Icons.battery_2_bar_rounded
                      : Icons.battery_full_rounded,
                  size: 20,
                  color: battery < 20 ? AhlColors.danger : AhlColors.inkMedium,
                ),
                Text(
                  '$battery%',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AhlColors.inkMedium),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityPill extends StatelessWidget {
  const _ActivityPill({required this.activity, required this.l10n, this.mode});

  final MemberActivity activity;
  final AppLocalizations l10n;
  final PresenceMode? mode;

  @override
  Widget build(BuildContext context) {
    final Color color = mode?.color ?? activity.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mode?.icon ?? activity.icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            mode?.label(l10n) ?? activity.label(l10n),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.onDismiss, required this.onAction});

  final VoidCallback onDismiss;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AhlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SoftIllustration(
                icon: Icons.card_giftcard_rounded,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.shareInviteTipTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AhlColors.inkMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.shareInviteTipBody,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AhlColors.inkMedium),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: AlignmentDirectional.centerStart,
            ),
            child: Text(
              l10n.shareInvite,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AhlColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
