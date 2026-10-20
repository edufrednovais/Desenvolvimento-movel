// ============================================================
// core/app_routes.dart
// Central de rotas (nomes das telas e mapa de navegação).
//
// COMO ADICIONAR UMA NOVA TELA:
//   1. Crie a tela em screens/<nome>/<nome>_screen.dart
//   2. Crie uma constante de nome aqui (ex: static const perfil = '/perfil')
//   3. Registre a tela no mapa `routes` logo abaixo
//   4. Se ela aparecer na barra de baixo, edite também
//      widgets/app_bottom_navigation.dart
// ============================================================

import 'package:flutter/material.dart';

import '../screens/about/about_screen.dart';
import '../screens/car/car_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/map/map_screen.dart';

class AppRoutes {
  AppRoutes._();

  // ---- Nomes das rotas (use sempre estas constantes, nunca texto solto) ----
  static const String home = '/';
  static const String car = '/car';
  static const String map = '/map';
  static const String login = '/login';
  static const String about = '/about';

  /// Mapa que liga cada nome de rota à sua tela.
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        car: (_) => const CarScreen(),
        map: (_) => const MapScreen(),
        login: (_) => const LoginScreen(),
        about: (_) => const AboutScreen(),
      };
}
