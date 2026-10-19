import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefamily/core/widgets/ahl_button.dart';
import 'package:wefamily/core/widgets/pill_tabs.dart';
import 'package:wefamily/core/theme/theme.dart';

void main() {
  testWidgets('AhlButton renders label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ahlTheme(const Locale('en')),
        home: Scaffold(body: AhlButton(label: 'Continue', onPressed: () {})),
      ),
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('PillTabs renders tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ahlTheme(const Locale('en')),
        home: Scaffold(
          body: PillTabs(
            tabs: const ['People', 'Places'],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Places'), findsOneWidget);
  });
}
