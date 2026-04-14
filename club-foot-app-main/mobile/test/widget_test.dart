import 'package:flutter_test/flutter_test.dart';
import 'package:club_mobile/main.dart';

void main() {
  testWidgets('Login screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login Screen - Flutter'), findsOneWidget);
  });
}
