import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/colors.dart';
import 'ahl_card.dart';

/// Base shimmer block used by every skeleton layout.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AhlColors.placeholder,
            borderRadius: BorderRadius.circular(radius),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AhlColors.placeholder,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

/// Member row placeholder for the home sheet and circle management.
class SkeletonMemberTile extends StatelessWidget {
  const SkeletonMemberTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AhlCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const SkeletonCircle(size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 130, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SkeletonBox(width: 44, height: 20, radius: 10),
        ],
      ),
    );
  }
}

/// Full chat placeholder shown while the first message snapshot arrives.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      children: const [
        Center(child: SkeletonBox(width: 64, height: 24, radius: 12)),
        SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: _BubbleSkeleton(width: 210, height: 62),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: _BubbleSkeleton(width: 170, height: 52),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: _BubbleSkeleton(width: 240, height: 72),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: _BubbleSkeleton(width: 150, height: 48),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: _BubbleSkeleton(width: 190, height: 58),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: _BubbleSkeleton(width: 220, height: 66),
        ),
      ],
    );
  }
}

class _BubbleSkeleton extends StatelessWidget {
  const _BubbleSkeleton({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AhlColors.placeholder,
            borderRadius: BorderRadius.circular(22),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

/// Generic list placeholder (notifications, member lists, etc).
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.all(16),
  });

  final int count;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => const SkeletonMemberTile(),
    );
  }
}
