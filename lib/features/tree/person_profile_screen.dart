import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/icon_3d.dart';
import '../../data/models/models.dart';
import '../../data/repositories/tree_repository.dart';
import 'add_relative_sheet.dart';
import 'tree_providers.dart';
import 'tree_relations.dart';

class PersonProfileScreen extends ConsumerWidget {
  const PersonProfileScreen({super.key, required this.person});

  final TreePerson person;

  TreePerson _current(WidgetRef ref) {
    final persons = ref.watch(treePersonsValueProvider);
    for (final item in persons) {
      if (item.id == person.id) return item;
    }
    return person;
  }

  bool _isSelf(TreePerson current, String? uid) =>
      (uid != null && current.id == uid) ||
      (uid != null && current.linkedUid == uid);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TreePerson current = _current(ref);
    final List<TreePerson> persons = ref.watch(treePersonsValueProvider);
    final String? uid = ref.watch(currentUidProvider);
    final FamilyCircle? circle = ref.watch(myCircleProvider).value;
    final bool isSelf = _isSelf(current, uid);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(current.name),
          actions: [
            IconButton(
              tooltip: l10n.editPerson,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, ref, current, l10n),
            ),
            if (!isSelf)
              IconButton(
                tooltip: l10n.deletePerson,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _delete(context, ref, current, l10n),
              ),
          ],
          bottom: TabBar(
            labelColor: AhlColors.ink,
            unselectedLabelColor: AhlColors.inkMedium,
            indicatorColor: AhlColors.primary,
            tabs: [
              Tab(text: l10n.about),
              Tab(text: l10n.relatives),
              Tab(text: l10n.photos),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AboutTab(
              person: current,
              isSelf: isSelf,
              circle: circle,
              l10n: l10n,
              onAddRelative: () => _addRelative(context, ref, current, l10n),
              onInvite: circle == null
                  ? null
                  : () => _copyInvite(context, circle, l10n),
            ),
            _RelativesTab(
              person: current,
              persons: persons,
              l10n: l10n,
              isSelf: isSelf,
              onAddRelative: () => _addRelative(context, ref, current, l10n),
            ),
            _PhotosTab(
              person: current,
              l10n: l10n,
              onEdit: () => _edit(context, ref, current, l10n),
              onRemove: () => _removePhoto(context, ref, current, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRelative(
    BuildContext context,
    WidgetRef ref,
    TreePerson anchor,
    AppLocalizations l10n,
  ) async {
    final String? uid = ref.read(currentUidProvider);
    final FamilyCircle? circle = ref.read(myCircleProvider).value;
    if (uid == null || circle == null) return;
    final persons = ref.read(treePersonsProvider).value ?? const <TreePerson>[];
    final draft = await showAddRelativeSheet(
      context,
      anchor: anchor,
      circleMembers: ref.read(liveMembersProvider),
      persons: persons,
      selfUid: uid,
    );
    if (draft == null || !context.mounted) return;
    if (draft.relation == 'father' || draft.relation == 'mother') {
      if (anchor.parentIds.length >= 2) {
        _snack(context, l10n.alreadyTwoParents);
        return;
      }
    }
    if (draft.relation == 'husband' || draft.relation == 'wife') {
      if (anchor.spouseId != null) {
        _snack(context, l10n.partnerAlready);
        return;
      }
    }
    if (draft.relation == 'brother' || draft.relation == 'sister') {
      if (anchor.parentIds.isEmpty) {
        _snack(context, l10n.treeSiblingNeedsParent);
        return;
      }
    }
    if (AppConfig.useMockData) {
      _snack(context, l10n.personAdded(draft.name));
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
      if (context.mounted) _snack(context, l10n.personAdded(draft.name));
    } on TreeException catch (error) {
      if (!context.mounted) return;
      _snack(
        context,
        error.code == 'member-already-linked'
            ? l10n.memberAlreadyLinked
            : l10n.treeSaveError,
      );
    } catch (_) {
      if (context.mounted) _snack(context, l10n.treeSaveError);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    TreePerson current,
    AppLocalizations l10n,
  ) async {
    final String? uid = ref.read(currentUidProvider);
    final FamilyCircle? circle = ref.read(myCircleProvider).value;
    if (circle == null) return;
    final persons = ref.read(treePersonsProvider).value ?? const <TreePerson>[];
    final draft = await showEditTreePersonSheet(
      context,
      person: current,
      circleMembers: ref.read(liveMembersProvider),
      persons: persons,
      selfUid: uid,
    );
    if (draft == null || !context.mounted) return;
    if (AppConfig.useMockData) {
      _snack(context, l10n.personUpdated);
      return;
    }
    try {
      await ref
          .read(treeRepositoryProvider)
          .updatePerson(
            circleId: circle.id,
            person: current,
            name: draft.name,
            gender: draft.gender,
            birthDate: draft.birthDate,
            clearBirthDate:
                draft.birthDate == null && current.birthDate != null,
            photoUrl: draft.photoUrl,
            clearPhoto: draft.photoUrl == null && current.photoUrl != null,
            about: draft.about,
            clearAbout: draft.about == null && current.about != null,
            linkedUid: draft.linkedUid,
            clearLinkedUid:
                draft.linkedUid == null && current.linkedUid != null,
          );
      if (context.mounted) _snack(context, l10n.personUpdated);
    } on TreeException catch (error) {
      if (!context.mounted) return;
      _snack(
        context,
        error.code == 'member-already-linked'
            ? l10n.memberAlreadyLinked
            : l10n.treeSaveError,
      );
    } catch (_) {
      if (context.mounted) _snack(context, l10n.treeSaveError);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    TreePerson current,
    AppLocalizations l10n,
  ) async {
    final FamilyCircle? circle = ref.read(myCircleProvider).value;
    if (circle == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePerson),
        content: Text(
          '${l10n.deletePersonConfirm(current.name)}\n\n${l10n.deletePersonBody}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AhlColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    if (AppConfig.useMockData) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    try {
      await ref
          .read(treeRepositoryProvider)
          .deletePerson(circleId: circle.id, personId: current.id);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _snack(context, l10n.personRemoved);
    } catch (_) {
      if (context.mounted) _snack(context, l10n.treeDeleteError);
    }
  }

  Future<void> _removePhoto(
    BuildContext context,
    WidgetRef ref,
    TreePerson current,
    AppLocalizations l10n,
  ) async {
    final FamilyCircle? circle = ref.read(myCircleProvider).value;
    if (circle == null) return;
    if (AppConfig.useMockData) return;
    try {
      await ref
          .read(treeRepositoryProvider)
          .updatePerson(
            circleId: circle.id,
            person: current,
            name: current.name,
            gender: current.gender,
            clearPhoto: true,
          );
      if (context.mounted) _snack(context, l10n.personUpdated);
    } catch (_) {
      if (context.mounted) _snack(context, l10n.treeSaveError);
    }
  }

  void _copyInvite(
    BuildContext context,
    FamilyCircle circle,
    AppLocalizations l10n,
  ) {
    Clipboard.setData(ClipboardData(text: circle.inviteCode));
    _snack(context, '${l10n.inviteCodeCopied}: ${circle.inviteCode}');
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.person,
    required this.isSelf,
    required this.circle,
    required this.l10n,
    required this.onAddRelative,
    required this.onInvite,
  });

  final TreePerson person;
  final bool isSelf;
  final FamilyCircle? circle;
  final AppLocalizations l10n;
  final VoidCallback onAddRelative;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    final int? age = person.birthDate == null
        ? null
        : (DateTime.now().difference(person.birthDate!).inDays / 365.25)
              .floor();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarCircle(
                name: person.name,
                photoUrl: person.photoUrl,
                size: 104,
              ),
              if (person.linkedUid != null)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AhlColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            person.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _InfoChip(
                icon: isSelf ? Icons.person_rounded : Icons.link_rounded,
                label: isSelf
                    ? l10n.relationSelf
                    : treeRelationLabel(l10n, person.relation),
                color: AhlColors.primary,
              ),
              _InfoChip(
                icon: person.gender == 'female'
                    ? Icons.female_rounded
                    : person.gender == 'male'
                    ? Icons.male_rounded
                    : Icons.person_outline_rounded,
                label: person.gender == 'female'
                    ? l10n.genderFemale
                    : person.gender == 'male'
                    ? l10n.genderMale
                    : l10n.genderOther,
                color: AhlColors.gold,
              ),
              _InfoChip(
                icon: person.linkedUid != null
                    ? Icons.verified_user_rounded
                    : Icons.person_off_outlined,
                label: person.linkedUid != null
                    ? l10n.linkedMember
                    : l10n.notLinked,
                color: person.linkedUid != null
                    ? AhlColors.success
                    : AhlColors.inkMedium,
              ),
            ],
          ),
          const SizedBox(height: 22),
          AhlCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.cake_outlined,
                  asset: 'calendar',
                  label: l10n.birthday,
                  value: person.birthDate == null
                      ? l10n.optional
                      : MaterialLocalizations.of(context)
                            .formatMediumDate(person.birthDate!),
                ),
                if (age != null) ...[
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.hourglass_bottom_rounded,
                    asset: 'clock',
                    label: l10n.ageYears(age.toString()),
                    value: '',
                  ),
                ],
              ],
            ),
          ),
          if (person.about != null && person.about!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            AhlCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon3D('notebook', size: 26),
                      const SizedBox(width: 8),
                      Text(
                        l10n.about,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    person.about!,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.5, color: AhlColors.inkMedium),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          AhlButton(
            label: l10n.addRelativeOf(person.name.split(' ').first),
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onAddRelative,
          ),
          if (person.linkedUid == null && onInvite != null) ...[
            const SizedBox(height: 10),
            AhlButton(
              label: l10n.inviteToCircle,
              asset: 'gift',
              gradient: false,
              onPressed: onInvite,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    this.asset,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String? asset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (asset != null)
          Icon3D(asset!, size: 24)
        else
          Icon(icon, size: 19, color: AhlColors.inkMedium),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AhlColors.inkMedium),
          ),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

class _RelativeEntry {
  const _RelativeEntry(this.person, this.label);

  final TreePerson person;
  final String label;
}

class _RelativesTab extends StatelessWidget {
  const _RelativesTab({
    required this.person,
    required this.persons,
    required this.l10n,
    required this.isSelf,
    required this.onAddRelative,
  });

  final TreePerson person;
  final List<TreePerson> persons;
  final AppLocalizations l10n;
  final bool isSelf;
  final VoidCallback onAddRelative;

  TreePerson? _find(String id) {
    for (final item in persons) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<_RelativeEntry> _list(
    Iterable<String> ids,
    String Function(TreePerson relative) label, {
    Set<String> exclude = const <String>{},
  }) {
    final result = <_RelativeEntry>[];
    final seen = <String>{...exclude};
    for (final id in ids) {
      if (id == person.id || !seen.add(id)) continue;
      final relative = _find(id);
      if (relative != null) {
        result.add(_RelativeEntry(relative, label(relative)));
      }
    }
    return result;
  }

  String _gendered(
    TreePerson relative, {
    required String male,
    required String female,
    required String fallback,
  }) {
    if (relative.gender == 'male') return male;
    if (relative.gender == 'female') return female;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final parents = _list(
      person.parentIds,
      (relative) => _gendered(
        relative,
        male: l10n.relationFather,
        female: l10n.relationMother,
        fallback: l10n.relationParent,
      ),
    );
    final spouse = person.spouseId == null
        ? const <_RelativeEntry>[]
        : _list(
            [person.spouseId!],
            (relative) => _gendered(
              relative,
              male: l10n.relationHusband,
              female: l10n.relationWife,
              fallback: l10n.spouse,
            ),
          );
    final children = _list(
      persons
          .where((item) => item.parentIds.contains(person.id))
          .map((item) => item.id),
      (relative) => _gendered(
        relative,
        male: l10n.relationSon,
        female: l10n.relationDaughter,
        fallback: l10n.relationChild,
      ),
    );
    final siblings = person.parentIds.isEmpty
        ? const <_RelativeEntry>[]
        : _list(
            persons
                .where(
                  (item) =>
                      item.id != person.id &&
                      item.parentIds.any(person.parentIds.contains),
                )
                .map((item) => item.id),
            (relative) => _gendered(
              relative,
              male: l10n.relationBrother,
              female: l10n.relationSister,
              fallback: l10n.relationSibling,
            ),
          );

    final used = <String>{
      ...parents.map((entry) => entry.person.id),
      ...spouse.map((entry) => entry.person.id),
      ...children.map((entry) => entry.person.id),
      ...siblings.map((entry) => entry.person.id),
    };

    final other = <_RelativeEntry>[];
    final otherSeen = <String>{};
    for (final item in persons) {
      if (item.id == person.id) continue;
      if (item.relatedToId == person.id && !used.contains(item.id)) {
        if (otherSeen.add(item.id)) {
          other.add(
            _RelativeEntry(item, treeRelationLabel(l10n, item.relation)),
          );
        }
      } else if (person.relatedToId == item.id && !used.contains(item.id)) {
        if (otherSeen.add(item.id)) {
          other.add(
            _RelativeEntry(
              item,
              inverseTreeRelationLabel(l10n, person.relation, item.gender),
            ),
          );
        }
      }
    }

    final sections = <(String, List<_RelativeEntry>)>[
      (l10n.parents, parents),
      (l10n.spouse, spouse),
      (l10n.children, children),
      (l10n.siblings, siblings),
      (l10n.otherRelatives, other),
    ];

    final hasAny = sections.any((section) => section.$2.isNotEmpty);
    if (!hasAny) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.family_restroom_rounded,
                size: 44,
                color: AhlColors.inkLight,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.noRelativesYet,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 18),
              AhlButton(
                label: isSelf
                    ? l10n.addFirstRelative
                    : l10n.addRelativeOf(person.name.split(' ').first),
                expand: false,
                icon: Icons.person_add_alt_1_rounded,
                onPressed: onAddRelative,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        for (final section in sections)
          if (section.$2.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
              child: Text(
                section.$1,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AhlColors.inkMedium,
                ),
              ),
            ),
            AhlCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (int i = 0; i < section.$2.length; i++) ...[
                    _RelativeTile(entry: section.$2[i]),
                    if (i < section.$2.length - 1)
                      const Divider(height: 1, indent: 64),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        const SizedBox(height: 6),
        AhlButton(
          label: isSelf
              ? l10n.addRelative
              : l10n.addRelativeOf(person.name.split(' ').first),
          icon: Icons.person_add_alt_1_rounded,
          gradient: false,
          onPressed: onAddRelative,
        ),
      ],
    );
  }
}

class _RelativeTile extends StatelessWidget {
  const _RelativeTile({required this.entry});

  final _RelativeEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PersonProfileScreen(person: entry.person),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            AvatarCircle(
              name: entry.person.name,
              photoUrl: entry.person.photoUrl,
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.label,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AhlColors.inkMedium),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AhlColors.inkLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({
    required this.person,
    required this.l10n,
    required this.onEdit,
    required this.onRemove,
  });

  final TreePerson person;
  final AppLocalizations l10n;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (person.photoUrl == null || person.photoUrl!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon3D('camera', size: 84),
              const SizedBox(height: 14),
              Text(
                l10n.noPhotos,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 18),
              AhlButton(
                label: l10n.addPhoto,
                expand: false,
                icon: Icons.add_photo_alternate_outlined,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.network(
              person.photoUrl!,
              width: double.infinity,
              height: 340,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 240,
                color: AhlColors.chip,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 42,
                  color: AhlColors.inkLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AhlButton(
                  label: l10n.changePhoto,
                  gradient: false,
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AhlButton(
                  label: l10n.removePhoto,
                  gradient: false,
                  icon: Icons.delete_outline_rounded,
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
