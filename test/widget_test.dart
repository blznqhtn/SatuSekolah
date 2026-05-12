import 'package:flutter_test/flutter_test.dart';
// Perbaikan import: jangan pakai /lib/
import 'package:aplikasi_mobile_ortu/main.dart'; 

void main() {
  testWidgets('Counter infiltration test', (WidgetTester tester) async {
    // Ganti MyApp() menjadi ParentSchoolApp()
    await tester.pumpWidget(const ParentSchoolApp());

    expect(find.text('Portal Orang Tua'), findsOneWidget);
    expect(find.text('Bpk. Budi Santoso'), findsOneWidget);
  });
}