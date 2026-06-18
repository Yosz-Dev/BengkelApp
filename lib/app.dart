import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/jasa/provider/jasa_provider.dart';
import 'features/pelanggan/provider/pelanggan_provider.dart';
import 'features/sparepart/provider/sparepart_provider.dart';

/// Root widget aplikasi.
class PosBengkelApp extends StatelessWidget {
  const PosBengkelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SparepartProvider()),
        ChangeNotifierProvider(create: (_) => JasaProvider()),
        ChangeNotifierProvider(create: (_) => PelangganProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generate,
      ),
    );
  }
}
