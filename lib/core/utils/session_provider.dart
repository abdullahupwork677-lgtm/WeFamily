import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';
import '../../data/repositories/mock_data.dart';
import '../constants/config.dart';
import 'circle_providers.dart';

const String kOnboardingSeenKey = 'onboarding_seen';
const String kOnboardingVersionKey = 'onboarding_version';
const int kOnboardingVersion = 2;
const String kLoggedInKey = 'logged_in';
const String kHasCircleKey = 'has_circle';
const String kCircleIdKey = kActiveCircleIdKey;
const String kProfileIdKey = 'profile_id';
const String kProfileNameKey = 'profile_name';
const String kProfileEmailKey = 'profile_email';
const String kProfilePhotoKey = 'profile_photo';

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
  StreamSubscription<User?>? _authSub;
  bool _syncing = false;
  bool _disposed = false;

  @override
  SessionState build() {
    ref.onDispose(() {
      _disposed = true;
      _authSub?.cancel();
      _authSub = null;
    });
    if (!AppConfig.useMockData) {
      try {
        _authSub ??= FirebaseAuth.instance.authStateChanges().listen(
          _onAuthStateChanged,
          onError: (_) {},
        );
      } catch (_) {
        // Firebase unavailable: fall back to cached prefs.
      }
    }
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

  AppUser? _userFromAuth(
    User? authUser, {
    String? fallbackName,
    String? fallbackPhotoUrl,
  }) {
    if (authUser == null) return null;
    final email = authUser.email ?? '';
    final local = email.contains('@') ? email.split('@').first : email;
    final display = authUser.displayName?.trim() ?? '';
    final fallback = fallbackName?.trim() ?? '';
    final name = display.isNotEmpty
        ? display
        : (fallback.isNotEmpty ? fallback : local);
    return AppUser(
      id: authUser.uid,
      name: name,
      phone: email,
      photoUrl: authUser.photoURL ?? fallbackPhotoUrl,
    );
  }

  AppUser? _cachedUser({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    if (id == null && name == null && email == null && photoUrl == null) {
      return null;
    }
    final trimmedName = name?.trim() ?? '';
    final local = (email != null && email.contains('@'))
        ? email.split('@').first
        : (email ?? '');
    return AppUser(
      id: id ?? '',
      name: trimmedName.isNotEmpty ? trimmedName : local,
      phone: email ?? '',
      photoUrl: photoUrl,
    );
  }

  /// Fires when Firebase restores the session after a cold start, which can be
  /// slower than the splash timeout. Keeps the header/map working without a
  /// second app launch.
  void _onAuthStateChanged(User? authUser) {
    if (authUser == null || _disposed) return;
    unawaited(_applyAuthUser(authUser));
  }

  Future<void> _applyAuthUser(User authUser) async {
    try {
      await loaded;
    } catch (_) {
      // Continue with the auth snapshot even if prefs failed.
    }
    if (_disposed) return;
    final current = state.user;
    final fromAuth = _userFromAuth(
      authUser,
      fallbackName: current != null && current.id == authUser.uid
          ? current.name
          : null,
      fallbackPhotoUrl: current?.photoUrl,
    );
    if (fromAuth == null) return;
    var merged = fromAuth;
    if (current != null && current.id == authUser.uid) {
      merged = merged.copyWith(
        name: current.name.trim().isNotEmpty ? current.name : merged.name,
        photoUrl: current.photoUrl ?? merged.photoUrl,
        gender: current.gender,
        birthDate: current.birthDate,
        language: current.language,
      );
    }
    state = state.copyWith(isLoggedIn: true, user: merged);
    _persistBool(kLoggedInKey, true);
    _persistUser(merged);
    unawaited(syncWithBackend());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final authUser = AppConfig.useMockData ? null : _authUser;
      final storedLoggedIn = prefs.getBool(kLoggedInKey) ?? false;
      final hasCircle = prefs.getBool(kHasCircleKey) ?? false;
      final cached = _cachedUser(
        id: prefs.getString(kProfileIdKey),
        name: prefs.getString(kProfileNameKey),
        email: prefs.getString(kProfileEmailKey),
        photoUrl: prefs.getString(kProfilePhotoKey),
      );
      final mockUser = storedLoggedIn ? MockData.currentUser : null;
      AppUser? user;
      if (AppConfig.useMockData) {
        user = mockUser;
      } else {
        user =
            _userFromAuth(
              authUser,
              fallbackName: cached?.name,
              fallbackPhotoUrl: cached?.photoUrl,
            ) ??
            cached;
        if (user != null && cached != null && user.id == cached.id) {
          final cachedName = cached.name.trim();
          if (cachedName.isNotEmpty && cachedName != user.name) {
            user = user.copyWith(name: cachedName);
          }
        }
      }
      if (user != null && !AppConfig.useMockData) {
        _persistUser(user);
      }
      final storedVersion =
          prefs.getInt(kOnboardingVersionKey) ??
          ((prefs.getBool(kOnboardingSeenKey) ?? false) ? 1 : 0);
      final currentlySeen = state.onboardingSeen;
      state = SessionState(
        onboardingSeen: currentlySeen || storedVersion >= kOnboardingVersion,
        isLoggedIn:
            state.isLoggedIn ||
            (AppConfig.useMockData
                ? storedLoggedIn
                : (authUser != null || storedLoggedIn)),
        hasCircle: state.hasCircle || hasCircle,
        user: state.user ?? user,
        circle:
            state.circle ??
            (AppConfig.useMockData && hasCircle ? MockData.circle : null),
      );
    } catch (_) {
      // keep default state if storage is unavailable
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingSeen: true);
    _persistBool(kOnboardingSeenKey, true);
    _persistInt(kOnboardingVersionKey, kOnboardingVersion);
  }

  Future<void> login(String phoneOrEmail) async {
    if (!AppConfig.useMockData) {
      final user = _userFromAuth(_authUser) ?? state.user;
      state = state.copyWith(isLoggedIn: true, user: user);
      if (user != null) _persistUser(user);
    } else {
      final user = MockData.currentUser.copyWith(phone: phoneOrEmail);
      state = state.copyWith(isLoggedIn: true, user: user);
      _persistUser(user);
    }
    _persistBool(kLoggedInKey, true);
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    DateTime? birthDate,
    String? photoUrl,
  }) async {
    var user = state.user;
    if (user == null) {
      user = _userFromAuth(_authUser);
      if (user == null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          user = _cachedUser(
            id: prefs.getString(kProfileIdKey),
            name: prefs.getString(kProfileNameKey),
            email: prefs.getString(kProfileEmailKey),
            photoUrl: prefs.getString(kProfilePhotoKey),
          );
        } catch (_) {
          // ignore storage failures
        }
      }
    }
    if (user == null) return;
    final updated = user.copyWith(
      name: name,
      gender: gender,
      birthDate: birthDate,
      photoUrl: photoUrl,
    );
    state = state.copyWith(user: updated);
    _persistUser(updated);
    if (AppConfig.useMockData) return;
    try {
      final repo = ref.read(circleRepositoryProvider);
      await repo.saveProfile(
        uid: updated.id,
        name: updated.name,
        email: updated.phone,
        gender: updated.gender,
        birthDate: updated.birthDate,
        photoUrl: updated.photoUrl,
      );
      final circleId = state.circle?.id;
      if (circleId != null) {
        await repo.updateMemberName(
          circleId: circleId,
          uid: updated.id,
          name: updated.name,
          photoUrl: updated.photoUrl,
        );
      }
    } catch (_) {
      // Profile stays local until the next successful sync.
    }
  }

  /// Pulls the profile and circle membership from Firestore (splash/login).
  ///
  /// Never overwrites cached data on failure, and repairs a missing
  /// `users/{uid}` document so the name survives the next login.
  Future<void> syncWithBackend() async {
    if (AppConfig.useMockData || _syncing) return;
    try {
      await loaded;
    } catch (_) {
      // Continue with whatever state we have.
    }
    if (_disposed) return;
    final authUser = _authUser;
    if (authUser == null) return;
    _syncing = true;
    try {
      final existing = state.user;
      String? profileName;
      var profileMissing = false;
      final fromAuth = _userFromAuth(
        authUser,
        fallbackName: existing != null && existing.id == authUser.uid
            ? existing.name
            : null,
        fallbackPhotoUrl: existing?.photoUrl,
      );
      if (fromAuth == null) return;
      var user = (existing != null && existing.id == authUser.uid)
          ? existing.copyWith(
              phone: fromAuth.phone,
              photoUrl: existing.photoUrl ?? fromAuth.photoUrl,
            )
          : fromAuth;
      state = state.copyWith(isLoggedIn: true, user: user);
      _persistBool(kLoggedInKey, true);
      _persistUser(user);

      final repo = ref.read(circleRepositoryProvider);
      try {
        final profile = await repo
            .fetchProfile(authUser.uid)
            .timeout(const Duration(seconds: 4));
        if (profile != null && profile.name.trim().isNotEmpty) {
          profileName = profile.name;
          user = user.copyWith(
            name: profile.name,
            gender: profile.gender,
            birthDate: profile.birthDate,
            photoUrl: profile.photoUrl ?? user.photoUrl,
          );
          state = state.copyWith(user: user);
          _persistUser(user);
        } else if (profile == null) {
          profileMissing = true;
        }
      } catch (_) {
        // Offline: keep the cached profile.
      }
      try {
        final circles = await repo
            .findMyCircles(authUser.uid)
            .timeout(const Duration(seconds: 4));
        if (circles.isNotEmpty) {
          final storedId = await _storedCircleId();
          final circle = circles.firstWhere(
            (item) => item.id == storedId,
            orElse: () => circles.first,
          );
          state = state.copyWith(hasCircle: true, circle: circle);
          _persistBool(kHasCircleKey, true);
          _persistString(kCircleIdKey, circle.id);
          await ref.read(activeCircleIdProvider.notifier).select(circle.id);
          if (profileName != null) {
            try {
              await repo.updateMemberName(
                circleId: circle.id,
                uid: authUser.uid,
                name: profileName,
              );
            } catch (_) {
              // Best effort; retried on the next sync.
            }
          }
          if (profileMissing) {
            var repairName = user.name.trim();
            CircleMember? self;
            try {
              self = await repo
                  .fetchMember(circleId: circle.id, uid: authUser.uid)
                  .timeout(const Duration(seconds: 4));
            } catch (_) {
              // Fall back to the cached name.
            }
            final memberName = self?.name.trim() ?? '';
            final local = (authUser.email ?? '').split('@').first;
            if (memberName.isNotEmpty &&
                (repairName.isEmpty ||
                    repairName == local ||
                    repairName == authUser.email)) {
              repairName = memberName;
              user = user.copyWith(
                name: memberName,
                photoUrl: self?.photoUrl ?? user.photoUrl,
              );
              state = state.copyWith(user: user);
              _persistUser(user);
            }
            if (repairName.isNotEmpty) {
              try {
                await repo.saveProfile(
                  uid: authUser.uid,
                  name: repairName,
                  email: user.phone,
                  photoUrl: user.photoUrl,
                );
              } catch (_) {
                // Best effort; retried on the next sync.
              }
            }
          }
        } else {
          state = state.copyWith(hasCircle: false);
          _persistBool(kHasCircleKey, false);
          _persistString(kCircleIdKey, '');
          if (profileMissing && user.name.trim().isNotEmpty) {
            try {
              await repo.saveProfile(
                uid: authUser.uid,
                name: user.name,
                email: user.phone,
                photoUrl: user.photoUrl,
              );
            } catch (_) {
              // Best effort; retried on the next sync.
            }
          }
        }
      } catch (_) {
        // Offline: keep the cached membership flag.
      }
    } finally {
      _syncing = false;
    }
  }

  Future<String?> _storedCircleId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(kCircleIdKey);
      return id == null || id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  Future<void> createOrJoinCircle(String name) async {
    if (AppConfig.useMockData) {
      final circle = FamilyCircle(
        id: MockData.circle.id,
        name: name,
        ownerUid: state.user?.id ?? 'u1',
        inviteCode: MockData.circle.inviteCode,
        memberUids: MockData.circle.memberUids,
      );
      state = state.copyWith(hasCircle: true, circle: circle);
      _persistBool(kHasCircleKey, true);
      return;
    }
    final authUser = _authUser;
    if (authUser == null) throw StateError('Not signed in');
    final user = state.user;
    final ownerName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name
        : (authUser.email?.split('@').first ?? 'Owner');
    final repo = ref.read(circleRepositoryProvider);
    final circle = await repo.createCircle(
      ownerUid: authUser.uid,
      ownerName: ownerName,
      name: name,
      ownerPhotoUrl: user?.photoUrl,
    );
    state = state.copyWith(hasCircle: true, circle: circle);
    _persistBool(kHasCircleKey, true);
    _persistString(kCircleIdKey, circle.id);
    await ref.read(activeCircleIdProvider.notifier).select(circle.id);
    if (user == null) {
      final restored = _userFromAuth(authUser, fallbackName: ownerName);
      if (restored != null) {
        state = state.copyWith(user: restored);
        _persistUser(restored);
      }
    }
    try {
      await repo.saveProfile(
        uid: authUser.uid,
        name: ownerName,
        email: authUser.email,
        photoUrl: user?.photoUrl,
      );
    } catch (_) {
      // Best effort; syncWithBackend retries later.
    }
  }

  Future<void> adoptCircle(FamilyCircle circle) async {
    state = state.copyWith(hasCircle: true, circle: circle);
    _persistBool(kHasCircleKey, true);
    _persistString(kCircleIdKey, circle.id);
    await ref.read(activeCircleIdProvider.notifier).select(circle.id);
  }

  Future<void> clearCircle() async {
    state = SessionState(
      onboardingSeen: state.onboardingSeen,
      isLoggedIn: state.isLoggedIn,
      hasCircle: false,
      user: state.user,
    );
    _persistBool(kHasCircleKey, false);
    _persistString(kCircleIdKey, '');
  }

  Future<void> logout() async {
    state = SessionState(onboardingSeen: state.onboardingSeen);
    _persistBool(kLoggedInKey, false);
    _persistBool(kHasCircleKey, false);
    _persistString(kCircleIdKey, '');
    _removeKeys([
      kProfileIdKey,
      kProfileNameKey,
      kProfileEmailKey,
      kProfilePhotoKey,
    ]);
  }

  void _persistUser(AppUser user) {
    if (user.id.isNotEmpty) _persistString(kProfileIdKey, user.id);
    if (user.name.trim().isNotEmpty) {
      _persistString(kProfileNameKey, user.name.trim());
    }
    if (user.phone.trim().isNotEmpty) {
      _persistString(kProfileEmailKey, user.phone.trim());
    }
    final photo = user.photoUrl;
    if (photo != null && photo.isNotEmpty) {
      _persistString(kProfilePhotoKey, photo);
    }
  }

  // Storage must never block navigation: persist in background, ignore errors.
  void _persistBool(String key, bool value) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
        );
        await prefs.setBool(key, value);
      } catch (_) {
        // ignore storage failures
      }
    }());
  }

  void _persistString(String key, String value) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
        );
        await prefs.setString(key, value);
      } catch (_) {
        // ignore storage failures
      }
    }());
  }

  void _persistInt(String key, int value) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
        );
        await prefs.setInt(key, value);
      } catch (_) {
        // ignore storage failures
      }
    }());
  }

  void _removeKeys(List<String> keys) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
        );
        for (final key in keys) {
          await prefs.remove(key);
        }
      } catch (_) {
        // ignore storage failures
      }
    }());
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
