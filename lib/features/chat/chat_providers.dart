import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/config.dart';
import '../../core/services/tracking_service.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/session_provider.dart';
import '../../data/models/models.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/mock_data.dart';

class ChatState {
  const ChatState({
    this.messages = const <ChatMessage>[],
    this.pending = const <ChatMessage>[],
    this.failed = const <ChatMessage>[],
    this.progress = const <String, double>{},
    this.hasMore = false,
    this.loadingOlder = false,
    this.loading = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final List<ChatMessage> pending;
  final List<ChatMessage> failed;
  final Map<String, double> progress;
  final bool hasMore;
  final bool loadingOlder;
  final bool loading;
  final String? error;

  List<ChatMessage> get all {
    final list = <ChatMessage>[...messages, ...pending, ...failed];
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatMessage>? pending,
    List<ChatMessage>? failed,
    Map<String, double>? progress,
    bool? hasMore,
    bool? loadingOlder,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
      progress: progress ?? this.progress,
      hasMore: hasMore ?? this.hasMore,
      loadingOlder: loadingOlder ?? this.loadingOlder,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends Notifier<ChatState> {
  StreamSubscription<List<ChatMessage>>? _subscription;
  String? _circleId;
  int _limit = 30;

  @override
  ChatState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    if (AppConfig.useMockData) {
      return ChatState(
        messages: MockData.messages
            .map((m) => m.copyWith(status: 'sent'))
            .toList(),
      );
    }

    final circleId = ref.watch(
      myCircleProvider.select((value) => value.value?.id),
    );
    _circleId = circleId;
    _limit = 30;
    if (circleId == null) {
      return const ChatState();
    }
    _subscribe();
    return const ChatState(loading: true);
  }

  void _subscribe() {
    _subscription?.cancel();
    final circleId = _circleId;
    if (circleId == null) return;
    _subscription = ref
        .read(chatRepositoryProvider)
        .watchMessages(circleId, limit: _limit)
        .listen(
          (messages) {
            state = state.copyWith(
              messages: messages,
              hasMore: messages.length >= _limit,
              loadingOlder: false,
              loading: false,
              clearError: true,
            );
          },
          onError: (Object error) {
            state = state.copyWith(
              loadingOlder: false,
              loading: false,
              error: error.toString(),
            );
          },
        );
  }

  /// Resubscribes after a Firestore/permission error.
  void retryLoad() {
    if (_circleId == null) return;
    state = state.copyWith(
      loading: true,
      loadingOlder: false,
      clearError: true,
    );
    _subscribe();
  }

  String get _uid => ref.read(currentUidProvider) ?? '';
  String get _senderName => ref.read(sessionProvider).user?.name ?? 'Member';

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  Future<void> loadOlder() async {
    if (!state.hasMore || state.loadingOlder || _circleId == null) return;
    state = state.copyWith(loadingOlder: true);
    _limit += 30;
    _subscribe();
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (AppConfig.useMockData) {
      _addMock(type: 'text', text: trimmed);
      return;
    }
    final circleId = _circleId;
    if (circleId == null) return;
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendText(
            circleId: circleId,
            uid: _uid,
            name: _senderName,
            text: trimmed,
          );
    } catch (_) {
      _addFailed(
        ChatMessage(
          id: _localId('failed'),
          senderUid: _uid,
          senderName: _senderName,
          type: 'text',
          text: trimmed,
          createdAt: DateTime.now(),
          status: 'failed',
        ),
      );
    }
  }

  Future<void> sendLocation() async {
    if (AppConfig.useMockData) {
      _addMock(type: 'location', lat: 24.7136, lng: 46.6753);
      return;
    }
    final circleId = _circleId;
    if (circleId == null) return;

    double? lat;
    double? lng;
    final live = ref.read(mapPositionProvider).value;
    if (live != null) {
      lat = live.latitude;
      lng = live.longitude;
    } else {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (_) {
        lat = null;
      }
    }
    if (lat == null || lng == null) {
      state = state.copyWith(error: 'location-unavailable');
      return;
    }
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendLocation(
            circleId: circleId,
            uid: _uid,
            name: _senderName,
            lat: lat,
            lng: lng,
          );
    } catch (_) {
      _addFailed(
        ChatMessage(
          id: _localId('failed'),
          senderUid: _uid,
          senderName: _senderName,
          type: 'location',
          lat: lat,
          lng: lng,
          createdAt: DateTime.now(),
          status: 'failed',
        ),
      );
    }
  }

  Future<void> sendImage(File file) async {
    if (AppConfig.useMockData) {
      _addMock(type: 'image', localPath: file.path);
      return;
    }
    final circleId = _circleId;
    if (circleId == null) return;
    final draft = ChatMessage(
      id: _localId('local'),
      senderUid: _uid,
      senderName: _senderName,
      type: 'image',
      localPath: file.path,
      createdAt: DateTime.now(),
      status: 'sending',
    );
    state = state.copyWith(pending: [...state.pending, draft]);
    try {
      await ref
          .read(chatRepositoryProvider)
          .uploadAndSendImage(
            circleId: circleId,
            uid: _uid,
            name: _senderName,
            file: file,
            onProgress: (value) => _setProgress(draft.id, value),
          );
      _removePending(draft.id);
    } catch (_) {
      _removePending(draft.id);
      _addFailed(draft.copyWith(status: 'failed'));
    }
  }

  Future<void> sendVoice(File file, int durationMs) async {
    if (AppConfig.useMockData) {
      _addMock(type: 'voice', localPath: file.path, durationMs: durationMs);
      return;
    }
    final circleId = _circleId;
    if (circleId == null) return;
    final draft = ChatMessage(
      id: _localId('local'),
      senderUid: _uid,
      senderName: _senderName,
      type: 'voice',
      localPath: file.path,
      durationMs: durationMs,
      createdAt: DateTime.now(),
      status: 'sending',
    );
    state = state.copyWith(pending: [...state.pending, draft]);
    try {
      await ref
          .read(chatRepositoryProvider)
          .uploadAndSendVoice(
            circleId: circleId,
            uid: _uid,
            name: _senderName,
            file: file,
            durationMs: durationMs,
            onProgress: (value) => _setProgress(draft.id, value),
          );
      _removePending(draft.id);
    } catch (_) {
      _removePending(draft.id);
      _addFailed(draft.copyWith(status: 'failed'));
    }
  }

  Future<void> retry(ChatMessage message) async {
    state = state.copyWith(
      failed: state.failed.where((m) => m.id != message.id).toList(),
    );
    switch (message.type) {
      case 'image':
      case 'voice':
        final path = message.localPath;
        if (path == null) return;
        final file = File(path);
        if (!await file.exists()) return;
        if (message.type == 'image') {
          await sendImage(file);
        } else {
          await sendVoice(file, message.durationMs ?? 0);
        }
      case 'location':
        await sendLocation();
      default:
        await sendText(message.text ?? '');
    }
  }

  String _localId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  void _addMock({
    required String type,
    String? text,
    String? localPath,
    int? durationMs,
    double? lat,
    double? lng,
  }) {
    final message = ChatMessage(
      id: _localId('mock'),
      senderUid: _uid,
      senderName: _senderName,
      type: type,
      text: text,
      localPath: localPath,
      durationMs: durationMs,
      lat: lat,
      lng: lng,
      createdAt: DateTime.now(),
      status: 'sent',
    );
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void _addFailed(ChatMessage message) {
    state = state.copyWith(failed: [...state.failed, message]);
  }

  void _setProgress(String id, double value) {
    state = state.copyWith(progress: {...state.progress, id: value});
  }

  void _removePending(String id) {
    state = state.copyWith(
      pending: state.pending.where((m) => m.id != id).toList(),
      progress: Map.of(state.progress)..remove(id),
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

final latestChatProvider = StreamProvider<List<ChatMessage>>((ref) {
  if (AppConfig.useMockData) return Stream.value(const <ChatMessage>[]);
  final circleId = ref.watch(
    myCircleProvider.select((value) => value.value?.id),
  );
  if (circleId == null) return Stream.value(const <ChatMessage>[]);
  return ref.watch(chatRepositoryProvider).watchMessages(circleId, limit: 25);
});

final chatLastReadProvider = FutureProvider<DateTime?>((ref) async {
  final circleId = ref.watch(
    myCircleProvider.select((value) => value.value?.id),
  );
  if (circleId == null) return null;
  final prefs = await SharedPreferences.getInstance();
  final millis = prefs.getInt('chat_read_$circleId');
  return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
});

final unreadChatCountProvider = Provider<int>((ref) {
  if (AppConfig.useMockData) return 0;
  final lastRead = ref.watch(chatLastReadProvider).value;
  final messages = ref.watch(latestChatProvider).value ?? const <ChatMessage>[];
  final uid = ref.watch(currentUidProvider);
  final since = lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
  return messages
      .where((m) => m.senderUid != uid && m.createdAt.isAfter(since))
      .length;
});

Future<void> markChatRead(String circleId) async {
  if (AppConfig.useMockData || circleId.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(
    'chat_read_$circleId',
    DateTime.now().millisecondsSinceEpoch,
  );
}

class VoicePlaybackState {
  const VoicePlaybackState({
    this.messageId,
    this.playing = false,
    this.position = Duration.zero,
    this.speed = 1,
  });

  final String? messageId;
  final bool playing;
  final Duration position;
  final double speed;

  VoicePlaybackState copyWith({
    String? messageId,
    bool? playing,
    Duration? position,
    double? speed,
  }) {
    return VoicePlaybackState(
      messageId: messageId ?? this.messageId,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      speed: speed ?? this.speed,
    );
  }
}

class VoicePlayerNotifier extends Notifier<VoicePlaybackState> {
  final AudioPlayer _player = AudioPlayer();
  bool _disposed = false;

  @override
  VoicePlaybackState build() {
    ref.onDispose(() {
      _disposed = true;
      _player.dispose();
    });
    _player.positionStream.listen((position) {
      if (_disposed) return;
      if (state.messageId != null) {
        state = state.copyWith(position: position);
      }
    });
    _player.playerStateStream.listen((playerState) {
      if (_disposed || state.messageId == null) return;
      final playing =
          playerState.playing &&
          playerState.processingState != ProcessingState.completed;
      state = state.copyWith(playing: playing);
    });
    return const VoicePlaybackState();
  }

  Duration? get duration => _player.duration;

  Future<void> toggle(ChatMessage message) async {
    final source = message.mediaUrl ?? message.localPath;
    if (source == null) return;
    if (state.messageId == message.id) {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
      return;
    }

    try {
      await _player.stop();
      final speed = state.speed;
      state = VoicePlaybackState(
        messageId: message.id,
        playing: true,
        position: Duration.zero,
        speed: speed,
      );
      if (source.startsWith('http')) {
        await _player.setUrl(source);
      } else {
        await _player.setFilePath(source);
      }
      await _player.setSpeed(speed);
      await _player.play();
    } catch (_) {
      state = const VoicePlaybackState();
    }
  }

  Future<void> cycleSpeed() async {
    const speeds = [1.0, 1.5, 2.0];
    final current = state.speed;
    final index = speeds.indexOf(current);
    final next = speeds[(index + 1) % speeds.length];
    await _player.setSpeed(next);
    state = state.copyWith(speed: next);
  }

  Future<void> stop() async {
    await _player.stop();
    state = VoicePlaybackState(speed: state.speed);
  }
}

final voicePlayerProvider =
    NotifierProvider<VoicePlayerNotifier, VoicePlaybackState>(
      VoicePlayerNotifier.new,
    );
