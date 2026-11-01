import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

class StageAvatar extends StatelessWidget {
  const StageAvatar({
    super.key,
    required this.asset,
    required this.size,
    this.gradient = AhlColors.primaryGradient,
    this.borderWidth = 2,
    this.badge,
  });

  final String asset;
  final double size;
  final Gradient gradient;
  final double borderWidth;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(borderWidth),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              boxShadow: AhlColors.softShadowSmall,
            ),
            child: ClipOval(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              right: -size * 0.06,
              bottom: -size * 0.04,
              child: badge!,
            ),
        ],
      ),
    );
  }
}

class StagePill extends StatelessWidget {
  const StagePill({
    super.key,
    required this.label,
    this.leading,
    this.dotColor,
    this.background = const Color(0xF2FFFFFF),
    this.foreground = AhlColors.ink,
    this.fontSize = 11,
    this.fontWeight = FontWeight.w600,
    this.uppercase = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.shadow = true,
  });

  final String label;
  final Widget? leading;
  final Color? dotColor;
  final Color background;
  final Color foreground;
  final double fontSize;
  final FontWeight fontWeight;
  final bool uppercase;
  final EdgeInsets padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        boxShadow: shadow ? AhlColors.softShadowSmall : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Text(
            uppercase ? label.toUpperCase() : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: uppercase ? 0.6 : 0,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.size,
    this.background = AhlColors.primary,
    this.foreground = Colors.white,
    this.iconSize,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color foreground;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Icon(icon, size: iconSize ?? size * 0.62, color: foreground),
    );
  }
}

class StageCurve {
  const StageCurve({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
    this.dashed = false,
    this.width = 2.2,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFB794F6), Color(0xFFE9D5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  });

  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset end;
  final bool dashed;
  final double width;
  final Gradient gradient;
}

class StageCurvesPainter extends CustomPainter {
  StageCurvesPainter({required this.curves, required this.mirror});

  final List<StageCurve> curves;
  final bool mirror;

  Offset _point(Offset normalized, Size size) {
    final double dx = normalized.dx * size.width;
    return Offset(mirror ? size.width - dx : dx, normalized.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    for (final StageCurve curve in curves) {
      final Path path = Path()
        ..moveTo(_point(curve.start, size).dx, _point(curve.start, size).dy)
        ..cubicTo(
          _point(curve.control1, size).dx,
          _point(curve.control1, size).dy,
          _point(curve.control2, size).dx,
          _point(curve.control2, size).dy,
          _point(curve.end, size).dx,
          _point(curve.end, size).dy,
        );

      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = curve.width
        ..strokeCap = StrokeCap.round
        ..shader = curve.gradient.createShader(rect);

      if (!curve.dashed) {
        canvas.drawPath(path, paint);
        continue;
      }

      for (final ui.PathMetric metric in path.computeMetrics()) {
        double distance = 0;
        while (distance < metric.length) {
          final double end = (distance + 6)
              .clamp(0.0, metric.length)
              .toDouble();
          canvas.drawPath(metric.extractPath(distance, end), paint);
          distance += 11;
        }
      }
    }
  }

  @override
  bool shouldRepaint(StageCurvesPainter oldDelegate) {
    return oldDelegate.curves != curves || oldDelegate.mirror != mirror;
  }
}

/// Wraps a stage illustration in a soft rounded card.
class StageCard extends StatelessWidget {
  const StageCard({super.key, required this.child, this.height = 350});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AhlColors.startSurfaceLow, AhlColors.startSurfaceContainer],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AhlColors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StageGlow extends StatelessWidget {
  const StageGlow({
    super.key,
    required this.size,
    required this.color,
    this.alignment = Alignment.topLeft,
  });

  final double size;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

double stageAlignment(bool mirror, double fraction) {
  final double value = (fraction * 2) - 1;
  return mirror ? -value : value;
}
