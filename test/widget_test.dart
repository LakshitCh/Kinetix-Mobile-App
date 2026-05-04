import 'package:flutter_test/flutter_test.dart';
import 'package:kinetix_mobile_app/main.dart';

void main() {
  testWidgets('Kinetix app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KinetixApp());
    // Basic smoke test — app should render without crashing
    expect(find.text('KINETIX'), findsAny);
  });
}
