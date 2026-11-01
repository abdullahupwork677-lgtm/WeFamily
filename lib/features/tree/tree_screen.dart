import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/icon_3d.dart';
import '../../data/models/models.dart';
import '../../data/repositories/tree_repository.dart';
import 'add_relative_sheet.dart';
import 'person_profile_screen.dart';
import 'tree_providers.dart';
import 'tree_relations.dart';

class TreeScreen extends ConsumerStatefulWidget {
  const TreeScreen({super.key});

  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  bool _listView = false;
  String _search = '';
  final Set<String> _ensuredCircles = <String>{};
  final Set<String> _ensuringCircles = <String>{};

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FamilyCircle? circle = ref.watch(myCircleProvider).value;
    final AsyncValue<List<TreePerson>> tree = ref.watch(treePersonsProvider);
    final List<TreePerson> persons = tree.value ?? const <TreePerson>[];
    final String? uid = ref.watch(currentUidProvider);

    if (!AppConfig.useMockData && circle != null) {
      unawaited(_ensureSelf(circle));
    }

    final String query = _search.trim().toLowerCase();
    final filtered = query.isEmpty
        ? persons
        : persons
              .where((person) => person.name.toLowerCase().contains(query))
              .toList();

    final TreePerson? self = _selfPerson(persons, uid);
    final bool isEmpty = !tree.isLoading && persons.isEmpty;
    final bool noResults = !isEmpty && filtered.isEmpty;
    final int generations = persons
        .map((person) => person.generation)
        .toSet()
        .length;
    final int linked = persons
        .where((person) => person.linkedUid != null)
        .length;

    return Scaffold(
      backgroundColor: AhlColors.background,
      appBar: AppBar(
        backgroundColor: AhlColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.tree,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          _ViewToggle(
            listView: _listView,
            onChanged: (value) => setState(() => _listView = value),
            l10n: l10n,
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: circle == null || isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: self == null ? null : () => _addRelative(self),
              backgroundColor: AhlColors.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              highlightElevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon3D('link', size: 26),
              label: Text(
                l10n.addRelative,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBF8FF), AhlColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (query.isEmpty)
              _TreeHero(
                l10n: l10n,
                people: persons.length,
                generations: generations,
                linked: linked,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.searchTree,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AhlColors.inkMedium,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _search.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => setState(() => _search = ''),
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            Expanded(
              child: tree.hasError && persons.isEmpty
                  ? _TreeError(
                      message: l10n.error,
                      retry: l10n.retry,
                      onRetry: () => ref.invalidate(treePersonsProvider),
                    )
                  : tree.isLoading && persons.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : isEmpty
                  ? _TreeEmpty(
                      l10n: l10n,
                      onAdd: self == null ? null : () => _addRelative(self),
                    )
                  : noResults
                  ? _NoResults(l10n: l10n)
                  : _listView
                  ? _PersonList(
                      persons: filtered,
                      selfUid: uid,
                      l10n: l10n,
                      onAddRelative: _addRelative,
                    )
                  : _TreeView(
                      persons: filtered,
                      selfUid: uid,
                      l10n: l10n,
                      onAddRelative: _addRelative,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ensureSelf(FamilyCircle circle) async {
    if (_ensuredCircles.contains(circle.id) ||
        _ensuringCircles.contains(circle.id)) {
      return;
    }
    final uid = ref.read(currentUidProvider);
    if (uid == null || uid.isEmpty) return;
    final members = ref.read(liveMembersProvider);
    CircleMember? self;
    for (final member in members) {
      if (member.uid == uid) {
        self = member;
        break;
      }
    }
    final session = ref.read(sessionProvider).user;
    final name = (self?.name ?? session?.name ?? '').trim();
    if (name.isEmpty) return;
    _ensuringCircles.add(circle.id);
    try {
      await ref
          .read(treeRepositoryProvider)
          .ensureSelfNode(
            circleId: circle.id,
            uid: uid,
            name: name,
            photoUrl: self?.photoUrl ?? session?.photoUrl,
          );
      _ensuredCircles.add(circle.id);
    } catch (_) {
      // Retried on the next rebuild or tab switch.
    } finally {
      _ensuringCircles.remove(circle.id);
    }
  }

  TreePerson? _selfPerson(List<TreePerson> persons, String? uid) {
    if (uid == null) return null;
    for (final person in persons) {
      if (person.id == uid || person.linkedUid == uid) return person;
    }
    return null;
  }

  Future<void> _addRelative(TreePerson anchor) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FamilyCircle? circle = ref.read(myCircleProvider).value;
    final String? uid = ref.read(currentUidProvider);
    if (circle == null || uid == null) return;
    final persons = ref.read(treePersonsProvider).value ?? const <TreePerson>[];
    final members = ref.read(liveMembersProvider);
    final draft = await showAddRelativeSheet(
      context,
      anchor: anchor,
      circleMembers: members,
      persons: persons,
      selfUid: uid,
    );
    if (draft == null || !mounted) return;
    if (draft.relation == 'father' || draft.relation == 'mother') {
      if (anchor.parentIds.length >= 2) {
        _snack(l10n.alreadyTwoParents);
        return;
      }
    }
    if (draft.relation == 'husband' || draft.relation == 'wife') {
      if (anchor.spouseId != null) {
        _snack(l10n.partnerAlready);
        return;
      }
    }
    if (draft.relation == 'brother' || draft.relation == 'sister') {
      if (anchor.parentIds.isEmpty) {
        _snack(l10n.treeSiblingNeedsParent);
        return;
      }
    }
    if (AppConfig.useMockData) {
      _snack(l10n.personAdded(draft.name));
      return;
    }
    try {
      final repo = ref.read(treeRepositoryProvider);
      final created = await repo.addRelative(
        circleId: circle.id,
        uid: uid,
        anchor: anchor,
        name: draft.name,
        relation: draft.relation,
        gender: draft.gender,
        birthDate: draft.birthDate,
        photoUrl: draft.photoUrl,
        about: draft.about,
        linkedUid: draft.linkedUid,
      );
      if ((draft.relation == 'father' || draft.relation == 'mother') &&
          anchor.parentIds.isNotEmpty) {
        await repo.linkSpouses(
          circleId: circle.id,
          aId: created.id,
          bId: anchor.parentIds.first,
        );
      }
      if (mounted) _snack(l10n.personAdded(draft.name));
    } on TreeException catch (error) {
      if (!mounted) return;
      _snack(
        error.code == 'member-already-linked'
            ? l10n.memberAlreadyLinked
            : l10n.treeSaveError,
      );
    } catch (_) {
      if (mounted) _snack(l10n.treeSaveError);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.listView,
    required this.onChanged,
    required this.l10n,
  });

  final bool listView;
  final ValueChanged<bool> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AhlColors.softShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            icon: Icons.account_tree_rounded,
            selected: !listView,
            tooltip: l10n.treeView,
            onTap: () => onChanged(false),
          ),
          _ToggleIcon(
            icon: Icons.view_agenda_outlined,
            selected: listView,
            tooltip: l10n.listView,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 34,
          decoration: BoxDecoration(
            gradient: selected ? AhlColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : AhlColors.inkMedium,
          ),
        ),
      ),
    );
  }
}

class _TreeHero extends StatelessWidget {
  const _TreeHero({
    required this.l10n,
    required this.people,
    required this.generations,
    required this.linked,
  });

  final AppLocalizations l10n;
  final int people;
  final int generations;
  final int linked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), AhlColors.primary, Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x335B21B6),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -46,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -54,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AhlColors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AhlColors.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.tree.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AhlColors.gold,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.treeHeroTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.treeHeroBody,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon3D('notebook', size: 78),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    _HeroStat(value: people, label: l10n.treePeople),
                    const _HeroDivider(),
                    _HeroStat(value: generations, label: l10n.treeGenerations),
                    const _HeroDivider(),
                    _HeroStat(value: linked, label: l10n.treeInCircle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.16),
    );
  }
}

class _TreeView extends StatelessWidget {
  const _TreeView({
    required this.persons,
    required this.selfUid,
    required this.l10n,
    required this.onAddRelative,
  });

  final List<TreePerson> persons;
  final String? selfUid;
  final AppLocalizations l10n;
  final ValueChanged<TreePerson> onAddRelative;

  @override
  Widget build(BuildContext context) {
    final generations = <int, List<TreePerson>>{};
    for (final person in persons) {
      generations.putIfAbsent(person.generation, () => []).add(person);
    }
    final keys = generations.keys.toList()..sort();

    return InteractiveViewer(
      maxScale: 2.4,
      minScale: 0.6,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
        child: Column(
          children: [
            for (int i = 0; i < keys.length; i++) ...[
              _GenerationHeader(
                label: l10n.generationLabel('${i + 1}'),
                count: generations[keys[i]]!.length,
              ),
              const SizedBox(height: 10),
              _GenerationRow(
                persons: generations[keys[i]]!,
                selfUid: selfUid,
                l10n: l10n,
                onAddRelative: onAddRelative,
              ),
              if (i < keys.length - 1)
                const SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: CustomPaint(painter: _TreeConnectorPainter()),
                ),
            ],
            if (persons.length <= 1)
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: _TreeHint(l10n: l10n),
              ),
          ],
        ),
      ),
    );
  }
}

class _GenerationHeader extends StatelessWidget {
  const _GenerationHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AhlColors.gold.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AhlColors.gold.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF8A6A1F),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AhlColors.gold.withValues(alpha: 0.45),
                  AhlColors.gold.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AhlColors.inkMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GenerationRow extends StatelessWidget {
  const _GenerationRow({
    required this.persons,
    required this.selfUid,
    required this.l10n,
    required this.onAddRelative,
  });

  final List<TreePerson> persons;
  final String? selfUid;
  final AppLocalizations l10n;
  final ValueChanged<TreePerson> onAddRelative;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: persons
          .map(
            (person) => _TreePersonNode(
              person: person,
              isSelf:
                  person.linkedUid == selfUid ||
                  (person.id == selfUid && selfUid != null),
              l10n: l10n,
              onAdd: () => onAddRelative(person),
            ),
          )
          .toList(),
    );
  }
}

class _TreePersonNode extends StatelessWidget {
  const _TreePersonNode({
    required this.person,
    required this.isSelf,
    required this.l10n,
    required this.onAdd,
  });

  final TreePerson person;
  final bool isSelf;
  final AppLocalizations l10n;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bool inCircle = person.linkedUid != null;
    final String label = isSelf
        ? l10n.relationSelf
        : person.relation == 'self'
        ? l10n.relationSelf
        : treeRelationLabel(l10n, person.relation);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PersonProfileScreen(person: person),
          ),
        );
      },
      child: SizedBox(
        width: 128,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 18, 10, 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelf
                      ? AhlColors.gold.withValues(alpha: 0.55)
                      : Colors.white,
                  width: isSelf ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelf
                        ? const Color(0x225B21B6)
                        : const Color(0x0F000000),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelf
                              ? AhlColors.goldPurpleBorder
                              : LinearGradient(
                                  colors: [
                                    AhlColors.primary.withValues(alpha: 0.22),
                                    AhlColors.gold.withValues(alpha: 0.22),
                                  ],
                                ),
                        ),
                        child: AvatarCircle(
                          name: person.name,
                          photoUrl: person.photoUrl,
                          size: 54,
                        ),
                      ),
                      if (inCircle)
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AhlColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AhlColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelf
                          ? AhlColors.gold.withValues(alpha: 0.16)
                          : AhlColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelf
                            ? const Color(0xFF8A6A1F)
                            : AhlColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (person.birthDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${person.birthDate!.year}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AhlColors.inkLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 7,
              right: 7,
              child: _MiniAddButton(l10n: l10n, onTap: onAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAddButton extends StatelessWidget {
  const _MiniAddButton({required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.addRelative,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            gradient: AhlColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x335B21B6),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, size: 15, color: Colors.white),
        ),
      ),
    );
  }
}

class _TreeConnectorPainter extends CustomPainter {
  const _TreeConnectorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AhlColors.gold.withValues(alpha: 0.18),
          AhlColors.gold.withValues(alpha: 0.65),
          AhlColors.gold.withValues(alpha: 0.18),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final junctionY = size.height * 0.46;
    final spread = size.width < 320 ? 34.0 : 46.0;

    final path = Path()
      ..moveTo(center, 0)
      ..lineTo(center, junctionY)
      ..moveTo(center - spread, junctionY)
      ..lineTo(center + spread, junctionY)
      ..moveTo(center - spread, junctionY)
      ..lineTo(center - spread, size.height)
      ..moveTo(center + spread, junctionY)
      ..lineTo(center + spread, size.height);
    canvas.drawPath(path, paint);

    final dot = Paint()..color = AhlColors.gold.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(center, junctionY), 3.2, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PersonList extends StatelessWidget {
  const _PersonList({
    required this.persons,
    required this.selfUid,
    required this.l10n,
    required this.onAddRelative,
  });

  final List<TreePerson> persons;
  final String? selfUid;
  final AppLocalizations l10n;
  final ValueChanged<TreePerson> onAddRelative;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: persons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final person = persons[index];
        final bool isSelf =
            person.linkedUid == selfUid ||
            (person.id == selfUid && selfUid != null);
        final bool inCircle = person.linkedUid != null;
        final String relation = isSelf
            ? l10n.relationSelf
            : treeRelationLabel(l10n, person.relation);

        return AhlCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PersonProfileScreen(person: person),
              ),
            );
          },
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelf
                          ? AhlColors.goldPurpleBorder
                          : LinearGradient(
                              colors: [
                                AhlColors.primary.withValues(alpha: 0.18),
                                AhlColors.gold.withValues(alpha: 0.18),
                              ],
                            ),
                    ),
                    child: AvatarCircle(
                      name: person.name,
                      photoUrl: person.photoUrl,
                      size: 46,
                    ),
                  ),
                  if (inCircle)
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AhlColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelf
                                ? AhlColors.gold.withValues(alpha: 0.16)
                                : AhlColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            relation,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isSelf
                                      ? const Color(0xFF8A6A1F)
                                      : AhlColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (person.birthDate != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${person.birthDate!.year}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AhlColors.inkLight),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _MiniAddButton(l10n: l10n, onTap: () => onAddRelative(person)),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                color: AhlColors.inkLight,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreeHint extends StatelessWidget {
  const _TreeHint({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AhlColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon3D('notebook', size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.treeHint,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AhlColors.inkMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AhlColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 32,
                color: AhlColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.treeSearchEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeEmpty extends StatelessWidget {
  const _TreeEmpty({required this.l10n, required this.onAdd});

  final AppLocalizations l10n;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AhlColors.gold.withValues(alpha: 0.22)),
          boxShadow: AhlColors.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AhlColors.primary.withValues(alpha: 0.08),
                    AhlColors.gold.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon3D('notebook', size: 92),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.treeEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              l10n.treeEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AhlColors.inkMedium, height: 1.4),
            ),
            const SizedBox(height: 22),
            AhlButton(
              label: l10n.addFirstRelative,
              expand: false,
              asset: 'link',
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeError extends StatelessWidget {
  const _TreeError({
    required this.message,
    required this.retry,
    required this.onRetry,
  });

  final String message;
  final String retry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 44, color: AhlColors.inkLight),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 14),
          TextButton(onPressed: onRetry, child: Text(retry)),
        ],
      ),
    );
  }
}
