import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../data/models/models.dart';

/// Life360-style map marker: avatar with a white ring, a small pin tail and
/// purple dot anchored at the exact coordinate, an optional heading cone and a
/// floating "Here for" bubble with place / speed info.
class MemberMarker extends StatelessWidget {
  const MemberMarker({
    super.key,
    required this.member,
    required this.isSelf,
    required this.selected,
    required this.onTap,
  });

  final CircleMember member;
  final bool isSelf;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool showBubble = isSelf || selected;
    final int? battery = member.batteryLevel;
    final bool lowBattery = battery != null && battery < 20;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 260,
        height: 190,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (member.isMoving && member.headingDeg != null)
              Positioned(
                left: 65,
                bottom: 4,
                width: 130,
                height: 120,
                child: Transform.rotate(
                  angle: (member.headingDeg! * math.pi) / 180,
                  alignment: Alignment.bottomCenter,
                  child: const CustomPaint(painter: _HeadingConePainter()),
                ),
              ),
            if (showBubble)
              Positioned(
                left: 120,
                bottom: 92,
                child: _InfoBubble(member: member, l10n: l10n),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 84,
                    height: 76,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (isSelf)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AhlColors.primary.withValues(alpha: 0.18),
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2E000000),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: AvatarCircle(
                            name: member.name,
                            photoUrl: member.photoUrl,
                            size: 60,
                          ),
                        ),
                        if (lowBattery)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: AhlColors.softShadowSmall,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.battery_2_bar_rounded,
                                      size: 12, color: AhlColors.danger),
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
                  const SizedBox(
                    width: 16,
                    height: 10,
                    child: CustomPaint(painter: _TailPainter()),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AhlColors.primary,
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

class _InfoBubble extends StatelessWidget {
  const _InfoBubble({
    required this.member,
    required this.l10n,
  });

  final CircleMember member;
  final AppLocalizations l10n;

  String get _headline {
    if (!member.isMoving) return l10n.hereFor;
    final speed = member.speedKmh ?? 0;
    return speed >= 10 ? l10n.driving : l10n.moving;
  }

  String get _value {
    if (member.isMoving) {
      return l10n.speedKmh((member.speedKmh ?? 0).round());
    }
    final since = member.sinceAt ?? member.lastUpdated;
    if (since == null) return l10n.justNow;
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
    final bool isHome = member.placeLabel == 'Home' ||
        member.placeLabel == l10n.home;
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AhlColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isHome ? Icons.home_rounded : Icons.place_rounded,
              size: 17,
              color: AhlColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _headline,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AhlColors.inkMedium),
                ),
                Text(
                  _value,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
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
          const Color(0xFF8B5CF6).withValues(alpha: 0.35),
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
