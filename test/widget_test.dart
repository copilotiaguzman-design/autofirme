// Tests básicos para Autofirme Sistema
import 'package:flutter_test/flutter_test.dart';
import 'package:autofirme_sistema/main.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Test básico: la app debe iniciarse sin errores
    await tester.pumpWidget(const MyApp());
    
    // Si llegamos aquí, la app se inició correctamente
    expect(true, isTrue);
  });
}
