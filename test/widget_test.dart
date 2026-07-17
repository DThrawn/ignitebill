import 'package:flutter_test/flutter_test.dart';
import 'package:ignite_bill/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MonApplication());

    // Verify that the app title or some initial text is present.
    expect(find.text(S.appTitle), findsOneWidget);
  });
}
