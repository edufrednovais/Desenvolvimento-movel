// ============================================================
// screens/map/vehicle_marker.dart
// Marcador do veículo no mapa: círculo vermelho com um
// "halo" transparente ao redor.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class VehicleMarker extends StatelessWidget {
  const VehicleMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Círculo externo (halo semitransparente)
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.22),
        shape: BoxShape.circle,
      ),
      child: Center(
        // Círculo interno (sólido) com o ícone do carro
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_car, color: Colors.white),
        ),
      ),
    );
  }
}
