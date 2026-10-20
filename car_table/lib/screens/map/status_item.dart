// ============================================================
// screens/map/status_item.dart
// Item pequeno do painel de status do mapa
// (ícone + título + valor). Ex: Velocidade / 48 km/h.
// ============================================================

import 'package:flutter/material.dart';

class StatusItem extends StatelessWidget {
  final IconData icon; // ícone do item
  final String title; // nome da informação (ex: "Bateria")
  final String value; // valor exibido (ex: "78%")

  const StatusItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 19),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
