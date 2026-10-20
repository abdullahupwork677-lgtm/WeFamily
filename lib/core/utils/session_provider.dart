import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';
import '../../data/repositories/mock_data.dart';
import '../constants/config.dart';

const String kOnboardingSeenKey = 'onboarding_seen';
const String kLoggedInKey = 'logged_in';
const String kHasCircleKey = 'has_circle';
const String kCircleIdKey = 'circle_id';
const String kProfileNameKey = 'profile_name';

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

  User? get _authUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  AppUser? _userFromAuth(User? authUser, {String? fallbackName}) {
    if (authUser == null) return null;
    final email = authUser.email ?? '';
    final local = email.contains('@') ? email.split('@').first : email;
    final display = authUser.displayName?.trim() ?? '';
    final name = display.isNotEmpty
        ? display
        : (fallbackName != null && fallbackName.trim().isNotEmpty
            ? fallbackName.trim()
            : local);
    return AppUser(id: authUser.uid, name: name, phone: email);
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authUser = AppConfig.useMockData ? null : _authUser;
      final storedLoggedIn = prefs.getBool(kLoggedInKey) ?? false;
      final hasCircle = prefs.getBool(kHasCircleKey) ?? false;
      final storedName = prefs.getString(kProfileNameKey);
      final mockUser =
          storedLoggedIn ? MockData.currentUser : null;
      AppUser? user;
      if (AppConfig.useMockData) {
        user = mockUser;
      } else {
        user = _userFromAuth(authUser);
        if (user != null && storedName != null && storedName.trim().isNotEmpty) {
          user = user.copyWith(name: storedName);
        }
      }
      state = SessionState(
        onboardingSeen: prefs.getBool(kOnboardingSeenKey) ?? false,
        isLoggedIn: AppConfig.useMockData
            ? storedLoggedIn
            : (authUser != null || storedLoggedIn),
        hasCircle: hasCircle,
        user: user,
        circle: AppConfig.useMockData && hasCircle ? MockData.circle : null,
      );
    } catch (_) {
      // keep default state if storage is unavailable
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingSeen: true);
    _persistBool(kOnboardingSeenKey, true);
  }

  Future<void> login(String phoneOrEmail) async {
    if (!AppConfig.useMockData) {
      final user = _userFromAuth(_authUser, fallbackName: phoneOrEmail);
      state = state.copyWith(isLoggedIn: true, user: user);
    } else {
      state = state.copyWith(
        isLoggedIn: true,
        user: MockData.currentUser.copyWith(phone: phoneOrEmail),
      );
    }
    _persistBool(kLoggedInKey, true);
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    DateTime? birthDate,
  }) async {
    final user = state.user;
    if (user == null) return;
    final updated = user.copyWith(name: name, gender: gender, birthDate: birthDate);
    state = state.copyWith(user: updated);
    if (name != null && name.trim().isNotEmpty) {
      _persistString(kProfileNameKey, name.trim());
    }
    if (AppConfig.useMockData) return;
    try {
      final repo = ref.read(circleRepositoryProvider);
      await repo.saveProfile(
        uid: user.id,
        name: updated.name,
        email: updated.phone,
        gender: updated.gender,
        birthDate: updated.birthDate,
      );
      final circleId = state.circle?.id;
      if (circleId != null) {
        await repo.updateMemberName(
          circleId: circleId,
          uid: user.id,
          name: updated.name,
        );
      }
    } catch (_) {
      // Profile stays local until the next successful sync.
    }
  }

  /// Pulls the profile and circle membership from Firestore (splash/login).
  Future<void> syncWithBackend() async {
    if (AppConfig.useMockData) return;
    final authUser = _authUser;
    if (authUser == null) return;
    state = state.copyWith(
      isLoggedIn: true,
      user: state.user ?? _userFromAuth(authUser),
    );
    _persistBool(kLoggedInKey, true);
    final repo = ref.read(circleRepositoryProvider);
    try {
      final profile = await repo
          .fetchProfile(authUser.uid)
          .timeout(const Duration(seconds: 4));
      if (profile != null && profile.name.trim().isNotEmpty) {
        state = state.copyWith(
          user: state.user?.copyWith(
                name: profile.name,
                gender: profile.gender,
                birthDate: profile.birthDate,
              ) ??
              profile,
        );
        _persistString(kProfileNameKey, profile.name);
      }
    } catch (_) {
      // Offline: keep the cached profile.
    }
    try {
      final circle = await repo
          .findMyCircle(authUser.uid)
          .timeout(const Duration(seconds: 4));
      if (circle != null) {
        state = state.copyWith(hasCircle: true, circle: circle);
        _persistBool(kHasCircleKey, true);
        _persistString(kCircleIdKey, circle.id);
      } else {
        state = state.copyWith(hasCircle: false);
        _persistBool(kHasCircleKey, false);
        _persistString(kCircleIdKey, '');
      }
    } catch (_) {
      // Offline: keep the cached membership flag.
    }
  }

  Future<void> createOrJoinCircle(String name) async {
    if (AppConfig.useMockData) {
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
      return;
    }
    final authUser = _authUser;
    if (authUser == null) throw StateError('Not signed in');
    final user = state.user;
    final ownerName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name
        : (authUser.email?.split('@').first ?? 'Owner');
    final circle = await ref.read(circleRepositoryProvider).createCircle(
          ownerUid: authUser.uid,
          ownerName: ownerName,
          name: name,
        );
    state = state.copyWith(hasCircle: true, circle: circle);
    _persistBool(kHasCircleKey, true);
    _persistString(kCircleIdKey, circle.id);
  }

  Future<void> logout() async {
    state = const SessionState(onboardingSeen: true);
    _persistBool(kLoggedInKey, false);
    _persistBool(kHasCircleKey, false);
    _persistString(kCircleIdKey, '');
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

  void _persistString(String key, String value) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance()
            .timeout(const Duration(seconds: 5));
        await prefs.setString(key, value);
      } catch (_) {
        // ignore storage failures
      }
    }());
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
