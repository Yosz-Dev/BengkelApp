import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data locale untuk format tanggal Indonesia.
  await initializeDateFormatting('id_ID', null);
  runApp(const PosBengkelApp());
}
