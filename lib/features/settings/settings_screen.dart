import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/config.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/language_switcher.dart';
import '../location/location_permission_sheet.dart';
import '../notifications/notifications_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sharing = true;
  bool _ghost = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final tracking = ref.watch(trackingControllerProvider);
    final bool sharing =
        AppConfig.useMockData ? _sharing : tracking.enabled;
    final bool ghost = AppConfig.useMockData ? _ghost : tracking.ghost;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: const [LanguageSwitcher(compact: true), SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AhlCard(
              child: Row(
                children: [
                  AvatarCircle(name: user?.name ?? 'U', size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '—', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          user?.phone ?? '—',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AhlColors.inkMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AhlCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AhlColors.primary),
                    title: Text(l10n.notifications),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.location_on_outlined, color: AhlColors.primary),
                    title: Text(l10n.locationSharing),
                    subtitle: Text(
                      l10n.locationSharingSub,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AhlColors.inkMedium),
                    ),
                    value: sharing,
                    activeThumbColor: AhlColors.primary,
                    onChanged: (v) async {
                      if (AppConfig.useMockData) {
                        setState(() => _sharing = v);
                        return;
                      }
                      final controller =
                          ref.read(trackingControllerProvider.notifier);
                      if (!v) {
                        await controller.pause();
                        return;
                      }
                      if (tracking.foregroundGranted) {
                        await controller.resume();
                      } else if (context.mounted) {
                        await showLocationPermissionSheet(context);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.visibility_off_outlined, color: AhlColors.primary),
                    title: Text(l10n.ghostMode),
                    subtitle: Text(
                      l10n.ghostModeSub,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AhlColors.inkMedium),
                    ),
                    value: ghost,
                    activeThumbColor: AhlColors.primary,
                    onChanged: (v) async {
                      if (AppConfig.useMockData) {
                        setState(() => _ghost = v);
                        return;
                      }
                      await ref
                          .read(trackingControllerProvider.notifier)
                          .setGhost(v);
                    },
                  ),
                  if (!AppConfig.useMockData) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.gps_fixed_rounded,
                          color: AhlColors.primary),
                      title: Text(l10n.backgroundTipsTitle),
                      subtitle: Text(
                        l10n.backgroundTipsBody,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AhlColors.inkMedium),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showLocationPermissionSheet(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AhlCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AhlColors.danger),
                title: Text(l10n.logout, style: const TextStyle(color: AhlColors.danger)),
                onTap: () async {
                  try {
                    await ref
                        .read(trackingControllerProvider.notifier)
                        .stop()
                        .timeout(const Duration(seconds: 2));
                  } catch (_) {}
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (_) {
                    // ignore when Firebase is unavailable
                  }
                  await ref.read(sessionProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
