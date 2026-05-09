import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_mobile_siswa/main.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our LoginScreen is present instead of MainWrapperScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
