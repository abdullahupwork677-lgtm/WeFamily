import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';
import '../../data/repositories/circle_repository.dart';

class CircleScreen extends ConsumerStatefulWidget {
  const CircleScreen({super.key});

  @override
  ConsumerState<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends ConsumerState<CircleScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  int _tab = 0;
  bool _loading = false;

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
    setState(() => _loading = true);
    try {
      await ref
          .read(sessionProvider.notifier)
          .createOrJoinCircle(name.isEmpty ? 'My Family' : name);
      if (mounted) context.go('/home');
    } catch (_) {
      _showMessage(l10n.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _joinErrorMessage(AppLocalizations l10n, CircleJoinFailure failure) {
    return switch (failure) {
      CircleJoinFailure.invalidCode => l10n.invalidCode,
      CircleJoinFailure.alreadyMember => l10n.alreadyMember,
      CircleJoinFailure.full => l10n.circleFull,
      CircleJoinFailure.offline => l10n.noInternet,
      CircleJoinFailure.unknown => l10n.joinFailed,
    };
  }

  Future<void> _join(AppLocalizations l10n) async {
    final code = _codeController.text.trim().toUpperCase();
    if (!AppConfig.useMockData) {
      if (code.length != 6) {
        _showMessage(l10n.invalidCode);
        return;
      }
      final session = ref.read(sessionProvider);
      final uid = session.user?.id;
      if (uid == null) {
        _showMessage(l10n.joinFailed);
        return;
      }
      setState(() => _loading = true);
      try {
        final circle = await ref.read(circleRepositoryProvider).joinCircle(
              code: code,
              uid: uid,
              name: session.user?.name ?? 'Member',
            );
        await ref.read(sessionProvider.notifier).adoptCircle(circle);
        if (mounted) context.go('/home');
        return;
      } on CircleJoinException catch (e) {
        _showMessage(_joinErrorMessage(l10n, e.failure));
      } catch (_) {
        _showMessage(l10n.joinFailed);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    if (code.isEmpty) {
      _showMessage(l10n.inviteCodeHint);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).createOrJoinCircle('My Family');
      if (mounted) context.go('/home');
    } catch (_) {
      _showMessage(l10n.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? l10n.createCircleTitle : l10n.joinCircleTitle),
      ),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 24),
              if (_tab == 0) ...[
                TextField(
                  controller: _nameController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(hintText: l10n.circleNameHint),
                ),
                const SizedBox(height: 24),
                AhlButton(
                  label: _loading ? '...' : l10n.createCircle,
                  onPressed: _loading ? null : () => _create(l10n),
                ),
                if (AppConfig.useMockData) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      l10n.or,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text: '${AppConfig.defaultInviteBase}K7M2P9',
                        ),
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
                _CodeInput(
                  controller: _codeController,
                  enabled: !_loading,
                ),
                const SizedBox(height: 24),
                AhlButton(
                  label: _loading ? '...' : l10n.joinCircle,
                  onPressed: _loading ? null : () => _join(l10n),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeInput extends StatefulWidget {
  const _CodeInput({required this.controller, this.enabled = true});

  final TextEditingController controller;
  final bool enabled;

  @override
  State<_CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<_CodeInput> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String text = widget.controller.text.toUpperCase();
    final int activeIndex = text.length.clamp(0, 5);

    return Stack(
      children: [
        Row(
          children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AhlColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AhlColors.softShadowSmall,
                    border: Border.all(
                      color: _focus.hasFocus && i == activeIndex
                          ? AhlColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    i < text.length ? text[i] : '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AhlColors.ink,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(6),
                _UpperCaseFormatter(),
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length.clamp(0, text.length),
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
