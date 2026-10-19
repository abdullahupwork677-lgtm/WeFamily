import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import '../core/utils/locale_provider.dart';
import 'router.dart';

class WeFamilyApp extends ConsumerWidget {
  const WeFamilyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(localeProvider);
    final AppRouter appRouter = AppRouter();

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
      routerConfig: appRouter.router,
    );
  }
}

