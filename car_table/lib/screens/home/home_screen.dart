// ============================================================
// screens/home/home_screen.dart
// 1. TELA INICIAL
// Logo, slogan, ilustração da rota e botões de "Começar"
// e "Entrar".
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/primary_button.dart';
import 'route_painter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // CustomScrollView + SliverFillRemaining: o conteúdo ocupa a tela
        // toda, mas rola se a tela for pequena demais.
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),

                    // ---- Logo + slogan ----
                    const AppLogo(size: 105),
                    const SizedBox(height: 24),
                    const Text(
                      'Mais segurança para\no que importa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),

                    // ---- Ilustração da rota (desenhada em RoutePainter) ----
                    SizedBox(
                      height: 170,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: RoutePainter(),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 55,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // ---- Botão principal: abre o mapa ----
                    PrimaryButton(
                      text: 'Começar',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.map),
                    ),
                    const SizedBox(height: 18),

                    // ---- Link para a tela de login ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem uma conta? ',
                          style: TextStyle(color: Colors.white54),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}
