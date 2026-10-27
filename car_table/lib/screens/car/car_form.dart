// ============================================================
// screens/car/car_form.dart
// Formulário para CADASTRAR ou EDITAR um carro.
//   - [carro] == null -> cadastra um carro novo
//   - [carro] != null -> edita o carro recebido
// Ao salvar, grava no banco (CarService) e fecha devolvendo true.
// É aberto como "bottom sheet" pela lista de carros.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/car_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Limita a digitação da placa, posição por posição:
///   3 letras + 4 números            (ABC1234  - padrão antigo)
///   3 letras + número + letra + 2 números (ABC1D23 - Mercosul)
/// Converte para maiúsculas e ignora espaço/hífen e caracteres inválidos.
class PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final entrada = newValue.text.toUpperCase();
    final saida = StringBuffer();

    for (final ch in entrada.split('')) {
      final pos = saida.length;
      if (pos >= 7) break;

      final ehLetra = RegExp(r'[A-Z]').hasMatch(ch);
      final ehNumero = RegExp(r'[0-9]').hasMatch(ch);

      final bool aceito;
      if (pos <= 2) {
        aceito = ehLetra; // letras
      } else if (pos == 3) {
        aceito = ehNumero; // número
      } else if (pos == 4) {
        aceito = ehNumero || ehLetra; // número (antiga) ou letra (Mercosul)
      } else {
        aceito = ehNumero; // posições 5 e 6: números
      }
      if (aceito) saida.write(ch);
    }

    final texto = saida.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class CarForm extends StatefulWidget {
  /// Dono do carro (usuário logado).
  final int usuarioId;

  /// Carro a editar (null = cadastro novo).
  final Carro? carro;

  const CarForm({super.key, required this.usuarioId, this.carro});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  late final TextEditingController _nomeController;
  late final TextEditingController _marcaController;
  late final TextEditingController _anoController;
  late final TextEditingController _modeloController;
  late final TextEditingController _placaController;
  late final TextEditingController _corController;

  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.carro != null;

  @override
  void initState() {
    super.initState();
    // Ao editar, os campos já vêm preenchidos com os dados do carro.
    final c = widget.carro;
    _nomeController = TextEditingController(text: c?.nomeCarro);
    _marcaController = TextEditingController(text: c?.marca);
    _anoController = TextEditingController(text: c?.ano.toString());
    _modeloController = TextEditingController(text: c?.modelo);
    _placaController = TextEditingController(text: c?.placa);
    _corController = TextEditingController(text: c?.cor);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _marcaController.dispose();
    _anoController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _corController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final marca = _marcaController.text.trim();
    final modelo = _modeloController.text.trim();
    final placa = _placaController.text.trim().toUpperCase();
    final cor = _corController.text.trim();
    final ano = int.tryParse(_anoController.text.trim());

    // Validação simples dos campos.
    if (nome.isEmpty ||
        marca.isEmpty ||
        modelo.isEmpty ||
        placa.isEmpty ||
        cor.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    if (!Carro.validarPlaca(placa)) {
      setState(() => _erro = 'Placa inválida. Use ABC1234 ou ABC1D23.');
      return;
    }
    if (ano == null || ano < 1900 || ano > DateTime.now().year + 1) {
      setState(() => _erro = 'Digite um ano válido (ex: 2022).');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final carro = Carro(
      id: widget.carro?.id,
      usuarioId: widget.usuarioId,
      nomeCarro: nome,
      marca: marca,
      ano: ano,
      modelo: modelo,
      placa: placa,
      cor: cor,
    );

    if (_editando) {
      await CarService.atualizar(carro);
    } else {
      await CarService.salvar(carro);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sobe o formulário junto com o teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editando ? 'Editar carro' : 'Novo carro',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Nome do carro',
                hint: 'Ex: Meu Civic',
                controller: _nomeController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Marca',
                hint: 'Ex: Honda',
                controller: _marcaController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Modelo',
                hint: 'Ex: Civic',
                controller: _modeloController,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Ano',
                hint: 'Ex: 2022',
                controller: _anoController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Placa',
                hint: 'Ex: ABC1D23',
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [PlacaInputFormatter()],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Cor',
                hint: 'Ex: Preto',
                controller: _corController,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 14),
                Text(_erro!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: _salvando ? 'Aguarde...' : (_editando ? 'Salvar' : 'Cadastrar'),
                onPressed: () {
                  if (!_salvando) _salvar();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
