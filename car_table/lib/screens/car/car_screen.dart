// ============================================================
// screens/car/car_screen.dart
// 2. TELA DO CARRO
// Funciona como uma "porta de entrada":
//   - NÃO logado -> mostra o login / criação de conta (AuthForm)
//   - logado     -> mostra o mapa, o carro selecionado e o botão
//                   "Sair". Tocando no card do carro abre a lista
//                   "Meus carros" (cadastrar, editar, excluir).
// Usuários e carros ficam no banco SQLite (AuthService e
// CarService); o login continua mesmo fechando o app.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/car_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../map/map_view.dart';
import 'auth_form.dart';
import 'car_list_sheet.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  /// Usuário logado (null = ninguém logado).
  UsuarioLogado? _usuario;

  /// Carros do usuário logado e o ID do carro selecionado.
  List<Carro> _carros = [];
  int? _carroSelecionadoId;

  /// true enquanto lê a sessão salva no aparelho.
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarSessao();
  }

  Future<void> _carregarSessao() async {
    final usuario = await AuthService.usuarioAtual();
    final carros =
        usuario == null ? <Carro>[] : await CarService.listar(usuario.id);
    if (!mounted) return;
    setState(() {
      _usuario = usuario;
      _carros = carros;
      _carroSelecionadoId = carros.isEmpty ? null : carros.first.id;
      _carregando = false;
    });
  }

  Future<void> _sair() async {
    await AuthService.sair();
    if (!mounted) return;
    setState(() {
      _usuario = null;
      _carros = [];
      _carroSelecionadoId = null;
    });
  }

  /// Carro selecionado no momento (null se não houver nenhum).
  Carro? get _carroSelecionado {
    for (final carro in _carros) {
      if (carro.id == _carroSelecionadoId) return carro;
    }
    return null;
  }

  /// Abre a lista "Meus carros" (cadastrar, editar, excluir, escolher).
  /// Ao fechar, recarrega os carros do banco, pois podem ter mudado.
  Future<void> _abrirMeusCarros() async {
    final escolhidoId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CarListSheet(
        usuarioId: _usuario!.id,
        selecionadoId: _carroSelecionadoId,
      ),
    );

    final carros = await CarService.listar(_usuario!.id);
    if (!mounted) return;
    setState(() {
      _carros = carros;
      // Prioridade: o carro tocado na lista; senão mantém o atual;
      // se ele foi excluído, usa o primeiro da lista.
      final idDesejado = escolhidoId ?? _carroSelecionadoId;
      final existe = carros.any((c) => c.id == idDesejado);
      _carroSelecionadoId =
          existe ? idDesejado : (carros.isEmpty ? null : carros.first.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          usuario == null ? 'Login' : 'Meu carro',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : usuario == null
              ? AuthForm(onAuthenticated: _carregarSessao)
              : _buildLogado(usuario),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  /// Conteúdo para usuário logado: saudação + Sair, e o mapa.
  Widget _buildLogado(UsuarioLogado usuario) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Olá, ${usuario.nome}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              TextButton.icon(
                onPressed: _sair,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sair'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
        Expanded(
          child: MapView(
            carModel: _carroSelecionado == null
                ? null
                : '${_carroSelecionado!.nomeCarro} • ${_carroSelecionado!.placa}',
            onSelectModel: _abrirMeusCarros,
          ),
        ),
      ],
    );
  }
}
