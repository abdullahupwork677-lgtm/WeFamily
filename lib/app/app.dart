import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import '../core/utils/locale_provider.dart';
import 'router.dart';

class WeFamilyApp extends ConsumerStatefulWidget {
  const WeFamilyApp({super.key});

  @override
  ConsumerState<WeFamilyApp> createState() => _WeFamilyAppState();
}

class _WeFamilyAppState extends ConsumerState<WeFamilyApp> {
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final Locale locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'WeFamily',
      debugShowCheckedModeBanner: false,
      theme: ahlTheme(locale),
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _appRouter.router,
    );
  }
}
