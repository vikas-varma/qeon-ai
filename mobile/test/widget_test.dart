import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qeonai/app.dart';
import 'package:qeonai/features/auth/onboarding_screen.dart';
import 'package:qeonai/features/integrations/connected_apps_screen.dart';
import 'package:qeonai/features/integrations/email_agent_screen.dart';
import 'package:qeonai/features/settings/privacy_screen.dart';
import 'package:qeonai/features/settings/activity_screen.dart';
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

  testWidgets('email draft send stays disabled until explicit review', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmailDraftReviewSheet(
            draft: const {
              'to': 'recipient@example.com',
              'subject': 'Project update',
              'body': 'The work is ready for review.',
            },
            onApprove: () async => const {'status': 'sent'},
          ),
        ),
      ),
    );

    FilledButton sendButton = tester.widget(
      find.byKey(const Key('email-send-approved-button')),
    );
    expect(sendButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('email-send-review-checkbox')));
    await tester.pump();

    sendButton = tester.widget(
      find.byKey(const Key('email-send-approved-button')),
    );
    expect(sendButton.onPressed, isNotNull);
    expect(find.text('Approve and send'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('data deletion requires typed DELETE confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PrivacyScreen())),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-account-data-button')),
      300,
    );
    await tester.tap(find.byKey(const Key('delete-account-data-button')));
    await tester.pumpAndSettle();

    expect(find.text('Type DELETE to confirm.'), findsOneWidget);
    FilledButton deleteButton = tester.widget(
      find.byKey(const Key('delete-data-confirm-button')),
    );
    expect(deleteButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('delete-data-confirmation-field')),
      'DELETE',
    );
    await tester.pump();

    deleteButton = tester.widget(
      find.byKey(const Key('delete-data-confirm-button')),
    );
    expect(deleteButton.onPressed, isNotNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Type DELETE to confirm.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('security activity presents a safe human-readable action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ActivityEntry(
            activity: {
              'action': 'gmail.draft_approved_and_sent',
              'created_at': '2026-08-16T12:00:00Z',
              'details': {'gmail_message_id': 'hidden-from-the-list'},
            },
          ),
        ),
      ),
    );

    expect(find.text('Email approved and sent'), findsOneWidget);
    expect(find.text('hidden-from-the-list'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
