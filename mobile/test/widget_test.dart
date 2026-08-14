import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qeonai/app.dart';
import 'package:qeonai/features/auth/onboarding_screen.dart';
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
}
