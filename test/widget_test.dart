import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockbasket/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StockBasket app loads dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GroceryInventoryApp());
    await tester.pumpAndSettle();

    // Verify that the title StockBasket is rendered
    expect(find.text('StockBasket'), findsOneWidget);
  });
}
