import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../../core/widgets/ahl_card.dart';
import '../../data/repositories/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String key) {
    switch (key) {
      case 'location_on':
        return Icons.location_on;
      case 'share_location':
        return Icons.share_location;
      case 'home':
        return Icons.home;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifications = MockData.notifications;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final n = notifications[index];
            return AhlCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AhlColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconFor(n.icon), color: AhlColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          n.body,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AhlColors.inkMedium),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(n.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AhlColors.inkLight),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
