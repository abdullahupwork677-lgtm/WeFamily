import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/repositories/mock_data.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  double _progress = 0;
  Timer? _timer;
  bool _activated = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startHold() {
    if (_activated) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() => _progress += 0.05);
      if (_progress >= 1) {
        t.cancel();
        setState(() {
          _activated = true;
          _progress = 1;
        });
      }
    });
  }

  void _cancelHold() {
    if (_activated) return;
    _timer?.cancel();
    setState(() => _progress = 0);
  }

  void _reset() {
    setState(() {
      _activated = false;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.safety)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              if (_activated)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AhlColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AhlColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 48, color: AhlColors.danger),
                      const SizedBox(height: 12),
                      Text(
                        l10n.sos,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AhlColors.danger),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Demo mode — no real alerts sent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AhlColors.inkMedium),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(onPressed: _reset, child: const Text('Reset')),
                    ],
                  ),
                ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms)
              else
                GestureDetector(
                  onPanStart: (_) => _startHold(),
                  onPanEnd: (_) => _cancelHold(),
                  onTapDown: (_) => _startHold(),
                  onTapUp: (_) => _cancelHold(),
                  onTapCancel: _cancelHold,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 6,
                          backgroundColor: AhlColors.danger.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(AhlColors.danger),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos, color: Colors.white, size: 40),
                            const SizedBox(height: 4),
                            Text(
                              l10n.sos,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                _activated ? '' : l10n.sosHold,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AhlColors.inkMedium),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.emergencyContacts, style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 12),
              for (final m in MockData.members.take(3)) ...[
                AhlCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      AvatarCircle(name: m.name, size: 40),
                      const SizedBox(width: 12),
                      Expanded(child: Text(m.name, style: Theme.of(context).textTheme.titleMedium)),
                      IconButton(
                        icon: const Icon(Icons.call, color: AhlColors.success),
                        onPressed: () {
                          // TODO(phone): url_launcher
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
