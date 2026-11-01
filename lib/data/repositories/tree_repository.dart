import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

class TreeException implements Exception {
  const TreeException(this.code);

  final String code;

  @override
  String toString() => 'TreeException($code)';
}

int treeGenerationOffset(String relation) {
  switch (relation) {
    case 'father':
    case 'mother':
      return -1;
    case 'grandfather':
    case 'grandmother':
      return -2;
    case 'son':
    case 'daughter':
      return 1;
    case 'paternal_uncle':
    case 'maternal_uncle':
    case 'paternal_aunt':
    case 'maternal_aunt':
      return -1;
    case 'brother':
    case 'sister':
    case 'husband':
    case 'wife':
    case 'other':
    default:
      return 0;
  }
}

/// Shared family tree for a circle.
///
/// Each person is a document in `circles/{circleId}/tree`. The document id of
/// the signed-in user is their own node. Graph edges are small arrays/lists on
/// the person so a single listener renders the whole tree.
class TreeRepository {
  TreeRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _tree(String circleId) =>
      _db.collection('circles').doc(circleId).collection('tree');

  TreePerson _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return TreePerson(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Relative',
      photoUrl: data['photoUrl'] as String?,
      about: data['about'] as String?,
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      gender: (data['gender'] as String?) ?? 'other',
      linkedUid: data['linkedUid'] as String?,
      generation: (data['generation'] as num?)?.toInt() ?? 0,
      relation: (data['relation'] as String?) ?? 'other',
      relatedToId: data['relatedToId'] as String?,
      parentIds: ((data['parentIds'] as List<dynamic>?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      spouseId: data['spouseId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Stream<List<TreePerson>> watchPersons(String circleId) {
    return _tree(circleId).snapshots().map((snapshot) {
      final persons = snapshot.docs.map(_fromDoc).toList();
      persons.sort((a, b) {
        final byGeneration = a.generation.compareTo(b.generation);
        if (byGeneration != 0) return byGeneration;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return persons;
    });
  }

  Future<List<TreePerson>> fetchPersons(String circleId) async {
    final snapshot = await _tree(circleId).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  Future<TreePerson?> fetchPerson({
    required String circleId,
    required String personId,
  }) async {
    final doc = await _tree(circleId).doc(personId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  /// Creates the signed-in user's node once, then keeps its linked name and
  /// photo fresh without touching any user-edited tree fields.
  Future<void> ensureSelfNode({
    required String circleId,
    required String uid,
    required String name,
    String? photoUrl,
  }) async {
    if (uid.isEmpty) return;
    final ownRef = _tree(circleId).doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ownRef.get();
    var docRef = ownRef;

    // A relative may already have been linked to this account before the
    // account opened the tree. Reuse that node instead of creating a duplicate.
    if (!snapshot.exists) {
      final linked = await _tree(circleId)
          .where('linkedUid', isEqualTo: uid)
          .limit(1)
          .get();
      if (linked.docs.isNotEmpty) {
        snapshot = linked.docs.first;
        docRef = snapshot.reference;
      }
    }

    final cleanName = name.trim();
    if (!snapshot.exists) {
      await docRef.set({
        'name': cleanName.isEmpty ? 'Me' : cleanName,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        'gender': 'other',
        'linkedUid': uid,
        'generation': 0,
        'relation': 'self',
        'parentIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    final data = snapshot.data() ?? const <String, dynamic>{};
    final updates = <String, dynamic>{};
    if (data['linkedUid'] != uid) updates['linkedUid'] = uid;
    if (cleanName.isNotEmpty && data['name'] != cleanName) {
      updates['name'] = cleanName;
    }
    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        data['photoUrl'] != photoUrl) {
      updates['photoUrl'] = photoUrl;
    }
    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.update(updates);
    }
  }

  Future<TreePerson> addRelative({
    required String circleId,
    required String uid,
    required TreePerson anchor,
    required String name,
    required String relation,
    required String gender,
    DateTime? birthDate,
    String? photoUrl,
    String? about,
    String? linkedUid,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const TreeException('name-required');
    }
    final snapshot = await _tree(circleId).get();
    final persons = snapshot.docs.map(_fromDoc).toList();
    if (linkedUid != null &&
        linkedUid.isNotEmpty &&
        persons.any((person) => person.linkedUid == linkedUid)) {
      throw const TreeException('member-already-linked');
    }

    final newRef = _tree(circleId).doc();
    final parentIds = <String>[];
    String? spouseId;
    final batch = _db.batch();
    bool updateAnchor = false;
    final anchorUpdates = <String, dynamic>{};

    TreePerson? parent;
    switch (relation) {
      case 'father':
      case 'mother':
        updateAnchor = true;
        anchorUpdates['parentIds'] = FieldValue.arrayUnion(<String>[newRef.id]);
        break;
      case 'son':
      case 'daughter':
        parentIds.add(anchor.id);
        if (anchor.spouseId != null) parentIds.add(anchor.spouseId!);
        break;
      case 'husband':
      case 'wife':
        spouseId = anchor.id;
        updateAnchor = true;
        anchorUpdates['spouseId'] = newRef.id;
        break;
      case 'brother':
      case 'sister':
        parentIds.addAll(anchor.parentIds);
        break;
      case 'grandfather':
      case 'grandmother':
        if (anchor.parentIds.isNotEmpty) {
          parent = _find(persons, anchor.parentIds.first);
          if (parent != null) {
            batch.update(_tree(circleId).doc(parent.id), {
              'parentIds': FieldValue.arrayUnion(<String>[newRef.id]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
        break;
      case 'paternal_uncle':
      case 'paternal_aunt':
      case 'maternal_uncle':
      case 'maternal_aunt':
        parent = _findParent(
          persons,
          anchor,
          paternal: relation.startsWith('paternal'),
        );
        if (parent != null) {
          parentIds.addAll(parent.parentIds);
        }
        break;
      default:
        break;
    }

    if (updateAnchor) {
      anchorUpdates['updatedAt'] = FieldValue.serverTimestamp();
      batch.update(_tree(circleId).doc(anchor.id), anchorUpdates);
    }

    batch.set(newRef, {
      'name': cleanName,
      'gender': gender,
      'generation': anchor.generation + treeGenerationOffset(relation),
      'relation': relation,
      'relatedToId': anchor.id,
      'parentIds': parentIds,
      'spouseId': ?spouseId,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
      if (photoUrl != null && photoUrl.trim().isNotEmpty)
        'photoUrl': photoUrl.trim(),
      if (about != null && about.trim().isNotEmpty) 'about': about.trim(),
      if (linkedUid != null && linkedUid.isNotEmpty) 'linkedUid': linkedUid,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    final created = await newRef.get();
    return _fromDoc(created);
  }

  Future<void> updatePerson({
    required String circleId,
    required TreePerson person,
    required String name,
    required String gender,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? photoUrl,
    bool clearPhoto = false,
    String? about,
    bool clearAbout = false,
    String? linkedUid,
    bool clearLinkedUid = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const TreeException('name-required');
    }
    final updates = <String, dynamic>{
      'name': cleanName,
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (clearBirthDate) {
      updates['birthDate'] = FieldValue.delete();
    } else if (birthDate != null) {
      updates['birthDate'] = Timestamp.fromDate(birthDate);
    }
    if (clearPhoto) {
      updates['photoUrl'] = FieldValue.delete();
    } else if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      updates['photoUrl'] = photoUrl.trim();
    }
    if (clearAbout) {
      updates['about'] = FieldValue.delete();
    } else if (about != null && about.trim().isNotEmpty) {
      updates['about'] = about.trim();
    }
    if (clearLinkedUid) {
      updates['linkedUid'] = FieldValue.delete();
    } else if (linkedUid != null && linkedUid.isNotEmpty) {
      if (linkedUid != person.linkedUid) {
        final snapshot = await _tree(circleId).get();
        final linked = snapshot.docs
            .map(_fromDoc)
            .any(
              (other) => other.id != person.id && other.linkedUid == linkedUid,
            );
        if (linked) throw const TreeException('member-already-linked');
      }
      updates['linkedUid'] = linkedUid;
    }
    await _tree(circleId).doc(person.id).update(updates);
  }

  Future<void> deletePerson({
    required String circleId,
    required String personId,
  }) async {
    final snapshot = await _tree(circleId).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      if (doc.id == personId) continue;
      final person = _fromDoc(doc);
      final updates = <String, dynamic>{};
      if (person.parentIds.contains(personId)) {
        updates['parentIds'] = person.parentIds
            .where((id) => id != personId)
            .toList();
      }
      if (person.spouseId == personId) {
        updates['spouseId'] = FieldValue.delete();
      }
      if (person.relatedToId == personId) {
        updates['relatedToId'] = FieldValue.delete();
      }
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        batch.update(doc.reference, updates);
      }
    }
    batch.delete(_tree(circleId).doc(personId));
    await batch.commit();
  }

  TreePerson? _find(List<TreePerson> persons, String id) {
    for (final person in persons) {
      if (person.id == id) return person;
    }
    return null;
  }

  TreePerson? _findParent(
    List<TreePerson> persons,
    TreePerson anchor, {
    required bool paternal,
  }) {
    for (final id in anchor.parentIds) {
      final parent = _find(persons, id);
      if (parent == null) continue;
      if (paternal &&
          (parent.relation == 'father' || parent.gender == 'male')) {
        return parent;
      }
      if (!paternal &&
          (parent.relation == 'mother' || parent.gender == 'female')) {
        return parent;
      }
    }
    for (final id in anchor.parentIds) {
      final parent = _find(persons, id);
      if (parent != null) return parent;
    }
    return null;
  }

  /// Links two people as spouses on both person docs.
  Future<void> linkSpouses({
    required String circleId,
    required String aId,
    required String bId,
  }) async {
    final batch = _db.batch();
    batch.update(_tree(circleId).doc(aId), {
      'spouseId': bId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_tree(circleId).doc(bId), {
      'spouseId': aId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}

final treeRepositoryProvider = Provider<TreeRepository>(
  (ref) => TreeRepository(),
);
