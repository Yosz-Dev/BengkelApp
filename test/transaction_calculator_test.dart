import 'package:flutter_test/flutter_test.dart';
import 'package:pos_bengkel/core/utils/transaction_calculator.dart';

void main() {
  group('TransactionCalculator', () {
    test('tanpa diskon ketika subtotal < 200.000', () {
      final r = TransactionCalculator.calculate(150000);
      expect(r.diskon, 0);
      expect(r.dpp, 150000);
      expect(r.pajak, closeTo(16500, 0.001)); // 11% x 150.000
      expect(r.total, closeTo(166500, 0.001));
    });

    test('diskon 10% tepat di ambang 200.000', () {
      final r = TransactionCalculator.calculate(200000);
      expect(r.diskon, closeTo(20000, 0.001));
      expect(r.dpp, closeTo(180000, 0.001));
      expect(r.pajak, closeTo(19800, 0.001)); // 11% x 180.000
      expect(r.total, closeTo(199800, 0.001));
    });

    test('diskon 10% di atas ambang (contoh PRD 250.000)', () {
      final r = TransactionCalculator.calculate(250000);
      expect(r.diskon, closeTo(25000, 0.001));
      expect(r.dpp, closeTo(225000, 0.001));
      expect(r.pajak, closeTo(24750, 0.001)); // 11% x 225.000
      expect(r.total, closeTo(249750, 0.001));
    });

    test('kembalian dihitung benar', () {
      final r = TransactionCalculator.calculate(150000);
      expect(r.kembalian(200000), closeTo(33500, 0.001)); // 200.000 - 166.500
    });
  });
}
