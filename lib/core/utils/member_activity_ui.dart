import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../data/models/models.dart';
import '../theme/colors.dart';

extension MemberActivityUi on MemberActivity {
  IconData get icon => switch (this) {
    MemberActivity.driving => Icons.directions_car_rounded,
    MemberActivity.walking => Icons.directions_walk_rounded,
    MemberActivity.cycling => Icons.pedal_bike_rounded,
    MemberActivity.stationary => Icons.chair_rounded,
    MemberActivity.offline => Icons.cloud_off_rounded,
  };

  Color get color => switch (this) {
    MemberActivity.driving => AhlColors.primary,
    MemberActivity.walking => AhlColors.success,
    MemberActivity.cycling => AhlColors.gold,
    MemberActivity.stationary => AhlColors.inkMedium,
    MemberActivity.offline => AhlColors.inkLight,
  };

  String label(AppLocalizations l10n) => switch (this) {
    MemberActivity.driving => l10n.driving,
    MemberActivity.walking => l10n.walking,
    MemberActivity.cycling => l10n.cycling,
    MemberActivity.stationary => l10n.atRest,
    MemberActivity.offline => l10n.offline,
  };
}
