import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verify(AppLocalizations l10n) async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) return;
    await ref.read(sessionProvider.notifier).login(widget.phone);
    if (mounted) context.push('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.otpTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.otpSubtitle(widget.phone),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (value) {
                        if (value.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (value.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        if (_controllers.every((c) => c.text.isNotEmpty)) {
                          _verify(l10n);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              AhlButton(label: l10n.continueBtn, onPressed: () => _verify(l10n)),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _resendSeconds > 0
                      ? null
                      : () {
                          _startResendTimer();
                        },
                  child: Text(
                    _resendSeconds > 0 ? l10n.resendIn(_resendSeconds) : l10n.resendCode,
                  ),
                ),
              ),
              if (AppConfig.useMockData) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await ref.read(sessionProvider.notifier).login(widget.phone);
                      if (!context.mounted) return;
                      context.push('/profile-setup');
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
            ],
          ),
        ),
      ),
    );
  }
}
