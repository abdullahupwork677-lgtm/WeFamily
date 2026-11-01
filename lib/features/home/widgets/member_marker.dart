import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utils/member_activity_ui.dart';
import '../../../core/utils/presence_mode_ui.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../data/models/models.dart';

/// Premium map marker: status ring, activity badge, name chip and a rich
/// info bubble (activity, place, last update and distance / ETA).
class MemberMarker extends StatelessWidget {
  const MemberMarker({
    super.key,
    required this.member,
    required this.isSelf,
    required this.selected,
    required this.onTap,
    this.distanceText,
    this.etaText,
    this.isEstimate = false,
  });

  static const double width = 280;
  static const double height = 244;

  final CircleMember member;
  final bool isSelf;
  final bool selected;
  final VoidCallback onTap;
  final String? distanceText;
  final String? etaText;
  final bool isEstimate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MemberActivity activity = member.activity;
    final PresenceMode? mode = member.presenceMode;
    final bool showBubble = selected;
    final int? battery = member.batteryLevel;
    final bool lowBattery = battery != null && battery < 25;
    final bool dimmed = activity == MemberActivity.offline;
    final Color statusColor = member.sosActive
        ? AhlColors.danger
        : member.isLive
        ? AhlColors.success
        : (member.ghostMode || !member.sharingLocation)
        ? AhlColors.gold
        : AhlColors.inkLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (member.isMoving && member.headingDeg != null)
              Positioned(
                left: 75,
                bottom: 38,
                width: 130,
                height: 112,
                child: Transform.rotate(
                  angle: (member.headingDeg! * math.pi) / 180,
                  alignment: Alignment.bottomCenter,
                  child: const CustomPaint(painter: _HeadingConePainter()),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBubble) ...[
                    _InfoBubble(
                      member: member,
                      l10n: l10n,
                      isSelf: isSelf,
                      distanceText: isSelf ? null : distanceText,
                      etaText: isSelf ? null : etaText,
                      isEstimate: isEstimate,
                    ),
                    const SizedBox(height: 6),
                  ] else if (dimmed) ...[
                    _OfflineTag(l10n: l10n),
                    const SizedBox(height: 4),
                  ],
                  _NameChip(
                    label: isSelf ? l10n.you : member.name,
                    statusColor: statusColor,
                    selected: selected,
                    dimmed: dimmed,
                    mode: mode,
                  ),
                  const SizedBox(height: 5),
                  AnimatedScale(
                    scale: selected ? 1.07 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: SizedBox(
                      width: 82,
                      height: 82,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          if (isSelf)
                            Positioned(
                              bottom: 2,
                              child:
                                  Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AhlColors.primary.withValues(
                                            alpha: 0.16,
                                          ),
                                        ),
                                      )
                                      .animate(onPlay: (c) => c.repeat())
                                      .scale(
                                        begin: const Offset(0.9, 0.9),
                                        end: const Offset(1.35, 1.35),
                                        duration: 2000.ms,
                                        curve: Curves.easeOut,
                                      )
                                      .fadeOut(duration: 2000.ms),
                            ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelf
                                  ? AhlColors.primaryGradient
                                  : null,
                              color: isSelf
                                  ? null
                                  : selected
                                  ? AhlColors.gold
                                  : Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Opacity(
                                opacity: dimmed ? 0.55 : 1,
                                child: AvatarCircle(
                                  name: member.name,
                                  photoUrl: member.photoUrl,
                                  size: 62,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 2,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 28),
                              height: 28,
                              padding: mode == null
                                  ? EdgeInsets.zero
                                  : const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: mode == null
                                    ? null
                                    : Border.all(
                                        color: mode.color.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                boxShadow: AhlColors.softShadowSmall,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    mode?.icon ?? activity.icon,
                                    size: 16,
                                    color: mode?.color ?? activity.color,
                                  ),
                                  if (mode != null) ...[
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        mode.label(l10n),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: mode.color,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                          if (member.sosActive)
                            Positioned(
                              top: -4,
                              left: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AhlColors.danger,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x55E11D48),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          if (lowBattery)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: AhlColors.softShadowSmall,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.battery_2_bar_rounded,
                                      size: 12,
                                      color: AhlColors.danger,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$battery%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(color: AhlColors.danger),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                    height: 9,
                    child: CustomPaint(painter: _TailPainter()),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dimmed ? AhlColors.inkLight : AhlColors.primary,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 4),
                      ],
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

class _NameChip extends StatelessWidget {
  const _NameChip({
    required this.label,
    required this.statusColor,
    required this.selected,
    required this.dimmed,
    this.mode,
  });

  final String label;
  final Color statusColor;
  final bool selected;
  final bool dimmed;
  final PresenceMode? mode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 188),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: selected ? Border.all(color: AhlColors.gold, width: 1.2) : null,
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: dimmed ? AhlColors.inkLight : AhlColors.ink,
              ),
            ),
          ),
          if (mode != null) ...[
            const SizedBox(width: 5),
            Container(width: 1, height: 10, color: AhlColors.border),
            const SizedBox(width: 5),
            Icon(mode!.icon, size: 12, color: mode!.color),
            const SizedBox(width: 3),
            Text(
              mode!.label(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: mode!.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfflineTag extends StatelessWidget {
  const _OfflineTag({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AhlColors.border),
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 11, color: AhlColors.inkMedium),
          const SizedBox(width: 4),
          Text(
            l10n.offline,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AhlColors.inkMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBubble extends StatelessWidget {
  const _InfoBubble({
    required this.member,
    required this.l10n,
    required this.isSelf,
    this.distanceText,
    this.etaText,
    this.isEstimate = false,
  });

  final CircleMember member;
  final AppLocalizations l10n;
  final bool isSelf;
  final String? distanceText;
  final String? etaText;
  final bool isEstimate;

  MemberActivity get _activity => member.activity;

  String get _value {
    if (_activity == MemberActivity.driving ||
        _activity == MemberActivity.walking ||
        _activity == MemberActivity.cycling) {
      return l10n.speedKmh((member.speedKmh ?? 0).round());
    }
    if (_activity == MemberActivity.offline) {
      return member.placeLabel ?? l10n.offline;
    }
    return member.placeLabel ?? l10n.hereFor;
  }

  String get _timeLabel {
    if (_activity == MemberActivity.stationary) {
      final since = member.sinceAt ?? member.lastUpdated;
      if (since != null) {
        return '${l10n.hereFor} ${_ago(since)}';
      }
    }
    final updated = member.lastUpdated;
    if (updated == null) return l10n.justNow;
    return l10n.updatedAgo(DateTime.now().difference(updated).inMinutes);
  }

  String _ago(DateTime since) {
    final diff = DateTime.now().difference(since);
    if (diff.inDays > 0) {
      return l10n.durationDaysHours(diff.inDays, diff.inHours % 24);
    }
    if (diff.inHours > 0) {
      return l10n.durationHoursMinutes(diff.inHours, diff.inMinutes % 60);
    }
    if (diff.inMinutes > 0) return l10n.durationMinutes(diff.inMinutes);
    return l10n.justNow;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDistance = distanceText != null && etaText != null;
    final String prefix = isEstimate ? '~' : '';

    return Container(
      constraints: const BoxConstraints(maxWidth: 214),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AhlColors.border.withValues(alpha: 0.6)),
        boxShadow: AhlColors.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: (member.presenceMode?.color ?? _activity.color)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  member.presenceMode?.icon ?? _activity.icon,
                  size: 17,
                  color: member.presenceMode?.color ?? _activity.color,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.presenceMode?.label(l10n) ?? _activity.label(l10n),
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: AhlColors.inkMedium),
                    ),
                    Text(
                      _value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (member.sosActive) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AhlColors.danger,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (hasDistance) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AhlColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 14,
                    color: AhlColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$prefix$distanceText',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AhlColors.ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AhlColors.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$prefix$etaText',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AhlColors.inkMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (member.placeLabel != null || !hasDistance) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.place_rounded, size: 13, color: AhlColors.inkLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    member.placeLabel ?? _timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AhlColors.inkMedium),
                  ),
                ),
                if (hasDistance)
                  Text(
                    _timeLabel,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AhlColors.inkLight),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeadingConePainter extends CustomPainter {
  const _HeadingConePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final spread = size.height * math.tan(math.pi / 6);
    final path = Path()
      ..moveTo(centerX, size.height)
      ..lineTo(centerX - spread, 0)
      ..lineTo(centerX + spread, 0)
      ..close();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.32),
          const Color(0x008B5CF6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TailPainter extends CustomPainter {
  const _TailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    final shadow = Paint()
      ..color = const Color(0x26000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path.shift(const Offset(0, 1.5)), shadow);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
