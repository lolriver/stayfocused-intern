import 'package:flutter_test/flutter_test.dart';
import 'package:stayfocusintern/main.dart';

void main() {
  testWidgets('App renders permission screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StayFocusedApp());
    expect(find.text('Permission Setup'), findsOneWidget);
  });
}
