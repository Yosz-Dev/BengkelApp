import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/profil/data/profil_model.dart';
import '../../features/transaksi/data/transaksi_model.dart';
import 'formatter.dart';

/// Membangun dokumen PDF struk transaksi (ukuran roll 80mm).
/// Reusable untuk fitur Riwayat & Laporan di fase berikutnya.
class StrukPdf {
  StrukPdf._();

  static pw.Document build(TransaksiModel trx, ProfilModel? profil) {
    final doc = pw.Document();
    final namaBengkel = profil?.nama ?? 'POS Bengkel';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  namaBengkel,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (profil?.alamat != null && profil!.alamat!.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    profil.alamat!,
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              if (profil?.telepon != null && profil!.telepon!.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    'Telp: ${profil.telepon!}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              pw.SizedBox(height: 6),
              _divider(),
              _line('No', '#${trx.id ?? '-'}'),
              _line('Tanggal', Formatter.dateTime(trx.createdAt)),
              if (trx.kasirNama != null) _line('Kasir', trx.kasirNama!),
              _divider(),
              pw.SizedBox(height: 2),
              ...trx.items.map(_itemRow),
              pw.SizedBox(height: 2),
              _divider(),
              _line('Subtotal', Formatter.rupiah(trx.subtotal)),
              if (trx.diskon > 0)
                _line('Diskon', '- ${Formatter.rupiah(trx.diskon)}'),
              if (trx.pajak > 0) _line('Pajak', Formatter.rupiah(trx.pajak)),
              _line('TOTAL', Formatter.rupiah(trx.total), bold: true),
              _line('Bayar', Formatter.rupiah(trx.bayar)),
              _line('Kembali', Formatter.rupiah(trx.kembalian)),
              _divider(),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Terima kasih atas kunjungan Anda',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  static pw.Widget _itemRow(item) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(item.nama, style: const pw.TextStyle(fontSize: 9)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${item.qty} x ${Formatter.rupiah(item.harga)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              Formatter.rupiah(item.subtotal),
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
      ],
    );
  }

  static pw.Widget _line(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(value, style: style),
      ],
    );
  }

  static pw.Widget _divider() => pw.Divider(height: 6, thickness: 0.5);
}
