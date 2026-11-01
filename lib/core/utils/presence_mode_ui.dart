import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../data/models/models.dart';
import '../theme/colors.dart';

extension PresenceModeUi on PresenceMode {
  IconData get icon => switch (this) {
    PresenceMode.driving => Icons.directions_car_rounded,
    PresenceMode.home => Icons.home_rounded,
    PresenceMode.work => Icons.work_rounded,
    PresenceMode.outside => Icons.park_rounded,
    PresenceMode.event => Icons.celebration_rounded,
  };

  String get icon3d => switch (this) {
    PresenceMode.driving => 'map-pin',
    PresenceMode.home => 'candle',
    PresenceMode.work => 'notebook',
    PresenceMode.outside => 'star',
    PresenceMode.event => 'calendar',
  };

  Color get color => switch (this) {
    PresenceMode.driving => AhlColors.primary,
    PresenceMode.home => AhlColors.success,
    PresenceMode.work => const Color(0xFF2563EB),
    PresenceMode.outside => const Color(0xFF0D9488),
    PresenceMode.event => AhlColors.primaryGradientEnd,
  };

  String label(AppLocalizations l10n) => switch (this) {
    PresenceMode.driving => l10n.modeDriving,
    PresenceMode.home => l10n.modeHome,
    PresenceMode.work => l10n.modeWork,
    PresenceMode.outside => l10n.modeOutside,
    PresenceMode.event => l10n.modeEvent,
  };
}
