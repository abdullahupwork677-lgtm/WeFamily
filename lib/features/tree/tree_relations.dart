import 'package:wefamily/l10n/generated/app_localizations.dart';

class TreeRelationOption {
  const TreeRelationOption(this.key, this.label);

  final String key;
  final String label;
}

List<TreeRelationOption> treeRelationOptions(AppLocalizations l10n) => [
  TreeRelationOption('father', l10n.relationFather),
  TreeRelationOption('mother', l10n.relationMother),
  TreeRelationOption('son', l10n.relationSon),
  TreeRelationOption('daughter', l10n.relationDaughter),
  TreeRelationOption('brother', l10n.relationBrother),
  TreeRelationOption('sister', l10n.relationSister),
  TreeRelationOption('husband', l10n.relationHusband),
  TreeRelationOption('wife', l10n.relationWife),
  TreeRelationOption('grandfather', l10n.relationGrandfather),
  TreeRelationOption('grandmother', l10n.relationGrandmother),
  TreeRelationOption('paternal_uncle', l10n.relationPaternalUncle),
  TreeRelationOption('maternal_uncle', l10n.relationMaternalUncle),
  TreeRelationOption('paternal_aunt', l10n.relationPaternalAunt),
  TreeRelationOption('maternal_aunt', l10n.relationMaternalAunt),
  TreeRelationOption('other', l10n.relationOther),
];

String treeRelationLabel(AppLocalizations l10n, String relation) {
  switch (relation) {
    case 'self':
      return l10n.relationSelf;
    case 'father':
      return l10n.relationFather;
    case 'mother':
      return l10n.relationMother;
    case 'son':
      return l10n.relationSon;
    case 'daughter':
      return l10n.relationDaughter;
    case 'brother':
      return l10n.relationBrother;
    case 'sister':
      return l10n.relationSister;
    case 'husband':
      return l10n.relationHusband;
    case 'wife':
      return l10n.relationWife;
    case 'grandfather':
      return l10n.relationGrandfather;
    case 'grandmother':
      return l10n.relationGrandmother;
    case 'paternal_uncle':
      return l10n.relationPaternalUncle;
    case 'maternal_uncle':
      return l10n.relationMaternalUncle;
    case 'paternal_aunt':
      return l10n.relationPaternalAunt;
    case 'maternal_aunt':
      return l10n.relationMaternalAunt;
    default:
      return l10n.relationRelative;
  }
}

String inverseTreeRelation(String relation, String anchorGender) {
  final bool male = anchorGender == 'male';
  final bool female = anchorGender == 'female';
  switch (relation) {
    case 'father':
    case 'mother':
      return male ? 'son' : (female ? 'daughter' : 'child');
    case 'son':
    case 'daughter':
      return male ? 'father' : (female ? 'mother' : 'parent');
    case 'brother':
    case 'sister':
      return male ? 'brother' : (female ? 'sister' : 'relative');
    case 'husband':
      return 'wife';
    case 'wife':
      return 'husband';
    case 'grandfather':
    case 'grandmother':
      return male ? 'grandson' : (female ? 'granddaughter' : 'relative');
    case 'paternal_uncle':
    case 'maternal_uncle':
    case 'paternal_aunt':
    case 'maternal_aunt':
      return male ? 'nephew' : (female ? 'niece' : 'relative');
    case 'self':
      return 'self';
    default:
      return 'relative';
  }
}

String inverseTreeRelationLabel(
  AppLocalizations l10n,
  String relation,
  String anchorGender,
) {
  final inverse = inverseTreeRelation(relation, anchorGender);
  switch (inverse) {
    case 'parent':
      return l10n.relationRelative;
    case 'child':
      return l10n.relationChild;
    case 'nephew':
      return l10n.relationNephew;
    case 'niece':
      return l10n.relationNiece;
    case 'grandson':
      return l10n.relationGrandson;
    case 'granddaughter':
      return l10n.relationGranddaughter;
    default:
      return treeRelationLabel(l10n, inverse);
  }
}
