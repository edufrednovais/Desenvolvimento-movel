// ============================================================
// widgets/primary_button.dart
// Botão principal do app (vermelho, largura total).
// Use este botão em vez de criar ElevatedButton novos,
// assim todos os botões ficam iguais.
// ============================================================

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  /// Texto exibido dentro do botão.
  final String text;

  /// Ação executada ao clicar.
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ocupa toda a largura disponível
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
