import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/services/media_service.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/icon_3d.dart';
import '../../data/models/models.dart';
import 'tree_relations.dart';

class TreePersonDraft {
  const TreePersonDraft({
    required this.name,
    required this.relation,
    required this.gender,
    this.birthDate,
    this.photoUrl,
    this.about,
    this.linkedUid,
  });

  final String name;
  final String relation;
  final String gender;
  final DateTime? birthDate;
  final String? photoUrl;
  final String? about;
  final String? linkedUid;
}

Future<TreePersonDraft?> showAddRelativeSheet(
  BuildContext context, {
  required TreePerson anchor,
  required List<CircleMember> circleMembers,
  required List<TreePerson> persons,
  required String? selfUid,
  String? initialRelation,
}) {
  return showModalBottomSheet<TreePersonDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AhlColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => _TreeRelativeSheet(
      anchor: anchor,
      circleMembers: circleMembers,
      persons: persons,
      selfUid: selfUid,
      initialRelation: initialRelation,
    ),
  );
}

Future<TreePersonDraft?> showEditTreePersonSheet(
  BuildContext context, {
  required TreePerson person,
  required List<CircleMember> circleMembers,
  required List<TreePerson> persons,
  required String? selfUid,
}) {
  return showModalBottomSheet<TreePersonDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AhlColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => _TreeRelativeSheet(
      person: person,
      circleMembers: circleMembers,
      persons: persons,
      selfUid: selfUid,
    ),
  );
}

class _TreeRelativeSheet extends StatefulWidget {
  const _TreeRelativeSheet({
    this.anchor,
    this.person,
    required this.circleMembers,
    required this.persons,
    required this.selfUid,
    this.initialRelation,
  });

  final TreePerson? anchor;
  final TreePerson? person;
  final List<CircleMember> circleMembers;
  final List<TreePerson> persons;
  final String? selfUid;
  final String? initialRelation;

  TreePerson? get editing => person;

  @override
  State<_TreeRelativeSheet> createState() => _TreeRelativeSheetState();
}

class _TreeRelativeSheetState extends State<_TreeRelativeSheet> {
  late final TextEditingController _name;
  late final TextEditingController _about;
  String? _relation;
  String _gender = 'other';
  DateTime? _birthDate;
  String? _photoUrl;
  String? _linkedUid;
  String? _error;
  bool _uploading = false;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final person = widget.editing;
    _name = TextEditingController(text: person?.name ?? '');
    _about = TextEditingController(text: person?.about ?? '');
    _relation = person?.relation ?? widget.initialRelation;
    _gender =
        person?.gender ?? _genderForRelation(widget.initialRelation) ?? 'other';
    _birthDate = person?.birthDate;
    _photoUrl = person?.photoUrl;
    _linkedUid = person?.linkedUid;
  }

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_uploading) return;
    final l10n = AppLocalizations.of(context);
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final url = await const MediaService().uploadProfilePhoto(
        File(picked.path),
      );
      if (!mounted) return;
      setState(() => _photoUrl = url);
    } catch (error) {
      if (!mounted) return;
      final message = error is MediaUploadException
          ? error.message
          : l10n.error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: AppLocalizations.of(context).selectDate,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.nameRequired);
      return;
    }
    final relation = _isEdit ? widget.editing!.relation : _relation;
    if (relation == null || relation.isEmpty) {
      setState(() => _error = l10n.relationRequired);
      return;
    }
    final about = _about.text.trim();
    Navigator.of(context).pop(
      TreePersonDraft(
        name: name,
        relation: relation,
        gender: _gender,
        birthDate: _birthDate,
        photoUrl: _photoUrl,
        about: about.isEmpty ? null : about,
        linkedUid: _linkedUid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = widget.editing;
    final anchor = person ?? widget.anchor;
    final linkedIds = <String>{
      for (final item in widget.persons)
        if (item.linkedUid != null &&
            item.id != person?.id &&
            item.linkedUid != widget.selfUid)
          item.linkedUid!,
    };
    final memberOptions = widget.circleMembers
        .where(
          (member) =>
              member.uid != widget.selfUid && !linkedIds.contains(member.uid),
        )
        .toList();
    final currentLinked = _linkedUid;
    if (currentLinked != null &&
        currentLinked != widget.selfUid &&
        !memberOptions.any((member) => member.uid == currentLinked)) {
      final match = widget.circleMembers
          .where((member) => member.uid == currentLinked)
          .toList();
      if (match.isNotEmpty) memberOptions.add(match.first);
    }

    final dropdownValue =
        (_linkedUid != null &&
            memberOptions.any((member) => member.uid == _linkedUid))
        ? _linkedUid
        : null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AhlColors.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                person != null ? l10n.editPerson : l10n.addRelative,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                person != null
                    ? treeRelationLabel(l10n, person.relation)
                    : l10n.addRelativeOf(anchor?.name ?? ''),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.selectRelation,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: treeRelationOptions(l10n).map((option) {
                    final selected = _relation == option.key;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _relation = option.key;
                        _gender = _genderForRelation(option.key) ?? _gender;
                        _error = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AhlColors.primary
                              : AhlColors.background,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: selected
                                ? AhlColors.primary
                                : AhlColors.border,
                          ),
                        ),
                        child: Text(
                          option.label,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: selected ? Colors.white : AhlColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 18),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.nameHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 14),
              Text(l10n.gender, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _GenderChip(
                    label: l10n.genderMale,
                    selected: _gender == 'male',
                    onTap: () => setState(() => _gender = 'male'),
                  ),
                  _GenderChip(
                    label: l10n.genderFemale,
                    selected: _gender == 'female',
                    onTap: () => setState(() => _gender = 'female'),
                  ),
                  _GenderChip(
                    label: l10n.genderOther,
                    selected: _gender == 'other',
                    onTap: () => setState(() => _gender = 'other'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AhlColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AhlColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        size: 20,
                        color: AhlColors.inkMedium,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _birthDate == null
                              ? l10n.birthday
                              : MaterialLocalizations.of(context)
                                    .formatMediumDate(_birthDate!),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: _birthDate == null
                                    ? AhlColors.inkMedium
                                    : AhlColors.ink,
                              ),
                        ),
                      ),
                      if (_birthDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _birthDate = null),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AhlColors.inkLight,
                          ),
                        )
                      else
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AhlColors.inkLight,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _name,
                    builder: (context, value, _) => AvatarCircle(
                      name: value.text.trim().isEmpty ? '?' : value.text.trim(),
                      photoUrl: _photoUrl,
                      size: 58,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _uploading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          )
                        : Wrap(
                            spacing: 4,
                            children: [
                              TextButton.icon(
                                onPressed: _pickPhoto,
                                icon: const Icon3D('camera', size: 24),
                                label: Text(
                                  _photoUrl == null
                                      ? l10n.addPhoto
                                      : l10n.changePhoto,
                                ),
                              ),
                              if (_photoUrl != null)
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _photoUrl = null),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 19,
                                  ),
                                  label: Text(l10n.removePhoto),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AhlColors.danger,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _about,
                maxLines: 3,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: l10n.about,
                  hintText: l10n.aboutHint,
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              if (memberOptions.isNotEmpty) ...[
                const SizedBox(height: 14),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.linkMember,
                    prefixIcon: const Icon(Icons.link_rounded),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: dropdownValue,
                      hint: Text(l10n.linkMemberHint),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.optional),
                        ),
                        for (final member in memberOptions)
                          DropdownMenuItem<String?>(
                            value: member.uid,
                            child: Text(
                              member.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) => setState(() => _linkedUid = value),
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AhlColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AhlButton(
                label: l10n.save,
                icon: Icons.check_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _genderForRelation(String? relation) {
  switch (relation) {
    case 'father':
    case 'son':
    case 'brother':
    case 'husband':
    case 'grandfather':
    case 'paternal_uncle':
    case 'maternal_uncle':
      return 'male';
    case 'mother':
    case 'daughter':
    case 'sister':
    case 'wife':
    case 'grandmother':
    case 'paternal_aunt':
    case 'maternal_aunt':
      return 'female';
    default:
      return null;
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AhlColors.primary.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AhlColors.primary : AhlColors.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AhlColors.primary : AhlColors.inkMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
