import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/models/models.dart';

void showMemberDetailSheet(BuildContext context, CircleMember member) {
  final AppLocalizations l10n = AppLocalizations.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AhlColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              AvatarCircle(name: member.name, size: 80),
              const SizedBox(height: 12),
              Text(member.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                member.relation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AhlColors.inkMedium),
              ),
              const SizedBox(height: 20),
              AhlCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: l10n.places,
                      value: member.placeLabel ?? '—',
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.battery_std,
                      label: l10n.battery,
                      value: member.batteryLevel != null ? '${member.batteryLevel}%' : '—',
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.schedule,
                      label: l10n.lastUpdated,
                      value: member.lastUpdated != null
                          ? '${member.lastUpdated!.toLocal().hour}:${member.lastUpdated!.toLocal().minute.toString().padLeft(2, '0')}'
                          : '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.call,
                      label: l10n.call,
                      primary: true,
                      onTap: () {
                        // TODO(phone): url_launcher tel:
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.message,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AhlColors.primary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AhlColors.inkMedium)),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    this.primary = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primary ? AhlColors.primary : AhlColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: primary ? null : Border.all(color: AhlColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primary ? Colors.white : AhlColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primary ? Colors.white : AhlColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
