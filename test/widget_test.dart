import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_crashlytics/app.dart';
import 'package:test_crashlytics/crashlytics_service.dart';

class FakeCrashlyticsService implements CrashlyticsService {
  Completer<void>? initialization;
  Completer<void>? preparation;
  bool failInitialization = false;
  bool failPreparation = false;
  int initializeCalls = 0;
  int prepareCalls = 0;
  int crashCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    if (failInitialization) throw Exception('Firebase unavailable');
    await initialization?.future;
  }

  @override
  Future<void> prepareCrash() async {
    prepareCalls++;
    if (failPreparation) throw Exception('Metadata unavailable');
    await preparation?.future;
  }

  @override
  void crash() => crashCalls++;
}

FilledButton crashButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.byWidgetPredicate((widget) => widget is FilledButton),
);

void main() {
  testWidgets('explains the Release requirement for an iPhone crash test', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(service: FakeCrashlyticsService()));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('On an iPhone, install the Release version'),
      findsOneWidget,
    );
  });

  testWidgets('loading keeps crash disabled until Firebase is ready', (
    tester,
  ) async {
    final service = FakeCrashlyticsService()
      ..initialization = Completer<void>();
    await tester.pumpWidget(MyApp(service: service));
    expect(find.text('Crashlytics Test'), findsOneWidget);
    expect(crashButton(tester).onPressed, isNull);
    service.initialization!.complete();
    await tester.pumpAndSettle();
    expect(crashButton(tester).onPressed, isNotNull);
    expect(find.text('Crashlytics ready'), findsOneWidget);
  });

  testWidgets('one tap prepares and delegates exactly one native crash', (
    tester,
  ) async {
    final service = FakeCrashlyticsService();
    await tester.pumpWidget(MyApp(service: service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate crash'));
    await tester.pumpAndSettle();
    expect(service.prepareCalls, 1);
    expect(service.crashCalls, 1);
  });

  testWidgets('rapid taps cannot produce multiple crash requests', (
    tester,
  ) async {
    final service = FakeCrashlyticsService()..preparation = Completer<void>();
    await tester.pumpWidget(MyApp(service: service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate crash'));
    await tester.tap(find.text('Generate crash'));
    await tester.pump();
    expect(service.prepareCalls, 1);
    service.preparation!.complete();
    await tester.pumpAndSettle();
    expect(service.crashCalls, 1);
  });

  testWidgets('initialization error disables crash and can retry', (
    tester,
  ) async {
    final service = FakeCrashlyticsService()..failInitialization = true;
    await tester.pumpWidget(MyApp(service: service));
    await tester.pumpAndSettle();
    expect(find.text('Could not initialize Firebase.'), findsOneWidget);
    expect(crashButton(tester).onPressed, isNull);
    service.failInitialization = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(service.initializeCalls, 2);
    expect(crashButton(tester).onPressed, isNotNull);
  });

  testWidgets('preparation error does not crash and permits another attempt', (
    tester,
  ) async {
    final service = FakeCrashlyticsService()..failPreparation = true;
    await tester.pumpWidget(MyApp(service: service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate crash'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not prepare the crash. Please try again.'),
      findsOneWidget,
    );
    expect(service.crashCalls, 0);
    expect(crashButton(tester).onPressed, isNotNull);
    service.failPreparation = false;
    await tester.tap(find.text('Generate crash'));
    await tester.pumpAndSettle();
    expect(service.crashCalls, 1);
  });
}
