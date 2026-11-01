import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'family_orbit_model.dart';

/// Pure, testable layout for the Family Orbit stage. Mirrors the reference
/// HTML `layout()` exactly, with RTL mirroring for siblings and partner.
class OrbitLayoutResult {
  const OrbitLayoutResult({
    required this.positions,
    required this.usedRows,
    required this.rowY,
    required this.rowPeople,
    required this.stageSize,
  });

  final Map<String, Offset> positions;
  final List<int> usedRows;
  final Map<int, double> rowY;
  final Map<int, List<String>> rowPeople;
  final Size stageSize;
}

OrbitLayoutResult orbitLayout({
  required Map<String, OrbitPerson> people,
  required String focusId,
  required Size size,
  required bool rtl,
}) {
  final focus = people[focusId];
  final focusParents = focus?.parents ?? const <String>[];

  final grandparents = <String>{};
  for (final pid in focusParents) {
    final parent = people[pid];
    if (parent != null) grandparents.addAll(parent.parents);
  }

  final children = _kids(people, focusId);
  final grandchildren = <String>{};
  for (final cid in children) {
    grandchildren.addAll(_kids(people, cid));
  }
  final siblings = _siblings(people, focusId);

  final rows = <int, List<String>>{
    -2: grandparents.toList(),
    -1: focusParents,
    0: <String>[],
    1: children,
    2: grandchildren.toList(),
  };

  final usedRows = <int>[];
  for (final r in [-2, -1, 0, 1, 2]) {
    if (r == 0 || rows[r]!.isNotEmpty) {
      usedRows.add(r);
    }
  }

  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  const padT = 48.0;
  const padB = 40.0;
  final n = usedRows.length;
  final rowY = <int, double>{};
  for (var i = 0; i < n; i++) {
    rowY[usedRows[i]] = n == 1 ? h / 2 : padT + i * (h - padT - padB) / (n - 1);
  }

  final positions = <String, Offset>{};
  final rowPeople = <int, List<String>>{};

  for (final r in usedRows) {
    if (r == 0) continue;
    final a = rows[r]!;
    final step = a.isEmpty ? 0.0 : math.min(96.0, (w - 60) / a.length);
    final list = <String>[];
    for (var i = 0; i < a.length; i++) {
      final id = a[i];
      final x = cx + (i - (a.length - 1) / 2) * step;
      positions[id] = Offset(x, rowY[r]!);
      list.add(id);
    }
    rowPeople[r] = list;
  }

  final step0 = math.min(90.0, (cx - 44) / math.max(1, siblings.length));
  final side = rtl ? 1.0 : -1.0;
  final zeroList = <String>[];
  for (var i = 0; i < siblings.length; i++) {
    final id = siblings[i];
    positions[id] = Offset(cx + side * step0 * (i + 1), rowY[0]!);
    zeroList.add(id);
  }
  positions[focusId] = Offset(cx, rowY[0]!);
  zeroList.add(focusId);
  if (focus != null &&
      focus.spouse != null &&
      people.containsKey(focus.spouse!)) {
    final sp = focus.spouse!;
    positions[sp] = Offset(cx - side * step0, rowY[0]!);
    zeroList.add(sp);
  }
  rowPeople[0] = zeroList;

  return OrbitLayoutResult(
    positions: positions,
    usedRows: usedRows,
    rowY: rowY,
    rowPeople: rowPeople,
    stageSize: size,
  );
}

List<String> _kids(Map<String, OrbitPerson> people, String id) {
  final person = people[id];
  final spouseId = person?.spouse;
  return people.entries
      .where((e) {
        final p = e.value;
        if (p.id == id) return false;
        if (p.parents.contains(id)) return true;
        if (spouseId != null && p.parents.contains(spouseId)) return true;
        return false;
      })
      .map((e) => e.key)
      .toList(growable: false);
}

List<String> _siblings(Map<String, OrbitPerson> people, String id) {
  final person = people[id];
  if (person == null) return const <String>[];
  final myParents = person.parents;
  return people.entries
      .where(
        (e) => e.key != id && e.value.parents.any((p) => myParents.contains(p)),
      )
      .map((e) => e.key)
      .toList(growable: false);
}

/// Relation of [id] from the perspective of [focusId]. [selfId] marks "me".
String orbitRelation({
  required Map<String, OrbitPerson> people,
  required String id,
  required String focusId,
  required String selfId,
}) {
  if (id == focusId) return selfId == focusId ? 'You' : 'Selected';
  final focus = people[focusId];
  final p = people[id];
  if (focus == null || p == null) return 'Relative';

  if (focus.parents.contains(id)) return 'Parent';
  if (focus.spouse == id) return 'Partner';
  final kids = _kids(people, focusId);
  if (kids.contains(id)) return 'Child';
  if (_siblings(people, focusId).contains(id)) return 'Sibling';

  final grandparents = <String>{};
  for (final pid in focus.parents) {
    final parent = people[pid];
    if (parent != null) grandparents.addAll(parent.parents);
  }
  if (grandparents.contains(id)) return 'Grandparent';

  for (final cid in kids) {
    if (_kids(people, cid).contains(id)) return 'Grandchild';
  }
  return 'Relative';
}
