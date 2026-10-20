import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_button.dart';

void showAddRelativeSheet(BuildContext context) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final nameController = TextEditingController();
  String? selectedRelation;

  final relations = <(String, String)>[
    ('father', l10n.relationFather),
    ('mother', l10n.relationMother),
    ('son', l10n.relationSon),
    ('daughter', l10n.relationDaughter),
    ('brother', l10n.relationBrother),
    ('sister', l10n.relationSister),
    ('husband', l10n.relationHusband),
    ('wife', l10n.relationWife),
    ('grandfather', l10n.relationGrandfather),
    ('grandmother', l10n.relationGrandmother),
    ('paternal_uncle', l10n.relationPaternalUncle),
    ('maternal_uncle', l10n.relationMaternalUncle),
    ('paternal_aunt', l10n.relationPaternalAunt),
    ('maternal_aunt', l10n.relationMaternalAunt),
    ('other', l10n.relationOther),
  ];

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AhlColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AhlColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.addRelative, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      l10n.selectRelation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AhlColors.inkMedium),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: relations.map((r) {
                        final selected = selectedRelation == r.$1;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedRelation = r.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AhlColors.ink : AhlColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: selected ? null : AhlColors.softShadowSmall,
                            ),
                            child: Text(
                              r.$2,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: selected ? Colors.white : AhlColors.ink,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(hintText: l10n.nameHint),
                    ),
                    const SizedBox(height: 20),
                    AhlButton(
                      label: l10n.addRelative,
                      onPressed: () {
                        if (nameController.text.trim().isEmpty || selectedRelation == null) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${nameController.text.trim()} · $selectedRelation')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
