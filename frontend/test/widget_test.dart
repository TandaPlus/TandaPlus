import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  setUpAll(() {
    dotenv.env['API_BASE_URL'] = 'http://localhost:8080';
  });

  testWidgets('La pantalla home muestra el titulo TandaPlus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TandaPlusApp()));
    await tester.pumpAndSettle();

    expect(find.text('TandaPlus'), findsOneWidget);
  });
}
