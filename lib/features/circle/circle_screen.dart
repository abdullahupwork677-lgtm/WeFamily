import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';

class CircleScreen extends ConsumerStatefulWidget {
  const CircleScreen({super.key});

  @override
  ConsumerState<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends ConsumerState<CircleScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _create(AppLocalizations l10n) async {
    final name = _nameController.text.trim();
    if (name.isEmpty && !AppConfig.useMockData) {
      _showMessage(l10n.enterCircleName);
      return;
    }
    try {
      await ref
          .read(sessionProvider.notifier)
          .createOrJoinCircle(name.isEmpty ? 'My Family' : name);
      if (mounted) context.go('/home');
    } catch (_) {
      _showMessage(l10n.error);
    }
  }

  Future<void> _join(AppLocalizations l10n) async {
    final code = _codeController.text.trim();
    if (!AppConfig.useMockData) {
      _showMessage(l10n.comingSoon);
      return;
    }
    if (code.isEmpty) {
      _showMessage(l10n.inviteCodeHint);
      return;
    }
    try {
      await ref.read(sessionProvider.notifier).createOrJoinCircle('My Family');
      if (mounted) context.go('/home');
    } catch (_) {
      _showMessage(l10n.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? l10n.createCircleTitle : l10n.joinCircleTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TabPill(
                      label: l10n.createCircle,
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TabPill(
                      label: l10n.joinCircle,
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _tab == 0 ? l10n.createCircleSubtitle : l10n.joinCircleSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 24),
              if (_tab == 0) ...[
                TextField(
                  controller: _nameController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(hintText: l10n.circleNameHint),
                ),
                const SizedBox(height: 24),
                AhlButton(label: l10n.createCircle, onPressed: () => _create(l10n)),
                const SizedBox(height: 24),
                if (AppConfig.useMockData) ...[
                  Center(child: Text(l10n.or, style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(text: '${AppConfig.defaultInviteBase}K7M2P9'),
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.shareInvite),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ] else ...[
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 4),
                  decoration: InputDecoration(hintText: l10n.inviteCodeHint),
                ),
                const SizedBox(height: 24),
                AhlButton(label: l10n.joinCircle, onPressed: () => _join(l10n)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
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
        padding: const EdgeInsets.symmetric(vertical: 14),
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
