// Smoke test alur autentikasi: tanpa sesi tersimpan, Splash mengarah ke Login.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_bengkel/app.dart';

void main() {
  testWidgets('Splash mengarah ke Login saat belum ada sesi', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PosBengkelApp());
    await tester.pumpAndSettle();

    // Layar login menampilkan tombol "Masuk".
    expect(find.text('Masuk'), findsOneWidget);
  });
}
