// ============================================================
// core/app_colors.dart
// Paleta de cores do app. Se precisar mudar a identidade
// visual, altere SOMENTE aqui.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // Classe só com constantes: impede que alguém crie instâncias dela.
  AppColors._();

  /// Fundo geral das telas (quase preto).
  static const Color background = Color(0xFF08080A);

  /// Cor de cards, campos de texto e barra de navegação.
  static const Color surface = Color(0xFF1D1D22);

  /// Cor de destaque da marca (vermelho): botões, ícones, rotas.
  static const Color primary = Color(0xFFB80C09);

  /// Fundo da área do mapa (um pouco mais claro que o background).
  static const Color mapBackground = Color(0xFF111115);

  /// Ruas principais desenhadas no mapa.
  static const Color mapStreet = Color(0xFF29292F);

  /// Ruas secundárias desenhadas no mapa.
  static const Color mapSmallStreet = Color(0xFF202025);
}
