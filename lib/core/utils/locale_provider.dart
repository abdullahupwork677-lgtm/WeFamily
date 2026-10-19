import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kLocalePrefKey = 'locale';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _load();
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(kLocalePrefKey);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLocalePrefKey, locale.languageCode);
  }

  void toggle() {
    final next = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    setLocale(next);
  }
}
