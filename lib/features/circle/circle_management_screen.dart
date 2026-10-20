import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';

class CircleManagementScreen extends ConsumerStatefulWidget {
  const CircleManagementScreen({super.key});

  @override
  ConsumerState<CircleManagementScreen> createState() =>
      _CircleManagementScreenState();
}

class _CircleManagementScreenState extends ConsumerState<CircleManagementScreen> {
  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _inviteMessage(AppLocalizations l10n, String code) =>
      l10n.shareInviteMessage(code, '${AppConfig.defaultInviteBase}$code');

  Future<void> _share(AppLocalizations l10n, String code) async {
    await SharePlus.instance.share(
      ShareParams(text: _inviteMessage(l10n, code)),
    );
  }

  Future<void> _shareWhatsApp(AppLocalizations l10n, String code) async {
    final text = Uri.encodeComponent(_inviteMessage(l10n, code));
    final uri = Uri.parse('https://wa.me/?text=$text');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _snack(l10n.error);
    }
  }

  Future<void> _copyCode(AppLocalizations l10n, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    _snack(l10n.codeCopied);
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              action,
              style: TextStyle(
                color: destructive ? AhlColors.danger : AhlColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _regenerate(AppLocalizations l10n, FamilyCircle circle) async {
    if (AppConfig.useMockData) {
      _snack(l10n.comingSoon);
      return;
    }
    final confirmed = await _confirm(
      title: l10n.regenerateCode,
      message: l10n.regenerateConfirm,
      action: l10n.regenerateCode,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(circleRepositoryProvider)
          .regenerateInviteCode(circleId: circle.id);
      _snack(l10n.regenerateSuccess);
    } catch (_) {
      _snack(l10n.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeMember(
    AppLocalizations l10n,
    FamilyCircle circle,
    CircleMember member,
  ) async {
    if (AppConfig.useMockData) {
      _snack(l10n.comingSoon);
      return;
    }
    final confirmed = await _confirm(
      title: l10n.removeMember,
      message: l10n.removeMemberConfirm(member.name),
      action: l10n.removeMember,
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(circleRepositoryProvider)
          .removeMember(circleId: circle.id, uid: member.uid);
    } catch (_) {
      _snack(l10n.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave(AppLocalizations l10n, FamilyCircle circle, String uid) async {
    if (AppConfig.useMockData) {
      _snack(l10n.comingSoon);
      return;
    }
    final confirmed = await _confirm(
      title: l10n.leaveCircle,
      message: l10n.leaveCircleConfirm,
      action: l10n.leaveCircle,
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(trackingControllerProvider.notifier)
          .stop(writePaused: false);
      await ref
          .read(circleRepositoryProvider)
          .removeMember(circleId: circle.id, uid: uid);
      await ref.read(sessionProvider.notifier).clearCircle();
      if (mounted) {
        _snack(l10n.leftCircle);
        context.go('/circle');
      }
    } catch (_) {
      _snack(l10n.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(AppLocalizations l10n, FamilyCircle circle) async {
    if (AppConfig.useMockData) {
      _snack(l10n.comingSoon);
      return;
    }
    final confirmed = await _confirm(
      title: l10n.deleteCircle,
      message: l10n.deleteCircleConfirm,
      action: l10n.deleteCircle,
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(trackingControllerProvider.notifier)
          .stop(writePaused: false);
      await ref
          .read(circleRepositoryProvider)
          .deleteCircle(circleId: circle.id);
      await ref.read(sessionProvider.notifier).clearCircle();
      if (mounted) {
        _snack(l10n.circleDeleted);
        context.go('/circle');
      }
    } catch (_) {
      _snack(l10n.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final uid = ref.watch(currentUidProvider);
    final streamCircle =
        AppConfig.useMockData ? null : ref.watch(myCircleProvider).value;
    final circle = streamCircle ?? session.circle;
    final members = ref.watch(liveMembersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageCircle)),
      body: SafeArea(
        child: circle == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group_off_rounded,
                          size: 40, color: AhlColors.outline),
                      const SizedBox(height: 12),
                      Text(
                        l10n.empty,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AhlColors.inkMedium),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AhlCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AhlColors.placeholder,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.family_restroom_rounded,
                              color: AhlColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                circle.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.circleMembers} · ${circle.memberUids.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AhlColors.inkMedium),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AhlCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inviteCode,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AhlColors.inkMedium),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                circle.inviteCode,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 6,
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _copyCode(l10n, circle.inviteCode),
                              icon: const Icon(Icons.copy_rounded,
                                  color: AhlColors.primary),
                              tooltip: l10n.copyCode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AhlButton(
                          label: l10n.shareInvite,
                          icon: Icons.share_rounded,
                          onPressed: () => _share(l10n, circle.inviteCode),
                        ),
                        const SizedBox(height: 8),
                        AhlButton(
                          label: l10n.whatsapp,
                          icon: Icons.chat_rounded,
                          gradient: false,
                          onPressed: () => _shareWhatsApp(l10n, circle.inviteCode),
                        ),
                        if (circle.ownerUid == uid) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _regenerate(l10n, circle),
                              icon: const Icon(Icons.autorenew_rounded,
                                  size: 18),
                              label: Text(l10n.regenerateCode),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.circleMembers,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (final member in members)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AhlCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            AvatarCircle(
                              name: member.name,
                              photoUrl: member.photoUrl,
                              size: 44,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    member.uid == circle.ownerUid
                                        ? l10n.owner
                                        : l10n.circleMembers,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                            color: AhlColors.inkMedium),
                                  ),
                                ],
                              ),
                            ),
                            if (circle.ownerUid == uid &&
                                member.uid != uid &&
                                member.uid != circle.ownerUid)
                              IconButton(
                                onPressed: _busy
                                    ? null
                                    : () =>
                                        _removeMember(l10n, circle, member),
                                icon: const Icon(Icons.person_remove_rounded,
                                    color: AhlColors.danger),
                                tooltip: l10n.removeMember,
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (circle.ownerUid == uid)
                    AhlButton(
                      label: l10n.deleteCircle,
                      icon: Icons.delete_outline_rounded,
                      gradient: false,
                      onPressed: _busy ? null : () => _delete(l10n, circle),
                    )
                  else
                    AhlButton(
                      label: l10n.leaveCircle,
                      icon: Icons.logout_rounded,
                      gradient: false,
                      onPressed: uid == null
                          ? null
                          : () => _leave(l10n, circle, uid),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
