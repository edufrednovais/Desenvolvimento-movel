// ============================================================
// screens/car/car_list_sheet.dart
// Lista "Meus carros" (bottom sheet) com o CRUD completo:
//   - toque no carro      -> seleciona (fecha devolvendo o ID)
//   - ícone de lápis      -> edita (abre o CarForm)
//   - ícone de lixeira    -> exclui (pede confirmação)
//   - botão "Adicionar"   -> cadastra um carro novo (abre o CarForm)
// A lista é lida do banco aqui mesmo e recarregada após cada ação.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/car_service.dart';
import '../../widgets/primary_button.dart';
import 'car_form.dart';

class CarListSheet extends StatefulWidget {
  final int usuarioId;

  /// Carro atualmente selecionado (recebe um ✓ na lista).
  final int? selecionadoId;

  const CarListSheet({
    super.key,
    required this.usuarioId,
    required this.selecionadoId,
  });

  @override
  State<CarListSheet> createState() => _CarListSheetState();
}

class _CarListSheetState extends State<CarListSheet> {
  List<Carro> _carros = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final carros = await CarService.listar(widget.usuarioId);
    if (!mounted) return;
    setState(() {
      _carros = carros;
      _carregando = false;
    });
  }

  /// Abre o formulário (novo carro ou edição) e recarrega se salvou.
  Future<void> _abrirFormulario({Carro? carro}) async {
    final salvou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // deixa o formulário subir com o teclado
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CarForm(usuarioId: widget.usuarioId, carro: carro),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _confirmarExclusao(Carro carro) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir carro'),
        content: Text('Deseja excluir "${carro.nomeCarro}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;
    await CarService.excluir(carro.id!);
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Meus carros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (_carregando)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (_carros.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Você ainda não cadastrou nenhum carro.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _carros.length,
                itemBuilder: (_, i) {
                  final carro = _carros[i];
                  return ListTile(
                    leading: const Icon(Icons.directions_car_outlined),
                    title: Text(carro.nomeCarro),
                    subtitle: Text(
                      '${carro.marca} ${carro.modelo} • ${carro.ano} • '
                      '${carro.placa} • ${carro.cor}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    onTap: () => Navigator.pop(context, carro.id),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (carro.id == widget.selecionadoId)
                          const Icon(Icons.check, color: AppColors.primary),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _abrirFormulario(carro: carro),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _confirmarExclusao(carro),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: PrimaryButton(
              text: 'Adicionar carro',
              onPressed: () => _abrirFormulario(),
            ),
          ),
        ],
      ),
    );
  }
}
