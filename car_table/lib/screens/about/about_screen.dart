// ============================================================
// screens/about/about_screen.dart
// 5. TELA SOBRE
// Descrição do app, lista de funcionalidades e créditos
// da equipe.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_logo.dart';
import 'feature_item.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Sobre o App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ---- Logo e versão ----
            const AppLogo(size: 70),
            const SizedBox(height: 8),
            const Text(
              'Versão 1.0.0',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 28),

            // ---- Descrição do app ----
            const Text(
              'O CarTable é um aplicativo de rastreamento em tempo real, '
              'desenvolvido para oferecer mais segurança, controle e '
              'tranquilidade no seu dia a dia.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.6,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),

            // ---- Funcionalidades ----
            // Para adicionar uma nova, copie um FeatureItem e troque os textos.
            const FeatureItem(
              icon: Icons.location_on_outlined,
              title: 'Rastreamento em tempo real',
              description:
                  'Saiba exatamente onde estão seus veículos ou pessoas.',
            ),
            const FeatureItem(
              icon: Icons.shield_outlined,
              title: 'Mais segurança',
              description: 'Receba alertas e acompanhe movimentos suspeitos.',
            ),
            const FeatureItem(
              icon: Icons.history,
              title: 'Histórico de trajetos',
              description:
                  'Acesse trajetos realizados de forma simples e rápida.',
            ),
            const FeatureItem(
              icon: Icons.settings_outlined,
              title: 'Fácil de usar',
              description:
                  'Uma interface intuitiva e completa para seu dia a dia.',
            ),
            const SizedBox(height: 24),

            // ---- Créditos ----
            const Text(
              'Feito por',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Arthur, Hugo e Eduardo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
