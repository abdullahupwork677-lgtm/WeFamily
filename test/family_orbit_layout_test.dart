import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wefamily/features/tree/family_orbit/family_orbit_layout.dart';
import 'package:wefamily/features/tree/family_orbit/family_orbit_model.dart';

OrbitPerson _person(
  String id, {
  String type = 'm',
  List<String> parents = const [],
  String? spouse,
}) {
  return OrbitPerson(
    id: id,
    name: id,
    type: type,
    parents: parents,
    spouse: spouse,
  );
}

void main() {
  group('orbitLayout', () {
    test('places spouse beside focus when focus has no siblings', () {
      final people = {
        'dad': _person('dad', spouse: 'mom'),
        'mom': _person('mom', type: 'f', spouse: 'dad'),
        'kid': _person('kid', type: 'b', parents: const ['dad', 'mom']),
      };

      final layout = orbitLayout(
        people: people,
        focusId: 'dad',
        size: const Size(360, 420),
        rtl: false,
      );

      final dad = layout.positions['dad']!;
      final mom = layout.positions['mom']!;
      expect((dad - mom).distance, greaterThan(40));
      expect(dad.dx, isNot(equals(mom.dx)));
    });
  });

  group('orbitRelation', () {
    test('labels a sibling spouse as relative, not grandchild', () {
      final people = {
        'me': _person('me'),
        'sibling': _person('sibling', parents: const ['parent']),
        'inLaw': _person('inLaw', spouse: 'sibling'),
      };

      expect(
        orbitRelation(people: people, id: 'inLaw', focusId: 'me', selfId: 'me'),
        'Relative',
      );
    });

    test('labels an actual grandchild correctly', () {
      final people = {
        'me': _person('me'),
        'child': _person('child', type: 'b', parents: const ['me']),
        'grandchild': _person(
          'grandchild',
          type: 'b',
          parents: const ['child'],
        ),
      };

      expect(
        orbitRelation(
          people: people,
          id: 'grandchild',
          focusId: 'me',
          selfId: 'me',
        ),
        'Grandchild',
      );
    });
  });
}
