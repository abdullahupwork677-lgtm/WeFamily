import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../data/models/models.dart';
import '../chat/chat_providers.dart';
import '../chat/chat_screen.dart';
import '../home/home_screen.dart';
import '../safety/safety_screen.dart';
import '../settings/settings_screen.dart';
import '../tree/family_orbit/family_orbit_screen.dart';
import 'shell_tab_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  String? _lastAlertKey;
  String? _dismissedKey;

  CircleMember? _activeSos(List<CircleMember> members, String? selfUid) {
    CircleMember? own;
    for (final member in members) {
      if (!member.hasActiveSos) continue;
      if (member.uid == selfUid) {
        own ??= member;
      } else {
        return member;
      }
    }
    return own;
  }

  String? _sosKey(CircleMember? member) {
    if (member == null) return null;
    return '${member.uid}:${member.sosAt?.millisecondsSinceEpoch ?? 0}';
  }

  void _viewSos(CircleMember member) {
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
    setState(() => _dismissedKey = _sosKey(member));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int index = ref.watch(shellTabProvider);
    final bool hasUnread = index != 3 && ref.watch(unreadChatCountProvider) > 0;
    final String? selfUid = ref.watch(currentUidProvider);
    final List<CircleMember> members = ref.watch(liveMembersProvider);
    final CircleMember? sos = _activeSos(members, selfUid);
    final String? sosKey = _sosKey(sos);

    ref.listen<List<CircleMember>>(liveMembersProvider, (previous, next) {
      final active = _activeSos(next, ref.read(currentUidProvider));
      final key = _sosKey(active);
      if (key == null) {
        _lastAlertKey = null;
        if (_dismissedKey != null && mounted) {
          setState(() => _dismissedKey = null);
        }
        return;
      }
      if (key != _lastAlertKey) {
        _lastAlertKey = key;
        if (mounted) setState(() => _dismissedKey = null);
        HapticFeedback.vibrate();
        SystemSound.play(SystemSoundType.alert);
      }
    });

    final CircleMember? activeSos = sos != null && sosKey != _dismissedKey
        ? sos
        : null;

    const screens = [
      HomeScreen(),
      FamilyOrbitScreen(),
      SafetyScreen(),
      ChatScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: index, children: screens),
          if (activeSos != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 6,
              left: 12,
              right: 12,
              child:
                  _SosBanner(
                        member: activeSos,
                        isSelf: activeSos.uid == selfUid,
                        l10n: l10n,
                        onView: () => _viewSos(activeSos),
                        onDismiss: () => setState(() => _dismissedKey = sosKey),
                      )
                      .animate()
                      .slideY(
                        begin: -0.8,
                        end: 0,
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(duration: 220.ms),
            ),
        ],
      ),
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
                  onTap: () => ref.read(shellTabProvider.notifier).select(0),
                ),
                _NavItem(
                  icon: Icons.account_tree_outlined,
                  activeIcon: Icons.account_tree,
                  label: l10n.tree,
                  selected: index == 1,
                  onTap: () => ref.read(shellTabProvider.notifier).select(1),
                ),
                _NavItem(
                  icon: Icons.shield_outlined,
                  activeIcon: Icons.shield,
                  label: l10n.safety,
                  selected: index == 2,
                  onTap: () => ref.read(shellTabProvider.notifier).select(2),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: l10n.chat,
                  selected: index == 3,
                  showBadge: hasUnread,
                  onTap: () => ref.read(shellTabProvider.notifier).select(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n.profile,
                  selected: index == 4,
                  onTap: () => ref.read(shellTabProvider.notifier).select(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SosBanner extends StatelessWidget {
  const _SosBanner({
    required this.member,
    required this.isSelf,
    required this.l10n,
    required this.onView,
    required this.onDismiss,
  });

  final CircleMember member;
  final bool isSelf;
  final AppLocalizations l10n;
  final VoidCallback onView;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final String time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime((member.sosAt ?? DateTime.now()).toLocal()),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x55FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55BE123C),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Icon(Icons.sos_rounded, color: Colors.white),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 900.ms,
                ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSelf
                        ? l10n.sosActiveTitle
                        : l10n.sosAlertTitle(member.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSelf ? l10n.sosActiveBody : l10n.sosSentAt(time),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: onView,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AhlColors.danger,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                l10n.view,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
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
    this.showBadge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  size: 26,
                  color: selected ? AhlColors.primary : AhlColors.outline,
                ),
                if (showBadge)
                  PositionedDirectional(
                    top: -1,
                    end: -3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AhlColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
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
