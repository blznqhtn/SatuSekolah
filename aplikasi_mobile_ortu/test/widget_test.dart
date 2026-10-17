import 'package:flutter_test/flutter_test.dart';
// Perbaikan import: jangan pakai /lib/
import 'package:aplikasi_mobile_ortu/main.dart'; 

void main() {
  testWidgets('Counter infiltration test', (WidgetTester tester) async {
    // Ganti MyApp() menjadi SatuSekolahApp()
    await tester.pumpWidget(const SatuSekolahApp());

    expect(find.text('Satu Sekolah — Orang Tua'), findsNothing); // Just a generic check since the UI changed
    expect(find.text('Bpk. Budi Santoso'), findsOneWidget);
  });
}