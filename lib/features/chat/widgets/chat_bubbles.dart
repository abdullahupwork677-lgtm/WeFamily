import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/constants/config.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../data/models/models.dart';
import '../chat_providers.dart';

class ChatDateChip extends StatelessWidget {
  const ChatDateChip({super.key, required this.date, required this.locale});

  final DateTime date;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final l10n = AppLocalizations.of(context);
    final String label;
    if (day == today) {
      label = l10n.today;
    } else if (day == today.subtract(const Duration(days: 1))) {
      label = l10n.yesterday;
    } else {
      label = DateFormat.yMMMMd(locale).format(date);
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AhlColors.border),
          boxShadow: AhlColors.softShadowSmall,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AhlColors.inkMedium,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.locale,
    this.sender,
    this.progress,
    this.onRetry,
    this.showAvatar = true,
    this.groupedWithPrevious = false,
  });

  final ChatMessage message;
  final bool isMe;
  final String locale;
  final CircleMember? sender;
  final double? progress;
  final VoidCallback? onRetry;
  final bool showAvatar;
  final bool groupedWithPrevious;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm(locale).format(message.createdAt.toLocal());
    final failed = message.status == 'failed';
    final bool media = message.type == 'image' || message.type == 'location';

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.76,
      ),
      decoration: BoxDecoration(
        gradient: isMe ? AhlColors.primaryGradient : null,
        color: isMe ? null : AhlColors.surface,
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(22),
          topEnd: const Radius.circular(22),
          bottomStart: Radius.circular(
            isMe ? 22 : (groupedWithPrevious ? 8 : 6),
          ),
          bottomEnd: Radius.circular(isMe ? (groupedWithPrevious ? 8 : 6) : 22),
        ),
        border: isMe ? null : Border.all(color: AhlColors.border),
        boxShadow: isMe
            ? const [
                BoxShadow(
                  color: Color(0x335B21B6),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : AhlColors.softShadowSmall,
      ),
      clipBehavior: message.type == 'image' ? Clip.antiAlias : Clip.none,
      child: Padding(
        padding: media
            ? const EdgeInsets.all(6)
            : const EdgeInsets.fromLTRB(14, 9, 14, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe && !groupedWithPrevious && message.type != 'image')
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AhlColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            _body(context),
            if (!media)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : AhlColors.inkLight,
                      ),
                    ),
                    if (isMe) ...[const SizedBox(width: 4), _statusIcon()],
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: groupedWithPrevious ? 0 : 3, bottom: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            showAvatar
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: AvatarCircle(
                      name: message.senderName,
                      photoUrl: sender?.photoUrl,
                      size: 31,
                    ),
                  )
                : const SizedBox(width: 39),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                bubble,
                if (failed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton.icon(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: AhlColors.danger,
                      ),
                      label: Text(
                        AppLocalizations.of(context).retry,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AhlColors.danger,
                        ),
                      ),
                    ),
                  ),
                if (message.type == 'image' || message.type == 'location')
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : AhlColors.inkLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    if (message.status == 'sending') {
      return const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.4,
          color: Colors.white70,
        ),
      );
    }
    if (message.status == 'failed') {
      return const Icon(
        Icons.error_outline_rounded,
        size: 12,
        color: Colors.white,
      );
    }
    return const Icon(Icons.done_all_rounded, size: 13, color: Colors.white70);
  }

  Widget _body(BuildContext context) {
    switch (message.type) {
      case 'image':
        return _imageBody(context);
      case 'voice':
        return _VoiceBody(message: message, isMe: isMe);
      case 'location':
        return _locationBody(context);
      default:
        return Text(
          message.text ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isMe ? Colors.white : AhlColors.ink,
            height: 1.3,
          ),
        );
    }
  }

  Widget _imageBody(BuildContext context) {
    final local = message.localPath;
    final url = message.mediaUrl;
    final ratio =
        (message.width != null &&
            message.height != null &&
            message.width! > 0 &&
            message.height! > 0)
        ? (message.width! / message.height!).clamp(0.6, 1.8)
        : 4 / 3;

    final Widget image;
    if (local != null && File(local).existsSync()) {
      image = Image.file(
        File(local),
        fit: BoxFit.cover,
        width: 230,
        height: 230 / ratio,
        errorBuilder: (context, error, stack) => _imageFallback(context),
      );
    } else if (url != null && url.isNotEmpty) {
      image = Image.network(
        message.thumbUrl ?? url,
        fit: BoxFit.cover,
        width: 230,
        height: 230 / ratio,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const SizedBox(
                width: 230,
                height: 170,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
        errorBuilder: (context, error, stack) => _imageFallback(context),
      );
    } else {
      image = _imageFallback(context);
    }

    return GestureDetector(
      onTap: url == null || url.isEmpty
          ? null
          : () => showChatImageViewer(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            image,
            if (message.status == 'sending')
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      width: 230,
      height: 160,
      color: isMe ? Colors.white24 : AhlColors.chip,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: isMe ? Colors.white70 : AhlColors.inkLight,
      ),
    );
  }

  Widget _locationBody(BuildContext context) {
    final lat = message.lat;
    final lng = message.lng;
    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }
    final point = LatLng(lat, lng);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 230,
            height: 132,
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: AppConfig.tileLightUrl,
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.wefamily.wefamily',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 34,
                        height: 34,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AhlColors.primary,
                          size: 34,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(
                Icons.near_me_rounded,
                size: 16,
                color: AhlColors.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).location,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isMe ? Colors.white : AhlColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://maps.google.com/?q=$lat,$lng'),
                  mode: LaunchMode.externalApplication,
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.of(context).openOnMap,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white : AhlColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceBody extends ConsumerWidget {
  const _VoiceBody({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(voicePlayerProvider);
    final isActive = playback.messageId == message.id;
    final playing = isActive && playback.playing;
    final duration = message.durationMs != null
        ? Duration(milliseconds: message.durationMs!)
        : null;
    final position = isActive ? playback.position : Duration.zero;
    final progress = duration != null && duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final color = isMe ? Colors.white : AhlColors.primary;

    return SizedBox(
      width: 210,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(voicePlayerProvider.notifier).toggle(message),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isMe ? Colors.white24 : AhlColors.placeholder,
                shape: BoxShape.circle,
              ),
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: color,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      for (var i = 0; i < 26; i++)
                        Expanded(
                          child: Container(
                            height: 6 + ((i * 7) % 13),
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: i / 26 <= progress ? 1 : 0.35,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDuration(
                        isActive ? position : duration ?? Duration.zero,
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isMe ? Colors.white70 : AhlColors.inkLight,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          ref.read(voicePlayerProvider.notifier).cycleSpeed(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white24 : AhlColors.placeholder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${playback.speed == playback.speed.roundToDouble() ? playback.speed.toInt() : playback.speed}x',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

Future<void> showChatImageViewer(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (context) => Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                    errorBuilder: (context, error, stack) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
