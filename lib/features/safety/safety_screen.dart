import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';
import '../shell/shell_tab_provider.dart';

class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key});

  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..addStatusListener(_onHoldStatus);

  bool _sending = false;
  bool _mockSos = false;

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_sending && !_selfSosActive) {
      unawaited(_sendSos());
    }
  }

  bool get _selfSosActive {
    final uid = ref.read(currentUidProvider);
    for (final member in ref.read(liveMembersProvider)) {
      if (member.uid == uid) return member.sosActive;
    }
    return _mockSos;
  }

  void _beginHold() {
    if (_sending || _selfSosActive) return;
    HapticFeedback.selectionClick();
    _hold.forward(from: 0);
  }

  void _endHold() {
    if (_hold.isCompleted || _sending) return;
    _hold.animateBack(
      0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendSos() async {
    if (_sending) return;
    final uid = ref.read(currentUidProvider);
    final circle = ref.read(myCircleProvider).value;
    if (uid == null || circle == null) {
      _snack(AppLocalizations.of(context).sosUnable);
      _hold.value = 0;
      return;
    }
    setState(() => _sending = true);
    LatLng? point;
    final live = ref.read(mapPositionProvider).value;
    if (live != null) {
      point = LatLng(live.latitude, live.longitude);
    } else {
      for (final member in ref.read(liveMembersProvider)) {
        if (member.uid == uid && member.lat != null && member.lng != null) {
          point = LatLng(member.lat!, member.lng!);
          break;
        }
      }
    }
    if (point == null) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 12),
          ),
        );
        point = LatLng(position.latitude, position.longitude);
      } catch (_) {
        point = null;
      }
    }
    if (!mounted) return;
    if (point == null) {
      setState(() => _sending = false);
      _hold.value = 0;
      _snack(AppLocalizations.of(context).sosNoLocation);
      return;
    }
    if (AppConfig.useMockData) {
      setState(() {
        _sending = false;
        _mockSos = true;
      });
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      _snack(AppLocalizations.of(context).sosSent);
      return;
    }
    try {
      await ref
          .read(circleRepositoryProvider)
          .triggerSos(
            circleId: circle.id,
            uid: uid,
            latitude: point.latitude,
            longitude: point.longitude,
          );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      setState(() => _sending = false);
      _snack(AppLocalizations.of(context).sosSent);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      _hold.value = 0;
      _snack(AppLocalizations.of(context).sosUnable);
    }
  }

  Future<void> _cancelSos() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sosCancel),
        content: Text(l10n.sosResolveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AhlColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.sosCancel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final uid = ref.read(currentUidProvider);
    final circle = ref.read(myCircleProvider).value;
    if (uid == null || circle == null) return;
    try {
      if (!AppConfig.useMockData) {
        await ref
            .read(circleRepositoryProvider)
            .cancelSos(circleId: circle.id, uid: uid);
      }
      if (!mounted) return;
      setState(() {
        _mockSos = false;
        _sending = false;
      });
      _hold.value = 0;
      _snack(l10n.sosCancelled);
    } catch (_) {
      if (mounted) _snack(l10n.sosUnable);
    }
  }

  void _showOnMap(CircleMember member) {
    if (!member.hasActiveSos) return;
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
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _timeLabel(BuildContext context, DateTime? at) {
    final value = at ?? DateTime.now();
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(value.toLocal()),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? uid = ref.watch(currentUidProvider);
    final List<CircleMember> members = ref.watch(liveMembersProvider);
    CircleMember? self;
    for (final member in members) {
      if (member.uid == uid) self = member;
    }
    final bool selfActive = self?.sosActive == true || _mockSos;
    final List<CircleMember> others = members
        .where((member) => member.uid != uid)
        .toList(growable: false);
    final List<CircleMember> otherSos = members
        .where((member) => member.uid != uid && member.hasActiveSos)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.safety)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8FA), AhlColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              for (final member in otherSos) ...[
                _OtherSosCard(
                  member: member,
                  l10n: l10n,
                  timeLabel: _timeLabel(context, member.sosAt),
                  onShowMap: () => _showOnMap(member),
                ),
                const SizedBox(height: 16),
              ],
              if (selfActive)
                _ActiveSosCard(
                  l10n: l10n,
                  sentAt: _timeLabel(context, self?.sosAt),
                  memberCount: others.length,
                  onShowMap: self == null ? null : () => _showOnMap(self!),
                  onCancel: _cancelSos,
                )
              else ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l10n.sos,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AhlColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    l10n.sosNotified,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AhlColors.inkMedium),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Listener(
                    onPointerDown: (_) => _beginHold(),
                    onPointerUp: (_) => _endHold(),
                    onPointerCancel: (_) => _endHold(),
                    child: AnimatedBuilder(
                      animation: _hold,
                      builder: (context, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 212,
                            height: 212,
                            child: CircularProgressIndicator(
                              value: _hold.value,
                              strokeWidth: 7,
                              strokeCap: StrokeCap.round,
                              backgroundColor: AhlColors.danger.withValues(
                                alpha: 0.12,
                              ),
                              valueColor: const AlwaysStoppedAnimation(
                                AhlColors.danger,
                              ),
                            ),
                          ),
                          Container(
                            width: 174,
                            height: 174,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AhlColors.danger.withValues(alpha: 0.08),
                            ),
                          ),
                          AnimatedScale(
                            scale: 1 + _hold.value * 0.04,
                            duration: const Duration(milliseconds: 80),
                            child: Container(
                              width: 154,
                              height: 154,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE11D48),
                                    Color(0xFFF43F5E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x44E11D48),
                                    blurRadius: 30,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_sending)
                                    const SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.sos_rounded,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _sending ? l10n.sosWaiting : l10n.sos,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _sending ? l10n.sosWaiting : l10n.sosHold,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AhlColors.inkMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    l10n.emergencyContacts,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AhlColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.membersCount(others.length),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AhlColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.sosAlertBody,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 12),
              if (others.isEmpty)
                AhlCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.shareInvite,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AhlColors.inkMedium),
                  ),
                )
              else
                for (final member in others) ...[
                  AhlCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        AvatarCircle(
                          name: member.name,
                          photoUrl: member.photoUrl,
                          size: 42,
                          showOnlineDot: true,
                          isOnline: member.isLive,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                member.placeLabel ?? l10n.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AhlColors.inkMedium),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AhlColors.success.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: AhlColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.sosNotified,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AhlColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSosCard extends StatelessWidget {
  const _ActiveSosCard({
    required this.l10n,
    required this.sentAt,
    required this.memberCount,
    required this.onShowMap,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final String sentAt;
  final int memberCount;
  final VoidCallback? onShowMap;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44BE123C),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38),
                    ),
                    child: const Icon(
                      Icons.sos_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    duration: 900.ms,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sosActiveTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.sosSentAt(sentAt)} · ${l10n.membersCount(memberCount)}',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.sosActiveBody,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white, height: 1.35),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AhlButton(
                  label: l10n.sosShowOnMap,
                  asset: 'map-pin',
                  onPressed: onShowMap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(l10n.sosCancel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherSosCard extends StatelessWidget {
  const _OtherSosCard({
    required this.member,
    required this.l10n,
    required this.timeLabel,
    required this.onShowMap,
  });

  final CircleMember member;
  final AppLocalizations l10n;
  final String timeLabel;
  final VoidCallback onShowMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AhlColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AhlColors.danger.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sos_rounded, color: AhlColors.danger, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sosAlertTitle(member.name),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AhlColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l10n.sosSentAt(timeLabel),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AhlColors.inkMedium),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onShowMap, child: Text(l10n.view)),
        ],
      ),
    );
  }
}
