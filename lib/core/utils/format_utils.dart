import 'package:wefamily/l10n/generated/app_localizations.dart';

/// "850 m" / "3.2 km" style distance label.
String formatDistance(AppLocalizations l10n, double meters) {
  if (meters < 950) {
    return l10n.mValue(meters.round().toString());
  }
  final km = meters / 1000;
  var value = km < 10 ? km.toStringAsFixed(1) : km.round().toString();
  if (value.endsWith('.0')) {
    value = value.substring(0, value.length - 2);
  }
  return l10n.kmValue(value);
}

/// "18 min" / "1 hr 12 min" style ETA label.
String formatDurationShort(AppLocalizations l10n, Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 60) {
    return l10n.minValue(minutes < 1 ? '1' : minutes.toString());
  }
  return l10n.hrMinValue(
    duration.inHours.toString(),
    (minutes % 60).toString(),
  );
}
