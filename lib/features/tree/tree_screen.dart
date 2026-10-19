import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import 'add_relative_sheet.dart';
import 'person_profile_screen.dart';

final treePersonsProvider = Provider<List<TreePerson>>((ref) => MockData.persons);
final treeRelationsProvider = Provider<List<TreeRelation>>((ref) => MockData.relations);

class TreeScreen extends ConsumerStatefulWidget {
  const TreeScreen({super.key});

  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  bool _listView = false;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<TreePerson> persons = ref.watch(treePersonsProvider);

    final filtered = _search.isEmpty
        ? persons
        : persons.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tree),
        actions: [
          IconButton(
            tooltip: _listView ? l10n.treeView : l10n.listView,
            icon: Icon(_listView ? Icons.account_tree : Icons.list),
            onPressed: () => setState(() => _listView = !_listView),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddRelativeSheet(context),
        backgroundColor: AhlColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.addRelative),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.searchTree,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _listView
                ? _PersonList(persons: filtered)
                : _TreeView(persons: filtered, relations: ref.watch(treeRelationsProvider)),
          ),
        ],
      ),
    );
  }
}

class _TreeView extends StatelessWidget {
  const _TreeView({required this.persons, required this.relations});

  final List<TreePerson> persons;
  final List<TreeRelation> relations;

  @override
  Widget build(BuildContext context) {
    final generations = <int, List<TreePerson>>{};
    for (final p in persons) {
      generations.putIfAbsent(p.generation, () => []).add(p);
    }
    final keys = generations.keys.toList()..sort();

    return InteractiveViewer(
      maxScale: 3,
      minScale: 0.5,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            for (int i = 0; i < keys.length; i++) ...[
              _GenerationRow(persons: generations[keys[i]]!),
              if (i < keys.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CustomPaint(
                    size: const Size(200, 32),
                    painter: _GoldConnectorPainter(),
                  ),
                ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _GenerationRow extends StatelessWidget {
  const _GenerationRow({required this.persons});

  final List<TreePerson> persons;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: persons.map((p) => _TreePersonNode(person: p)).toList(),
    );
  }
}

class _TreePersonNode extends StatelessWidget {
  const _TreePersonNode({required this.person});

  final TreePerson person;

  @override
  Widget build(BuildContext context) {
    final bool inCircle = person.linkedUid != null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => PersonProfileScreen(person: person)),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarCircle(name: person.name, size: 64),
              if (inCircle)
                Positioned(
                  bottom: 2,
                  right: 2,
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
          const SizedBox(height: 6),
          Text(
            person.name.split(' ').first,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GoldConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AhlColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(size.width / 2, size.height * 0.4, size.width / 2, size.height * 0.6, size.width / 2, size.height);

    canvas.drawPath(path, paint);

    // side branches for spouses
    final branch = Path()
      ..moveTo(size.width * 0.25, size.height)
      ..quadraticBezierTo(size.width / 2, size.height * 0.5, size.width * 0.75, size.height);
    canvas.drawPath(branch, paint..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PersonList extends StatelessWidget {
  const _PersonList({required this.persons});

  final List<TreePerson> persons;

  @override
  Widget build(BuildContext context) {
    if (persons.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).empty,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: persons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = persons[index];
        return AhlCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => PersonProfileScreen(person: p)),
            );
          },
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarCircle(name: p.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text(p.name, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (p.linkedUid != null)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: AhlColors.success, shape: BoxShape.circle),
                ),
            ],
          ),
        );
      },
    );
  }
}
