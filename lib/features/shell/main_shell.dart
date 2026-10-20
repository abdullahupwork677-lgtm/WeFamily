import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../chat/chat_screen.dart';
import '../home/home_screen.dart';
import '../safety/safety_screen.dart';
import '../settings/settings_screen.dart';
import '../tree/tree_screen.dart';
import 'shell_tab_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int index = ref.watch(shellTabProvider);

    const screens = [
      HomeScreen(),
      TreeScreen(),
      SafetyScreen(),
      ChatScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: AhlColors.sheetShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.location_on_outlined,
                  activeIcon: Icons.location_on,
                  label: l10n.location,
                  selected: index == 0,
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).select(0),
                ),
                _NavItem(
                  icon: Icons.account_tree_outlined,
                  activeIcon: Icons.account_tree,
                  label: l10n.tree,
                  selected: index == 1,
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).select(1),
                ),
                _NavItem(
                  icon: Icons.shield_outlined,
                  activeIcon: Icons.shield,
                  label: l10n.safety,
                  selected: index == 2,
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).select(2),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: l10n.chat,
                  selected: index == 3,
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).select(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n.profile,
                  selected: index == 4,
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).select(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 26,
              color: selected ? AhlColors.primary : AhlColors.outline,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? AhlColors.primary : AhlColors.outline,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
