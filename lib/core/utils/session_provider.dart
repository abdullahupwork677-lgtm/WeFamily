import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';

const String kOnboardingSeenKey = 'onboarding_seen';
const String kLoggedInKey = 'logged_in';
const String kHasCircleKey = 'has_circle';

class SessionState {
  const SessionState({
    this.onboardingSeen = false,
    this.isLoggedIn = false,
    this.hasCircle = false,
    this.user,
    this.circle,
  });

  final bool onboardingSeen;
  final bool isLoggedIn;
  final bool hasCircle;
  final AppUser? user;
  final FamilyCircle? circle;

  SessionState copyWith({
    bool? onboardingSeen,
    bool? isLoggedIn,
    bool? hasCircle,
    AppUser? user,
    FamilyCircle? circle,
  }) {
    return SessionState(
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasCircle: hasCircle ?? this.hasCircle,
      user: user ?? this.user,
      circle: circle ?? this.circle,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  Future<void>? _loadFuture;

  @override
  SessionState build() {
    _loadFuture ??= _load();
    return const SessionState();
  }

  Future<void> get loaded => _loadFuture ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = SessionState(
        onboardingSeen: prefs.getBool(kOnboardingSeenKey) ?? false,
        isLoggedIn: prefs.getBool(kLoggedInKey) ?? false,
        hasCircle: prefs.getBool(kHasCircleKey) ?? false,
        user: prefs.getBool(kLoggedInKey) == true ? MockData.currentUser : null,
        circle: prefs.getBool(kHasCircleKey) == true ? MockData.circle : null,
      );
    } catch (_) {
      // keep default state if storage is unavailable
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingSeen: true);
    _persistBool(kOnboardingSeenKey, true);
  }

  Future<void> login(String phone) async {
    state = state.copyWith(
      isLoggedIn: true,
      user: MockData.currentUser.copyWith(phone: phone),
    );
    _persistBool(kLoggedInKey, true);
  }

  Future<void> updateProfile({String? name, String? gender, DateTime? birthDate}) async {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(
      user: user.copyWith(name: name, gender: gender, birthDate: birthDate),
    );
  }

  Future<void> createOrJoinCircle(String name) async {
    state = state.copyWith(
      hasCircle: true,
      circle: FamilyCircle(
        id: MockData.circle.id,
        name: name,
        ownerUid: state.user?.id ?? 'u1',
        inviteCode: MockData.circle.inviteCode,
        memberUids: MockData.circle.memberUids,
      ),
    );
    _persistBool(kHasCircleKey, true);
  }

  Future<void> logout() async {
    state = const SessionState(onboardingSeen: true);
    _persistBool(kLoggedInKey, false);
    _persistBool(kHasCircleKey, false);
  }

  // Storage must never block navigation: persist in background, ignore errors.
  void _persistBool(String key, bool value) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance()
            .timeout(const Duration(seconds: 5));
        await prefs.setBool(key, value);
      } catch (_) {
        // ignore storage failures
      }
    }());
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
