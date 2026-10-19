import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_button.dart';
import '../../data/models/models.dart';

class PersonProfileScreen extends StatelessWidget {
  const PersonProfileScreen({super.key, required this.person});

  final TreePerson person;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(person.name),
          bottom: TabBar(
            labelColor: AhlColors.ink,
            unselectedLabelColor: AhlColors.inkMedium,
            indicatorColor: AhlColors.primary,
            tabs: [
              Tab(text: l10n.about),
              Tab(text: l10n.relatives),
              Tab(text: l10n.photos),
              Tab(text: l10n.stories),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AboutTab(person: person, l10n: l10n),
            Center(
              child: Text(
                l10n.relatives,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
              ),
            ),
            _ComingSoon(l10n: l10n, label: l10n.photos),
            _ComingSoon(l10n: l10n, label: l10n.stories),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.person, required this.l10n});

  final TreePerson person;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AhlColors.primary.withValues(alpha: 0.12),
            child: Text(
              person.name.characters.first.toUpperCase(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AhlColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(person.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AhlColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              person.gender,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AhlColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          if (person.linkedUid != null)
            AhlButton(
              label: l10n.inviteToCircle,
              onPressed: () {
                // TODO(tree): already in circle
              },
            ),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.l10n, required this.label});

  final AppLocalizations l10n;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: AhlColors.inkLight),
          const SizedBox(height: 12),
          Text(
            '$label · ${l10n.comingSoon}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
          ),
        ],
      ),
    );
  }
}
