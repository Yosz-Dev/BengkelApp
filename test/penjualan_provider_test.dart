import 'package:flutter_test/flutter_test.dart';
import 'package:pos_bengkel/features/sparepart/data/sparepart_model.dart';
import 'package:pos_bengkel/features/transaksi/provider/penjualan_provider.dart';

SparepartModel _sp(int id, {String nama = 'Item', double harga = 50000, int stok = 10}) {
  return SparepartModel(id: id, nama: nama, hargaJual: harga, stok: stok);
}

void main() {
  group('PenjualanProvider keranjang', () {
    test('addItem menambah item & menggabungkan qty', () {
      final p = PenjualanProvider();
      final sp = _sp(1);
      p.addItem(sp);
      p.addItem(sp);
      expect(p.cart.length, 1);
      expect(p.itemCount, 2);
      expect(p.qtyOf(1), 2);
    });

    test('tidak menambah sparepart dengan stok habis', () {
      final p = PenjualanProvider();
      p.addItem(_sp(1, stok: 0));
      expect(p.isEmpty, true);
    });

    test('increment tidak melebihi stok', () {
      final p = PenjualanProvider();
      final sp = _sp(1, stok: 2);
      p.addItem(sp); // qty 1
      p.increment(1); // qty 2 (mentok)
      p.increment(1); // ditolak
      expect(p.qtyOf(1), 2);
    });

    test('decrement menghapus item saat qty mencapai 0', () {
      final p = PenjualanProvider();
      p.addItem(_sp(1));
      p.decrement(1);
      expect(p.isEmpty, true);
    });

    test('removeItem & clear mengosongkan keranjang', () {
      final p = PenjualanProvider();
      p.addItem(_sp(1));
      p.addItem(_sp(2));
      p.removeItem(1);
      expect(p.cart.length, 1);
      p.clear();
      expect(p.isEmpty, true);
    });
  });

  group('PenjualanProvider perhitungan', () {
    test('subtotal & calc sesuai TransactionCalculator (contoh 250.000)', () {
      final p = PenjualanProvider();
      // 5 x 50.000 = 250.000 → diskon 25.000 → pajak 24.750 → total 249.750
      final sp = _sp(1, harga: 50000, stok: 10);
      for (var i = 0; i < 5; i++) {
        p.addItem(sp);
      }
      expect(p.subtotal, 250000);
      expect(p.calc.diskon, closeTo(25000, 0.001));
      expect(p.calc.pajak, closeTo(24750, 0.001));
      expect(p.calc.total, closeTo(249750, 0.001));
    });
  });
}
