// ============================================================
// screens/home/route_painter.dart
// Desenho decorativo da tela inicial: uma grade escura com
// uma rota vermelha em zigue-zague.
// Usa CustomPainter (desenho direto no Canvas).
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ---------- 1. Grade de fundo ----------
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 25.0; // distância entre as linhas da grade

    // Linhas verticais
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Linhas horizontais
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ---------- 2. Rota vermelha ----------
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Pontos da rota (em proporção do tamanho disponível).
    final path = Path()
      ..moveTo(20, size.height - 20)
      ..lineTo(size.width * .20, size.height * .70)
      ..lineTo(size.width * .35, size.height * .75)
      ..lineTo(size.width * .48, size.height * .45)
      ..lineTo(size.width * .67, size.height * .55)
      ..lineTo(size.width * .82, size.height * .25)
      ..lineTo(size.width - 15, 20);

    canvas.drawPath(path, routePaint);
  }

  // O desenho é fixo, então nunca precisa ser redesenhado.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
