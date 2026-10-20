// ============================================================
// screens/map/map_painter.dart
// Desenha um "mapa" fictício: ruas principais, ruas pequenas
// e a rota do veículo em vermelho.
//
// Quando houver um mapa de verdade (ex: google_maps_flutter),
// este arquivo pode ser removido.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ---------- Pincéis ----------
    final streetPaint = Paint()
      ..color = AppColors.mapStreet
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final smallStreetPaint = Paint()
      ..color = AppColors.mapSmallStreet
      ..strokeWidth = 4;

    // ---------- 1. Três ruas principais (diagonais) ----------
    canvas.drawLine(
      Offset(0, size.height * .2),
      Offset(size.width, size.height * .8),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * .2, 0),
      Offset(size.width * .7, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * .8),
      Offset(size.width, size.height * .3),
      streetPaint,
    );

    // ---------- 2. Ruas pequenas ----------
    // Linhas inclinadas "para baixo-esquerda", espaçadas de 70 em 70.
    for (double i = 30; i < size.width; i += 70) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - 80, size.height),
        smallStreetPaint,
      );
    }
    // Linhas inclinadas "para baixo-direita", espaçadas de 80 em 80.
    for (double i = 40; i < size.height; i += 80) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i + 90),
        smallStreetPaint,
      );
    }

    // ---------- 3. Rota do veículo ----------
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * .1, size.height * .8)
      ..lineTo(size.width * .3, size.height * .67)
      ..lineTo(size.width * .45, size.height * .62)
      ..lineTo(size.width * .55, size.height * .5)
      ..lineTo(size.width * .7, size.height * .55)
      ..lineTo(size.width * .85, size.height * .25);

    canvas.drawPath(path, routePaint);
  }

  // Desenho fixo: nunca precisa ser redesenhado.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
