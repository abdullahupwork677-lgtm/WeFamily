import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/language_switcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isSignup = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_loading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@') || password.length < 6) {
      _showMessage(l10n.authInvalid);
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isSignup) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      }
      await ref.read(sessionProvider.notifier).login(email);
      if (mounted) context.go('/profile-setup');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? l10n.authFailed);
    } catch (_) {
      _showMessage(l10n.authFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _skipDemo() async {
    await ref.read(sessionProvider.notifier).login('demo@wefamily.app');
    if (mounted) context.push('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80),
                  const LanguageSwitcher(compact: true),
                  const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 40),
              Text(l10n.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.emailHint,
                  prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(l10n),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.passwordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AhlButton(
                label: _loading
                    ? '...'
                    : (_isSignup ? l10n.createAccount : l10n.signIn),
                onPressed: _loading ? null : () => _submit(l10n),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isSignup = !_isSignup),
                  child: Text(
                    _isSignup ? l10n.switchToLogin : l10n.switchToSignup,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AhlColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              if (AppConfig.useMockData) ...[
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: _skipDemo,
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
