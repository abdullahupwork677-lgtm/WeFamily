import 'package:wefamily/data/models/models.dart';

/// Pure data model used by the Family Orbit layout module.
/// Mirrors the reference shape: { id, name, type, parents[], spouse }.
class OrbitPerson {
  const OrbitPerson({
    required this.id,
    required this.name,
    required this.type,
    required this.parents,
    required this.spouse,
    this.photoUrl,
  });

  final String id;
  final String name;

  /// One of: m, f, em, ef, b, g
  final String type;
  final List<String> parents;
  final String? spouse;
  final String? photoUrl;

  bool get isElder => type == 'em' || type == 'ef';
  bool get isChild => type == 'b' || type == 'g';
  bool get isMale => type == 'm' || type == 'em' || type == 'b';

  OrbitPerson copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? parents,
    String? spouse,
    String? photoUrl,
  }) {
    return OrbitPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parents: parents ?? this.parents,
      spouse: spouse ?? this.spouse,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  static OrbitPerson fromTree(TreePerson p, {bool alternateUnknown = false}) {
    final age = p.birthDate == null
        ? 30
        : DateTime.now().difference(p.birthDate!).inDays ~/ 365;
    final isMale = p.gender == 'male';
    final isFemale = p.gender == 'female';
    final rel = p.relation;
    final elder =
        age >= 60 ||
        rel == 'grandfather' ||
        rel == 'grandmother' ||
        rel == 'paternal_uncle' ||
        rel == 'maternal_uncle' ||
        rel == 'paternal_aunt' ||
        rel == 'maternal_aunt';
    final child = age < 16;

    String type;
    if (elder) {
      type = isMale ? 'em' : 'ef';
    } else if (child) {
      type = isMale ? 'b' : 'g';
    } else if (isMale) {
      type = 'm';
    } else if (isFemale) {
      type = 'f';
    } else {
      final maleRels = {
        'father',
        'grandfather',
        'son',
        'brother',
        'husband',
        'paternal_uncle',
        'maternal_uncle',
      };
      final femaleRels = {
        'mother',
        'grandmother',
        'daughter',
        'sister',
        'wife',
        'paternal_aunt',
        'maternal_aunt',
      };
      if (maleRels.contains(rel)) {
        type = 'm';
      } else if (femaleRels.contains(rel)) {
        type = 'f';
      } else {
        type = alternateUnknown ? 'f' : 'm';
      }
    }

    return OrbitPerson(
      id: p.id,
      name: p.name.trim().isEmpty ? 'Relative' : p.name.trim(),
      type: type,
      parents: List<String>.from(p.parentIds),
      spouse: p.spouseId,
      photoUrl: p.photoUrl,
    );
  }
}
