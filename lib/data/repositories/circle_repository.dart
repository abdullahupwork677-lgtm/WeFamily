import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

/// Firestore access for circles, members and user profiles.
///
/// Task 4 keeps the surface small (create + sync + location writes); Task 5
/// adds join-by-code, code rotation and member management on top.
class CircleRepository {
  CircleRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  CollectionReference<Map<String, dynamic>> get _circles =>
      _db.collection('circles');

  DocumentReference<Map<String, dynamic>> _circleDoc(String circleId) =>
      _circles.doc(circleId);

  CollectionReference<Map<String, dynamic>> _members(String circleId) =>
      _circleDoc(circleId).collection('members');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  FamilyCircle _circleFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return FamilyCircle(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Family',
      ownerUid: (data['ownerUid'] as String?) ?? '',
      inviteCode: (data['inviteCode'] as String?) ?? '',
      memberUids: ((data['memberUids'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  CircleMember _memberFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final last = (data['lastLocation'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final DateTime? updated =
        (last['updatedAt'] as Timestamp?)?.toDate() ??
            (data['updatedAt'] as Timestamp?)?.toDate();
    final DateTime? sinceAt = (data['sinceAt'] as Timestamp?)?.toDate();
    return CircleMember(
      uid: doc.id,
      name: (data['name'] as String?) ?? 'Member',
      relation: (data['relation'] as String?) ?? 'other',
      photoUrl: data['photoUrl'] as String?,
      role: (data['role'] as String?) ?? 'member',
      sharingLocation: (data['sharingLocation'] as bool?) ?? true,
      ghostMode: (data['ghostMode'] as bool?) ?? false,
      lat: (last['lat'] as num?)?.toDouble(),
      lng: (last['lng'] as num?)?.toDouble(),
      batteryLevel: (data['batteryLevel'] as num?)?.toInt(),
      placeLabel: data['placeLabel'] as String?,
      lastUpdated: updated,
      isMoving: (data['isMoving'] as bool?) ?? false,
      speedKmh: (last['speed'] as num?)?.toDouble(),
      headingDeg: (last['heading'] as num?)?.toDouble(),
      sinceAt: sinceAt,
    );
  }

  Stream<FamilyCircle?> watchMyCircle(String uid) {
    return _circles
        .where('memberUids', arrayContains: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : _circleFromDoc(snap.docs.first));
  }

  Future<FamilyCircle?> findMyCircle(String uid) async {
    final snap = await _circles
        .where('memberUids', arrayContains: uid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _circleFromDoc(snap.docs.first);
  }

  Stream<List<CircleMember>> watchMembers(String circleId) {
    return _members(circleId).snapshots().map((snap) {
      final list = snap.docs.map(_memberFromDoc).toList();
      list.sort((a, b) {
        if (a.role == b.role) return a.name.compareTo(b.name);
        return a.role == 'owner' ? -1 : 1;
      });
      return list;
    });
  }

  /// Creates a circle with a unique invite code and registers the owner as a
  /// member. The invite code is reserved in `inviteCodes/{code}` inside the
  /// same transaction.
  Future<FamilyCircle> createCircle({
    required String ownerUid,
    required String ownerName,
    required String name,
  }) async {
    final circleRef = _circles.doc();
    for (var attempt = 0; attempt < 6; attempt++) {
      final code = _randomCode();
      final codeRef = _db.collection('inviteCodes').doc(code);
      final circle = FamilyCircle(
        id: circleRef.id,
        name: name,
        ownerUid: ownerUid,
        inviteCode: code,
        memberUids: [ownerUid],
      );
      final created = await _db.runTransaction<bool>((tx) async {
        final existing = await tx.get(codeRef);
        if (existing.exists) return false;
        tx.set(codeRef, {
          'circleId': circleRef.id,
          'ownerUid': ownerUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.set(circleRef, {
          'name': name,
          'ownerUid': ownerUid,
          'inviteCode': code,
          'memberUids': [ownerUid],
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.set(_members(circleRef.id).doc(ownerUid), {
          'name': ownerName,
          'relation': 'other',
          'role': 'owner',
          'sharingLocation': true,
          'ghostMode': false,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (created) return circle;
    }
    throw StateError('Could not allocate a unique invite code');
  }

  Future<void> updateMyLocation({
    required String circleId,
    required String uid,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
    required bool isMoving,
    required int? batteryLevel,
    required DateTime? sinceAt,
    required String placeLabel,
  }) {
    return _members(circleId).doc(uid).set({
      'lastLocation': {
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'isMoving': isMoving,
      'batteryLevel': batteryLevel,
      'sinceAt': sinceAt == null ? null : Timestamp.fromDate(sinceAt),
      if (placeLabel.isNotEmpty) 'placeLabel': placeLabel,
      'dateKey': _dateKey(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> updateSharingState({
    required String circleId,
    required String uid,
    required bool sharingLocation,
    required bool ghostMode,
  }) {
    return _members(circleId).doc(uid).set({
      'sharingLocation': sharingLocation,
      'ghostMode': ghostMode,
    }, SetOptions(merge: true));
  }

  Future<void> updateMemberName({
    required String circleId,
    required String uid,
    required String name,
  }) {
    return _members(circleId).doc(uid).set(
      {'name': name},
      SetOptions(merge: true),
    );
  }

  Future<AppUser?> fetchProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return AppUser(
      id: uid,
      name: (data['name'] as String?) ?? '',
      phone: (data['email'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      gender: data['gender'] as String?,
      language: (data['language'] as String?) ?? 'en',
    );
  }

  Future<void> saveProfile({
    required String uid,
    required String name,
    String? email,
    String? gender,
    DateTime? birthDate,
  }) {
    return _userDoc(uid).set({
      'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      'gender': ?gender,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _randomCode() {
    final random = Random.secure();
    return List.generate(6, (_) => _codeAlphabet[random.nextInt(_codeAlphabet.length)])
        .join();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

final circleRepositoryProvider =
    Provider<CircleRepository>((ref) => CircleRepository());
