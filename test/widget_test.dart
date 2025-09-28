import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:w3w/main.dart';
import 'package:w3w/providers/w3w_provider.dart';

void main() {
  testWidgets('What3words app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => W3WProvider(apiKey: 'test_api_key'),
        child: const MyApp(),
      ),
    );

    // Verify that the app loads with tabs
    expect(find.text('What3words Demo'), findsOneWidget);
    expect(find.text('AutoSuggest'), findsOneWidget);
    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
  });

  testWidgets('AutoSuggest tab test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => W3WProvider(apiKey: 'test_api_key'),
        child: const MyApp(),
      ),
    );

    // Tap on AutoSuggest tab (should be selected by default)
    expect(find.text('AutoSuggest'), findsOneWidget);
    expect(find.text('Start typing to get What3words suggestions'),
        findsOneWidget);
  });
}
