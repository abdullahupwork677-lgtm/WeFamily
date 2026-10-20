import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/avatar_circle.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    final name = ref.read(sessionProvider).user?.name;
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final name = _nameController.text.trim();
    if (name.isEmpty && !AppConfig.useMockData) return;
    await ref.read(sessionProvider.notifier).updateProfile(
          name: name.isEmpty ? 'Demo User' : name,
          gender: _gender,
          birthDate: _birthDate,
        );
    if (mounted) context.push('/circle');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSetupTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    AvatarCircle(name: _nameController.text.isEmpty ? '?' : _nameController.text, size: 96),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // TODO(asset): photo picker
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: Text(l10n.photos),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(hintText: l10n.nameHint),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickBirthDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: l10n.birthDateHint,
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  child: Text(
                    _birthDate == null
                        ? l10n.birthDateHint
                        : _birthDate!.toLocal().toString().split(' ').first,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _birthDate == null ? AhlColors.inkLight : AhlColors.ink,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _GenderChip(
                      label: l10n.genderMale,
                      selected: _gender == 'male',
                      onTap: () => setState(() => _gender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderChip(
                      label: l10n.genderFemale,
                      selected: _gender == 'female',
                      onTap: () => setState(() => _gender = 'female'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AhlButton(label: l10n.saveContinue, onPressed: () => _save(l10n)),
              if (AppConfig.useMockData)
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      await ref.read(sessionProvider.notifier).updateProfile(
                            name: name.isEmpty ? 'Demo User' : name,
                            gender: _gender,
                            birthDate: _birthDate,
                          );
                      if (!context.mounted) return;
                      context.push('/circle');
                    },
                    child: Text(
                      l10n.skipDemo,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AhlColors.inkMedium,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _birthDate = date);
    }
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AhlColors.ink : AhlColors.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? null : AhlColors.softShadowSmall,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? Colors.white : AhlColors.ink,
              ),
        ),
      ),
    );
  }
}
