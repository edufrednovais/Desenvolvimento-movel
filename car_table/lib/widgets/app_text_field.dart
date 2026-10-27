// ============================================================
// widgets/app_text_field.dart
// Campo de texto padrão do app: rótulo em cima + campo embaixo.
// O visual do campo (cores, bordas) vem do tema em
// core/app_theme.dart.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  /// Texto exibido acima do campo.
  final String label;

  /// Texto de exemplo (aparece apagado quando o campo está vazio).
  final String hint;

  /// Controla/lê o texto digitado.
  final TextEditingController controller;

  /// Tipo de teclado (ex: TextInputType.emailAddress). Opcional.
  final TextInputType? keyboardType;

  /// Se true, esconde o texto (usado em senhas).
  final bool obscureText;

  /// Ícone opcional no fim do campo (ex: "olhinho" da senha).
  final Widget? suffixIcon;

  /// Chamado a cada alteração do texto. Opcional.
  final ValueChanged<String>? onChanged;

  /// Filtros/máscaras aplicados ao que é digitado. Opcional.
  final List<TextInputFormatter>? inputFormatters;

  /// Capitalização automática do teclado. Opcional.
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo do campo
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Campo de digitação
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
