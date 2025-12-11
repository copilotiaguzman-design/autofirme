// Tests basicos para Autofirme Sistema
import 'package:flutter_test/flutter_test.dart';
import 'package:autofirme_sistema/main.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Test basico: la app debe iniciarse sin errores
    await tester.pumpWidget(const AutofirmeApp());
    
    // Si llegamos aqui, la app se inicio correctamente
    expect(true, isTrue);
  });
}
