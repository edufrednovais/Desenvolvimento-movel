// ============================================================
// widgets/app_logo.dart
// Logo do app (ícone de localização + nome "CarTable").
// Usado nas telas Inicial, Login e Sobre.
// ============================================================

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class AppLogo extends StatelessWidget {
  /// Tamanho do ícone. O texto "CarTable" tem tamanho fixo.
  final double size;

  const AppLogo({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.location_on, size: size, color: AppColors.primary),
        const SizedBox(height: 8),
        const Text(
          'CarTable',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
