import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 48,
    this.showOnlineDot = false,
    this.isOnline = false,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final bool showOnlineDot;
  final bool isOnline;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Color get _color {
    final hash = name.hashCode;
    final colors = [
      AhlColors.primary,
      const Color(0xFF7C3AED),
      const Color(0xFFA200BA),
      const Color(0xFF6D28D9),
      const Color(0xFF9333EA),
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _color.withValues(alpha: 0.15),
            border: Border.all(color: _color.withValues(alpha: 0.4), width: 2),
          ),
          alignment: Alignment.center,
          child: photoUrl != null && photoUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    photoUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _initialsWidget(context),
                  ),
                )
              : _initialsWidget(context),
        ),
        if (showOnlineDot)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AhlColors.success : AhlColors.inkLight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initialsWidget(BuildContext context) {
    return Text(
      _initials,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: _color,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.35,
      ),
    );
  }
}
