import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/circle_repository.dart';
import '../../data/repositories/mock_data.dart';
import '../constants/config.dart';
import '../services/auth_service.dart';

/// UID of the signed-in user (mock user in demo mode).
final currentUidProvider = Provider<String?>((ref) {
  if (AppConfig.useMockData) return MockData.currentUser.id;
  final user = ref.watch(authStateProvider).value;
  return user?.uid;
});

/// The circle the signed-in user belongs to, live from Firestore.
final myCircleProvider = StreamProvider<FamilyCircle?>((ref) {
  if (AppConfig.useMockData) return Stream.value(MockData.circle);
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(circleRepositoryProvider).watchMyCircle(uid);
});

/// Members of the current circle, live from Firestore.
final circleMembersProvider = StreamProvider<List<CircleMember>>((ref) {
  if (AppConfig.useMockData) return Stream.value(MockData.members);
  final circle = ref.watch(myCircleProvider).value;
  if (circle == null) return Stream.value(const <CircleMember>[]);
  return ref.watch(circleRepositoryProvider).watchMembers(circle.id);
});

/// Synchronous member list for the map/sheet (empty while loading).
final liveMembersProvider = Provider<List<CircleMember>>((ref) {
  return ref.watch(circleMembersProvider).value ?? const <CircleMember>[];
});
