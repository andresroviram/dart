import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:rfw/formats.dart';

import 'package:client/src/app_rfwtxt.dart';

void main() {
  testWidgets('updates pager direction locally and shows a toast after input',
      (WidgetTester tester) async {
    final loader = _FakeLibraryLoader();

    await tester.pumpWidget(
      RfwOnboardingApp(
        baseUrl: 'http://example.test',
        loader: loader.call,
        pagerInterval: null,
      ),
    );
    await tester.pumpAndSettle();

    expect(loader.screens, <String>['gopass']);
    expect(find.text('Page 3'), findsOneWidget);
    expect(find.text('forward'), findsOneWidget);
    expect(find.text('Continue disabled'), findsOneWidget);

    await tester.tap(find.text('Set page 4'));
    await tester.pump();
    expect(find.text('Page 4'), findsOneWidget);
    expect(find.text('forward'), findsOneWidget);

    await tester.tap(find.text('Set page 2'));
    await tester.pump();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('backward'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3001234567');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '3001234567',
    );
    expect(find.text('Show toast'), findsOneWidget);

    await tester.tap(find.text('Show toast'));
    await tester.pump();
    await tester.pump();

    expect(loader.screens, <String>['gopass']);
    expect(find.text('Phone number registered'), findsOneWidget);
  });

  testWidgets('advances the pager automatically without fetching again',
      (WidgetTester tester) async {
    final loader = _FakeLibraryLoader();

    await tester.pumpWidget(
      RfwOnboardingApp(
        baseUrl: 'http://example.test',
        loader: loader.call,
        pagerInterval: const Duration(seconds: 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Page 3'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Page 4'), findsOneWidget);
    expect(find.text('forward'), findsOneWidget);
    expect(loader.screens, <String>['gopass']);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _FakeLibraryLoader {
  final screens = <String>[];

  Future<http.Response> call(Uri uri) async {
    final screen = uri.queryParameters['screen']!;
    screens.add(screen);

    return http.Response.bytes(
      encodeLibraryBlob(parseLibraryFile(_sources[screen]!)),
      200,
      headers: const <String, String>{'content-type': 'application/rfw'},
    );
  }
}

const _sources = <String, String>{
  'gopass': '''
import core.widgets;
import gopass.local;

widget root = Column(
  children: [
    Text(text: switch data.onboarding.page {
      1: "Page 1",
      2: "Page 2",
      3: "Page 3",
      default: "Page 4",
    }),
    Text(text: data.onboarding.direction),
    GestureDetector(
      onTap: event "setPage" { page: 4 },
      child: Text(text: "Set page 4"),
    ),
    GestureDetector(
      onTap: event "setPage" { page: 2 },
      child: Text(text: "Set page 2"),
    ),
    PhoneNumberField(
      value: data.form.phone,
      onChanged: event "phoneChanged" { },
    ),
    switch data.form.phone {
      "": Text(text: "Continue disabled"),
      default: GestureDetector(
        onTap: event "showToast" { message: "Phone number registered" },
        child: Text(text: "Show toast"),
      ),
    },
  ],
);''',
};
