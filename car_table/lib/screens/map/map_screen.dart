// ============================================================
// screens/map/map_screen.dart
// 3. TELA MAPA
// Mostra o card do carro, o mapa (desenhado), o marcador do
// veículo, o endereço atual e o painel de status.
//
// Todos os dados abaixo são FICTÍCIOS (valores fixos).
// TODO: trocar por dados reais do rastreador / GPS.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_bottom_navigation.dart';
import 'map_painter.dart';
import 'status_item.dart';
import 'vehicle_marker.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---- Barra superior ----
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: const Text(
          'CarTable',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Card com o nome e o estado do carro
          _buildCarCard(),

          // Área do mapa (ocupa o espaço restante)
          Expanded(child: _buildMapArea()),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }

  // ----------------------------------------------------------
  // CARD DO CARRO (topo da tela)
  // ----------------------------------------------------------
  Widget _buildCarCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white10,
              child: Icon(Icons.directions_car, color: Colors.white),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meu Carro',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 5),
                  // Bolinha verde + texto de estado
                  Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'Online • Atualizado agora',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ÁREA DO MAPA
  // Várias camadas empilhadas (Stack), de baixo para cima:
  //   1. fundo + ruas desenhadas
  //   2. marcador do veículo (centro)
  //   3. botão "minha localização" (canto superior direito)
  //   4. card de endereço
  //   5. painel de status (velocidade, bateria, precisão)
  // ----------------------------------------------------------
  Widget _buildMapArea() {
    return Stack(
      children: [
        // 1. Fundo do mapa
        Container(
          width: double.infinity,
          color: AppColors.mapBackground,
          child: CustomPaint(painter: MapPainter()),
        ),

        // 2. Marcador do veículo
        const Center(child: VehicleMarker()),

        // 3. Botão de centralizar na localização
        Positioned(
          right: 20,
          top: 20,
          child: CircleAvatar(
            backgroundColor: AppColors.surface,
            child: IconButton(
              icon: const Icon(Icons.my_location, size: 20),
              onPressed: () {}, // TODO: centralizar o mapa
            ),
          ),
        ),

        // 4. Card de endereço
        Positioned(left: 16, right: 16, bottom: 100, child: _buildAddressCard()),

        // 5. Painel de status
        Positioned(left: 16, right: 16, bottom: 18, child: _buildStatusPanel()),
      ],
    );
  }

  /// Card com o endereço atual do veículo (valor fictício).
  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rua das Flores, 123',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3),
                Text(
                  'São Paulo - SP',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }

  /// Painel com três indicadores lado a lado (valores fictícios).
  Widget _buildStatusPanel() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Expanded(
            child: StatusItem(
              icon: Icons.speed,
              title: 'Velocidade',
              value: '48 km/h',
            ),
          ),
          VerticalDivider(color: Colors.white12),
          Expanded(
            child: StatusItem(
              icon: Icons.battery_5_bar,
              title: 'Bateria',
              value: '78%',
            ),
          ),
          VerticalDivider(color: Colors.white12),
          Expanded(
            child: StatusItem(
              icon: Icons.gps_fixed,
              title: 'Precisão',
              value: '5 m',
            ),
          ),
        ],
      ),
    );
  }
}
