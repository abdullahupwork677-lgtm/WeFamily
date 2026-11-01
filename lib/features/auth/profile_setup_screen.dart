import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/config.dart';
import '../../core/services/media_service.dart';
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
  String? _photoUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).user;
    final name = user?.name;
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
    _photoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final name = _nameController.text.trim();
    if (name.isEmpty && !AppConfig.useMockData) return;
    await ref
        .read(sessionProvider.notifier)
        .updateProfile(
          name: name.isEmpty ? 'Demo User' : name,
          gender: _gender,
          birthDate: _birthDate,
          photoUrl: _photoUrl,
        );
    if (mounted) context.go('/circle');
  }

  Future<void> _pickPhoto(AppLocalizations l10n) async {
    if (_uploading) return;
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AvatarCircle(
                          name: _nameController.text.isEmpty
                              ? '?'
                              : _nameController.text,
                          photoUrl: _photoUrl,
                          size: 96,
                        ),
                        if (_uploading)
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _uploading ? null : () => _pickPhoto(l10n),
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
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                    ),
                  ),
                  child: Text(
                    _birthDate == null
                        ? l10n.birthDateHint
                        : _birthDate!.toLocal().toString().split(' ').first,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _birthDate == null
                          ? AhlColors.inkLight
                          : AhlColors.ink,
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
                      await ref
                          .read(sessionProvider.notifier)
                          .updateProfile(
                            name: name.isEmpty ? 'Demo User' : name,
                            gender: _gender,
                            birthDate: _birthDate,
                          );
                      if (!context.mounted) return;
                      context.go('/circle');
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
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: selected ? Colors.white : AhlColors.ink),
        ),
      ),
    );
  }
}
