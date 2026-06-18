import 'package:intl/intl.dart';

/// Helper format mata uang & tanggal (locale Indonesia).
class Formatter {
  Formatter._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _number = NumberFormat.decimalPattern('id_ID');

  static final DateFormat _date = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  /// Format angka menjadi rupiah, mis. "Rp 200.000".
  static String rupiah(num value) => _currency.format(value);

  /// Format angka dengan pemisah ribuan, mis. "200.000".
  static String number(num value) => _number.format(value);

  /// Format tanggal "19 Jun 2026".
  static String date(DateTime value) => _date.format(value);

  /// Format tanggal & waktu "19 Jun 2026, 14:30".
  static String dateTime(DateTime value) => _dateTime.format(value);

  /// Parse ISO string aman menjadi DateTime.
  static DateTime parse(String iso) => DateTime.parse(iso);
}
