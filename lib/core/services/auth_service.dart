import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase auth state; empty stream when Firebase is unavailable (tests/offline).
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (_) {
    return const Stream<User?>.empty();
  }
});

/// First auth event with a timeout; null when signed out or unavailable.
Future<User?> firstAuthUser({
  Duration timeout = const Duration(seconds: 4),
}) async {
  try {
    return await FirebaseAuth.instance.authStateChanges().first.timeout(
      timeout,
    );
  } catch (_) {
    return null;
  }
}
