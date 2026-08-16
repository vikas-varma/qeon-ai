import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qeonai/app.dart';
import 'package:qeonai/features/auth/onboarding_screen.dart';
import 'package:qeonai/features/integrations/connected_apps_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Qeon AI starts on splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QeonApp()));
    expect(find.text('Qeon AI'), findsOneWidget);
  });

  testWidgets('onboarding fits a 360 by 640 screen without overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(720, 1280);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(find.text('Get started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gmail consent explains data use before continuing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GmailConsentSheet())),
    );

    expect(find.text('Connect Gmail to Qeon AI'), findsOneWidget);
    expect(find.text('Data Qeon AI accesses'), findsOneWidget);
    expect(find.text('How that data is used'), findsOneWidget);
    expect(find.text('Storage and AI processing'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('You approve external actions'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gmail-consent-continue')), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
