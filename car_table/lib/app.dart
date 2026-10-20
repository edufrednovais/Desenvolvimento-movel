// ============================================================
// app.dart
// Widget raiz do aplicativo (MaterialApp).
// Aqui apenas "juntamos" tema + rotas. Para alterar:
//   - cores/estilos  -> core/app_theme.dart e core/app_colors.dart
//   - telas/rotas    -> core/app_routes.dart
// ============================================================

import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';

class CarTableApp extends StatelessWidget {
  const CarTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarTable',
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
