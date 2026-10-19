import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AhlColors.ink : AhlColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? AhlColors.ink : AhlColors.border,
                ),
              ),
              child: Text(
                tabs[index],
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : AhlColors.inkMedium,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
