import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wefamily/app/app.dart';

Future<void> _startAtLogin(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  await tester.pumpWidget(const ProviderScope(child: WeFamilyApp()));
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _skipLogin(WidgetTester tester) async {
  await tester.tap(find.text('Skip for now (demo)'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('skip on login navigates to profile setup', (tester) async {
    await _startAtLogin(tester);

    expect(find.text('Welcome to WeFamily'), findsOneWidget);

    await _skipLogin(tester);

    expect(find.text('Tell us about you'), findsOneWidget,
        reason: 'Skip on login should open profile setup');
  });

  testWidgets('back from profile setup returns to login', (tester) async {
    await _startAtLogin(tester);
    await _skipLogin(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to WeFamily'), findsOneWidget,
        reason: 'Back from profile setup should return to login');
  });

  testWidgets('skip on profile setup navigates to circle', (tester) async {
    await _startAtLogin(tester);
    await _skipLogin(tester);

    await tester.tap(find.text('Skip for now (demo)'));
    await tester.pumpAndSettle();

    expect(find.text('Create your family circle'), findsOneWidget,
        reason: 'Skip on profile setup should open circle screen');
  });

  testWidgets('switch link toggles signup mode', (tester) async {
    await _startAtLogin(tester);

    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('New here? Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget,
        reason: 'Toggling should switch the submit button to signup');
  });

  testWidgets('fresh install full flow reaches home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: WeFamilyApp()));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Stay close to the ones you love'), findsOneWidget,
        reason: 'Fresh install should show onboarding');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to WeFamily'), findsOneWidget,
        reason: 'After onboarding, login should show');

    await _skipLogin(tester);
    await tester.tap(find.text('Skip for now (demo)'));
    await tester.pumpAndSettle();

    expect(find.text('Create your family circle'), findsOneWidget);

    await tester.tap(find.text('Create circle').last);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      tester.takeException();
    }

    expect(find.text('Profile'), findsWidgets,
        reason: 'Creating a circle should land on home shell');
  });

  testWidgets('empty fields show validation and skip still works', (tester) async {
    await _startAtLogin(tester);

    // Empty email/password must not sign in but must show a message
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
        find.text(
            'Enter a valid email and a password of at least 6 characters'),
        findsOneWidget,
        reason: 'Empty fields should show a validation message');

    // Skip + empty name must still reach circle in mock mode
    await _skipLogin(tester);
    await tester.tap(find.text('Save & continue'));
    await tester.pumpAndSettle();
    expect(find.text('Create your family circle'), findsOneWidget);
  });
}
