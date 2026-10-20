import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/soft_illustration.dart';

Future<void> showLocationPermissionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AhlColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const _LocationPermissionSheet(),
  );
}

class _LocationPermissionSheet extends ConsumerStatefulWidget {
  const _LocationPermissionSheet();

  @override
  ConsumerState<_LocationPermissionSheet> createState() =>
      _LocationPermissionSheetState();
}

class _LocationPermissionSheetState
    extends ConsumerState<_LocationPermissionSheet> {
  bool _busy = false;
  bool? _batteryIgnored;

  @override
  void initState() {
    super.initState();
    _loadBatteryStatus();
  }

  Future<void> _loadBatteryStatus() async {
    final ignored = await ref
        .read(trackingControllerProvider.notifier)
        .isBatteryOptimizationIgnored();
    if (mounted) setState(() => _batteryIgnored = ignored);
  }

  Future<void> _requestForeground() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(trackingControllerProvider.notifier)
          .requestForegroundPermission();
      await _startIfPossible();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestBackground() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(trackingControllerProvider.notifier)
          .requestBackgroundPermission();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSettings() async {
    await ref.read(trackingControllerProvider.notifier).openAppSettings();
    await ref
        .read(trackingControllerProvider.notifier)
        .refreshPermission();
    await _startIfPossible();
  }

  Future<void> _disableOptimization() async {
    setState(() => _busy = true);
    try {
      final ignored = await ref
          .read(trackingControllerProvider.notifier)
          .requestBatteryOptimizationExemption();
      if (mounted) setState(() => _batteryIgnored = ignored);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startIfPossible() async {
    final circle = ref.read(myCircleProvider).value;
    if (circle == null) return;
    final l10n = AppLocalizations.of(context);
    await ref.read(trackingControllerProvider.notifier).start(
          circleId: circle.id,
          foregroundTitle: l10n.sharingNotificationTitle,
          foregroundText: l10n.sharingNotificationBody,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final tracking = ref.watch(trackingControllerProvider);
    final foreground = tracking.foregroundGranted;
    final background = tracking.backgroundGranted;
    final blocked = tracking.permanentlyDenied;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AhlColors.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const SoftIllustration(icon: Icons.my_location_rounded, size: 64),
              const SizedBox(height: 14),
              Text(
                blocked
                    ? l10n.locationDeniedTitle
                    : foreground
                        ? l10n.allowBackgroundTitle
                        : l10n.locationPromptTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                blocked
                    ? l10n.locationDeniedBody
                    : foreground
                        ? l10n.allowBackgroundBody
                        : l10n.locationPromptBody,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              if (!foreground) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.visibility_off_outlined,
                        size: 18, color: AhlColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.locationPromptPrivacy,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AhlColors.inkMedium),
                      ),
                    ),
                  ],
                ),
              ],
              if (blocked) ...[
                const SizedBox(height: 20),
                AhlButton(
                  label: l10n.openSettings,
                  icon: Icons.settings_rounded,
                  onPressed: _busy ? null : _openSettings,
                ),
              ] else if (!foreground) ...[
                const SizedBox(height: 20),
                AhlButton(
                  label: l10n.shareWhileUsing,
                  icon: Icons.location_on_rounded,
                  onPressed: _busy ? null : _requestForeground,
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.notNow),
                ),
              ] else if (!background) ...[
                const SizedBox(height: 20),
                AhlButton(
                  label: l10n.shareAlways,
                  icon: Icons.nights_stay_rounded,
                  onPressed: _busy ? null : _requestBackground,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : _openSettings,
                  child: Text(l10n.openSettings),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.notNow),
                ),
              ] else ...[
                const SizedBox(height: 20),
                if (_batteryIgnored == false)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AhlColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.backgroundTipsTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.backgroundTipsBody,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AhlColors.inkMedium),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _busy ? null : _disableOptimization,
                          icon: const Icon(Icons.battery_saver_rounded,
                              size: 18),
                          label: Text(l10n.disableOptimization),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AhlColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.sharingActive,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AhlColors.success),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                AhlButton(
                  label: l10n.saveContinue,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
