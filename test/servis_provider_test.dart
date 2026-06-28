import 'package:flutter_test/flutter_test.dart';
import 'package:pos_bengkel/features/jasa/data/jasa_model.dart';
import 'package:pos_bengkel/features/pelanggan/data/pelanggan_model.dart';
import 'package:pos_bengkel/features/sparepart/data/sparepart_model.dart';
import 'package:pos_bengkel/features/transaksi/provider/servis_provider.dart';

JasaModel _jasa(int id, {String nama = 'Servis', double harga = 50000}) =>
    JasaModel(id: id, nama: nama, harga: harga);

SparepartModel _sp(int id, {double harga = 50000, int stok = 10}) =>
    SparepartModel(id: id, nama: 'Sparepart $id', hargaJual: harga, stok: stok);

void main() {
  group('ServisProvider item', () {
    test('addJasa menambah & menggabungkan qty', () {
      final p = ServisProvider();
      final j = _jasa(1);
      p.addJasa(j);
      p.addJasa(j);
      expect(p.jasaItems.length, 1);
      expect(p.jasaQtyOf(1), 2);
      expect(p.isEmpty, false);
    });

    test('decJasa menghapus saat qty 0', () {
      final p = ServisProvider();
      p.addJasa(_jasa(1));
      p.decJasa(1);
      expect(p.jasaItems, isEmpty);
    });

    test('addSparepart guard stok habis & batas stok', () {
      final p = ServisProvider();
      p.addSparepart(_sp(1, stok: 0));
      expect(p.sparepartItems, isEmpty);

      final sp = _sp(2, stok: 2);
      p.addSparepart(sp); // qty 1
      p.incSparepart(2); // qty 2 (mentok)
      p.incSparepart(2); // ditolak
      expect(p.sparepartQtyOf(2), 2);
    });

    test('isEmpty true hanya bila tak ada jasa & sparepart', () {
      final p = ServisProvider();
      expect(p.isEmpty, true);
      p.addSparepart(_sp(1));
      expect(p.isEmpty, false);
    });
  });

  group('ServisProvider pelanggan', () {
    test('set & clear pelanggan', () {
      final p = ServisProvider();
      const plg = PelangganModel(id: 5, nama: 'Budi');
      p.setPelanggan(plg);
      expect(p.pelanggan?.id, 5);
      p.clearPelanggan();
      expect(p.pelanggan, isNull);
    });
  });

  group('ServisProvider perhitungan', () {
    test('subtotal gabungan jasa + sparepart & calc sesuai kalkulator', () {
      final p = ServisProvider();
      // jasa 1x100.000 + sparepart 3x50.000 = 250.000
      p.addJasa(_jasa(1, harga: 100000));
      final sp = _sp(2, harga: 50000, stok: 10);
      p.addSparepart(sp);
      p.incSparepart(2);
      p.incSparepart(2); // qty 3
      expect(p.subtotal, 250000);
      // diskon 10% (>=200rb) = 25.000, dpp 225.000, pajak 11% = 24.750
      expect(p.calc.diskon, closeTo(25000, 0.001));
      expect(p.calc.pajak, closeTo(24750, 0.001));
      expect(p.calc.total, closeTo(249750, 0.001));
    });

    test('clear mengosongkan semua', () {
      final p = ServisProvider();
      p.addJasa(_jasa(1));
      p.addSparepart(_sp(2));
      p.setPelanggan(const PelangganModel(id: 1, nama: 'A'));
      p.clear();
      expect(p.isEmpty, true);
      expect(p.pelanggan, isNull);
    });
  });
}
