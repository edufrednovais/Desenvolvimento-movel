// ============================================================
// widgets/app_bottom_navigation.dart
// Barra de navegação curva exibida na parte de baixo das telas.
//
// Cada tela passa o seu próprio `currentIndex` para a barra
// destacar o ícone correto:
//   0 = Inicial | 1 = Carro (login + mapa) | 2 = Sobre
//
// A ORDEM dos itens abaixo precisa ser a mesma da lista `_rotas`.
// ============================================================

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_routes.dart';

class AppBottomNavigation extends StatelessWidget {
  /// Posição (0 a 2) do item que deve aparecer selecionado.
  final int currentIndex;

  const AppBottomNavigation({super.key, required this.currentIndex});

  /// Rota de cada item da barra, na mesma ordem dos ícones.
  static const List<String> _rotas = [
    AppRoutes.home,
    AppRoutes.car,
    AppRoutes.about,
  ];

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor: AppColors.background,
      color: AppColors.surface,
      buttonBackgroundColor: AppColors.primary,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 400),

      // Itens exibidos (ícone + rótulo). Mantenha a ordem de `_rotas`.
      items: const [
        CurvedNavigationBarItem(
          child: Icon(Icons.home_outlined, color: Colors.white),
          label: 'Inicial',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.directions_car_outlined, color: Colors.white),
          label: 'Carro',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.info_outline, color: Colors.white),
          label: 'Sobre',
        ),
      ],

      // Ao tocar em um item, troca de tela (sem empilhar telas).
      onTap: (index) {
        // Já está nessa tela: não faz nada.
        if (index == currentIndex) return;

        Navigator.pushReplacementNamed(context, _rotas[index]);
      },
    );
  }
}
