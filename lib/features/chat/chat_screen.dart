import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/icon_3d.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/models.dart';
import '../shell/shell_tab_provider.dart';
import 'chat_providers.dart';
import 'widgets/chat_bubbles.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();
  AudioRecorder? _recorder;

  AudioRecorder get _rec => _recorder ??= AudioRecorder();

  Timer? _recordTimer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  DateTime _lastMarked = DateTime.fromMillisecondsSinceEpoch(0);

  bool _recording = false;
  bool _locked = false;
  bool _cancelHint = false;
  bool _recordBusy = false;
  bool _recordStarting = false;
  bool _stopRequested = false;
  bool _cancelRequested = false;
  double _startDx = 0;
  Duration _elapsed = Duration.zero;
  List<double> _amplitudes = const <double>[];

  @override
  void dispose() {
    _recordTimer?.cancel();
    _amplitudeSub?.cancel();
    if (_recording) {
      _rec.cancel();
    }
    _recorder?.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markRead(String? circleId, bool active) async {
    if (!active || circleId == null) return;
    final now = DateTime.now();
    if (now.difference(_lastMarked) < const Duration(seconds: 4)) return;
    _lastMarked = now;
    await markChatRead(circleId);
    if (mounted) ref.invalidate(chatLastReadProvider);
  }

  void _sendText(AppLocalizations l10n) {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendText(text);
    _input.clear();
    setState(() {});
    _scrollToBottom();
  }

  Future<void> _openAttachments(AppLocalizations l10n) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AhlColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AhlColors.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon3D('camera', size: 30),
              title: Text(l10n.camera),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon3D('folder-new', size: 30),
              title: Text(l10n.gallery),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            ListTile(
              leading: const Icon3D('map-pin', size: 30),
              title: Text(l10n.sendLocation),
              onTap: () => Navigator.of(context).pop('location'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    if (action == 'location') {
      await ref.read(chatControllerProvider.notifier).sendLocation();
      _scrollToBottom();
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 92,
        maxWidth: 2400,
      );
      if (picked == null || !mounted) return;
      await ref
          .read(chatControllerProvider.notifier)
          .sendImage(File(picked.path));
      _scrollToBottom();
    } catch (_) {
      _snack(l10n.error);
    }
  }

  Future<void> _startRecording({
    required bool locked,
    double startDx = 0,
  }) async {
    if (_recordBusy || _recording) return;
    _recordBusy = true;
    _recordStarting = true;
    _stopRequested = false;
    _cancelRequested = false;
    try {
      final hasPermission = await _rec.hasPermission();
      if (!hasPermission) {
        if (mounted) _showMicDenied();
        return;
      }
      final path =
          '${Directory.systemTemp.path}/wefamily_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      if (!mounted) {
        await _rec.cancel();
        return;
      }
      HapticFeedback.mediumImpact();
      setState(() {
        _recording = true;
        _locked = locked;
        _cancelHint = false;
        _startDx = startDx;
        _elapsed = Duration.zero;
        _amplitudes = const <double>[];
      });
      _amplitudeSub = _rec
          .onAmplitudeChanged(const Duration(milliseconds: 120))
          .listen((amplitude) {
            if (!mounted || !_recording) return;
            final level = ((amplitude.current + 60) / 60).clamp(0.05, 1.0);
            setState(() {
              _amplitudes = [..._amplitudes.take(29), level];
            });
          });
      _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || !_recording) return;
        setState(() {
          _elapsed += const Duration(milliseconds: 100);
        });
        if (_elapsed.inSeconds >= 120) {
          _finishRecording(send: true);
        }
      });
      if (_stopRequested) {
        final cancel = _cancelRequested;
        _stopRequested = false;
        _cancelRequested = false;
        if (cancel) {
          await _cancelRecording();
        } else {
          await _finishRecording(send: true);
        }
      }
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).error);
    } finally {
      _recordBusy = false;
      _recordStarting = false;
      if (!_recording) {
        _stopRequested = false;
        _cancelRequested = false;
      }
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    _amplitudeSub?.cancel();
    setState(() {
      _recording = false;
      _locked = false;
      _cancelHint = false;
      _amplitudes = const <double>[];
      _elapsed = Duration.zero;
    });
    try {
      await _rec.cancel();
    } catch (_) {}
  }

  Future<void> _finishRecording({required bool send}) async {
    if (!_recording) return;
    final duration = _elapsed;
    _recordTimer?.cancel();
    _amplitudeSub?.cancel();
    setState(() {
      _recording = false;
      _locked = false;
      _cancelHint = false;
      _amplitudes = const <double>[];
      _elapsed = Duration.zero;
    });

    String? path;
    try {
      if (send) {
        path = await _rec.stop();
      } else {
        await _rec.cancel();
      }
    } catch (_) {
      path = null;
    }

    if (!send || path == null) return;
    if (duration.inMilliseconds < 600) {
      try {
        await File(path).delete();
      } catch (_) {}
      return;
    }
    await ref
        .read(chatControllerProvider.notifier)
        .sendVoice(File(path), duration.inMilliseconds);
    _scrollToBottom();
  }

  void _showMicDenied() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.micDeniedTitle),
        content: Text(l10n.micDeniedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = Localizations.localeOf(context);
    final localeName = locale.toString();
    final chat = ref.watch(chatControllerProvider);
    final members = ref.watch(liveMembersProvider);
    final uid = ref.watch(currentUidProvider);
    final circleId = ref.watch(
      myCircleProvider.select((value) => value.value?.id),
    );
    final circleName = ref.watch(
      myCircleProvider.select((value) => value.value?.name),
    );
    final activeTab = ref.watch(shellTabProvider) == 3;

    final membersByUid = {for (final member in members) member.uid: member};
    final all = chat.all;
    final loadingChat = chat.loading && all.isEmpty;
    final int onlineCount = members.where((member) => member.isLive).length;
    final headerAvatars = members.take(3).toList(growable: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead(circleId, activeTab);
    });

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null && previous?.error != error) {
        _snack(error == 'location-unavailable' ? l10n.locationOff : l10n.error);
        if (error == 'location-unavailable') {
          ref.read(chatControllerProvider.notifier).clearError();
        }
      }
    });

    return Scaffold(
      backgroundColor: AhlColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AhlColors.primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 82,
        titleSpacing: 16,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AhlColors.primaryGradient),
        ),
        title: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Center(child: Icon3D('chat-bubble', size: 32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    circleName?.isNotEmpty == true ? circleName! : l10n.chat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    members.isEmpty
                        ? l10n.chatWithCircle
                        : l10n.membersOnline(members.length, onlineCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.74),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (headerAvatars.isNotEmpty)
            SizedBox(
              width: 26.0 + (headerAvatars.length - 1) * 18 + 12,
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < headerAvatars.length; i++)
                    PositionedDirectional(
                      start: i * 18.0,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: AvatarCircle(
                          name: headerAvatars[i].name,
                          photoUrl: headerAvatars[i].photoUrl,
                          size: 25,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F3FF), Color(0xFFFDFBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: loadingChat
                  ? const ChatSkeleton()
                  : all.isEmpty && chat.error != null
                  ? _ChatLoadError(
                      l10n: l10n,
                      onRetry: () =>
                          ref.read(chatControllerProvider.notifier).retryLoad(),
                    )
                  : all.isEmpty
                  ? _EmptyChat(l10n: l10n)
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 140) {
                          ref.read(chatControllerProvider.notifier).loadOlder();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scroll,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        itemCount: all.length + (chat.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= all.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: chat.loadingOlder
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const SizedBox(height: 8),
                              ),
                            );
                          }
                          final message = all[all.length - 1 - index];
                          final previous = index < all.length - 1
                              ? all[all.length - 2 - index]
                              : null;
                          final showDate =
                              previous == null ||
                              !_sameDay(previous.createdAt, message.createdAt);
                          final isMe = message.senderUid == uid;
                          final groupedWithPrevious =
                              !isMe &&
                              !showDate &&
                              previous.senderUid == message.senderUid &&
                              message.createdAt
                                      .difference(previous.createdAt)
                                      .inMinutes <
                                  4;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDate)
                                ChatDateChip(
                                  date: message.createdAt,
                                  locale: localeName,
                                ),
                              ChatBubble(
                                message: message,
                                isMe: isMe,
                                locale: localeName,
                                sender: membersByUid[message.senderUid],
                                progress: chat.progress[message.id],
                                showAvatar: !isMe && !groupedWithPrevious,
                                groupedWithPrevious: groupedWithPrevious,
                                onRetry: () {
                                  ref
                                      .read(chatControllerProvider.notifier)
                                      .retry(message);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
            _quickChips(l10n),
            if (_recording) _recordingBar(l10n),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AhlColors.border),
                    boxShadow: AhlColors.softShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _recording ? null : () => _openAttachments(l10n),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AhlColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AhlColors.primary,
                            size: 23,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 4,
                          enabled: !_recording,
                          textInputAction: TextInputAction.send,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _sendText(l10n),
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: l10n.typeMessage,
                            hintStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AhlColors.inkLight),
                            filled: true,
                            fillColor: AhlColors.background,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(
                                color: AhlColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (_input.text.trim().isNotEmpty && !_recording)
                        GestureDetector(
                          onTap: () => _sendText(l10n),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              gradient: AhlColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x445B21B6),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onLongPressStart: (details) {
                            if (!_recording && _input.text.trim().isEmpty) {
                              _startRecording(
                                locked: false,
                                startDx: details.globalPosition.dx,
                              );
                            }
                          },
                          onLongPressMoveUpdate: (details) {
                            if (!_recording || _locked) return;
                            final dx = details.globalPosition.dx - _startDx;
                            final rtl =
                                Directionality.of(context) == TextDirection.rtl;
                            final cancel = rtl ? dx > 70 : dx < -70;
                            if (cancel != _cancelHint) {
                              setState(() => _cancelHint = cancel);
                            }
                          },
                          onLongPressEnd: (_) {
                            if (!_recording) {
                              if (_recordStarting) {
                                _stopRequested = true;
                                _cancelRequested = _cancelHint;
                              }
                              return;
                            }
                            if (_cancelHint) {
                              _cancelRecording();
                            } else if (!_locked) {
                              _finishRecording(send: true);
                            }
                          },
                          onTap: () {
                            if (_recording && _locked) {
                              _finishRecording(send: true);
                            } else if (!_recording &&
                                _input.text.trim().isEmpty) {
                              _startRecording(locked: true);
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: _recording
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFE11D48),
                                        Color(0xFFF43F5E),
                                      ],
                                    )
                                  : AhlColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_recording
                                              ? AhlColors.danger
                                              : AhlColors.primary)
                                          .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _recording
                                ? const Icon(
                                    Icons.stop_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  )
                                : const Icon3D('mic', size: 28),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChips(AppLocalizations l10n) {
    final chips = [
      (label: l10n.quickOnMyWay, asset: 'map-pin'),
      (label: l10n.quickReached, asset: 'star'),
      (label: l10n.quickCallMe, asset: 'call-only'),
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return GestureDetector(
            onTap: () {
              ref.read(chatControllerProvider.notifier).sendText(chip.label);
              _scrollToBottom();
            },
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AhlColors.primary.withValues(alpha: 0.12),
                ),
                boxShadow: AhlColors.softShadowSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon3D(chip.asset, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    chip.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AhlColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _recordingBar(AppLocalizations l10n) {
    final hint = _cancelHint
        ? l10n.releaseToCancel
        : (_locked ? l10n.tapToStop : l10n.slideToCancel);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AhlColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        children: [
          const _PulsingDot(),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_elapsed),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  for (var i = 0; i < 24; i++)
                    Expanded(
                      child: Container(
                        height:
                            (4 +
                                    (_amplitudes.isEmpty
                                        ? 1
                                        : _amplitudes[i % _amplitudes.length] *
                                              16))
                                .toDouble(),
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _cancelHint
                              ? AhlColors.danger.withValues(alpha: 0.6)
                              : AhlColors.primary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            hint,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _cancelHint ? AhlColors.danger : AhlColors.inkMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_locked) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _cancelRecording,
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AhlColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ChatLoadError extends StatelessWidget {
  const _ChatLoadError({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AhlColors.placeholder,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AhlColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.error,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AhlColors.inkMedium),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon3D('chat-bubble', size: 104)
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.04, 1.04),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 20),
            Text(
              l10n.chatWithCircle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: AhlColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.startConversation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AhlColors.inkMedium, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AhlColors.danger,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
