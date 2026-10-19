import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_button.dart';
import '../../core/widgets/language_switcher.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(AppLocalizations l10n) {
    if (_index < 2) {
      _controller.nextPage(duration: 350.ms, curve: Curves.easeOutCubic);
    } else {
      // TODO(auth): navigate to login
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isLast = _index == 2;

    final pages = [
      (Icons.favorite_rounded, l10n.onboardingTitle1, l10n.onboardingBody1),
      (Icons.account_tree_rounded, l10n.onboardingTitle2, l10n.onboardingBody2),
      (Icons.shield_rounded, l10n.onboardingTitle3, l10n.onboardingBody3),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80),
                  const LanguageSwitcher(compact: true),
                  TextButton(
                    onPressed: () => _next(l10n),
                    child: Text(l10n.skip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final (icon, title, body) = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: AhlColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 64, color: Colors.white),
                        ).animate().scale(
                              begin: const Offset(0.85, 0.85),
                              end: const Offset(1, 1),
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 40),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AhlColors.inkMedium,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final bool active = i == _index;
                      return AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AhlColors.primary : AhlColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  AhlButton(
                    label: isLast ? l10n.getStarted : l10n.next,
                    onPressed: () => _next(l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

