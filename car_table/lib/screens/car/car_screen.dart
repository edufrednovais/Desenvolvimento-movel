// ============================================================
// screens/car/car_screen.dart
// 2. TELA DO CARRO
// Formulário para cadastrar o carro (nome + placa) e um card
// de pré-visualização que atualiza enquanto o usuário digita.
// A placa é formatada automaticamente (ex: ABC-1234).
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  // Controllers: guardam o que o usuário digitou em cada campo.
  final nomeCarroController = TextEditingController();
  final placaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reconstrói a tela a cada letra digitada, para o card de
    // pré-visualização (no fim da tela) mostrar o texto atual.
    nomeCarroController.addListener(() => setState(() {}));
    placaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Libera a memória dos controllers ao sair da tela.
    nomeCarroController.dispose();
    placaController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // LÓGICA DA PLACA
  // ----------------------------------------------------------

  /// Remove símbolos, limita a 7 caracteres, coloca o hífen
  /// depois do 3º caractere e converte para maiúsculas.
  /// Ex: "abc1234" -> "ABC-1234"
  String formatarPlaca(String placa) {
    // Mantém só letras e números
    String texto = placa.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Placa tem no máximo 7 caracteres
    if (texto.length > 7) {
      texto = texto.substring(0, 7);
    }

    // Insere o hífen: ABC + - + 1234
    if (texto.length > 3) {
      texto = '${texto.substring(0, 3)}-${texto.substring(3)}';
    }
    return texto.toUpperCase();
  }

  /// Chamado a cada alteração no campo de placa.
  /// Troca o texto digitado pelo texto já formatado.
  void atualizarPlaca(String valor) {
    final placaFormatada = formatarPlaca(valor);

    // Só atualiza se mudou (evita loop infinito de atualizações).
    if (placaController.text != placaFormatada) {
      placaController.value = TextEditingValue(
        text: placaFormatada,
        // Mantém o cursor sempre no final do texto.
        selection: TextSelection.collapsed(offset: placaFormatada.length),
      );
    }
  }

  // ----------------------------------------------------------
  // INTERFACE
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Carro',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // ---- Ícone circular do topo ----
              _buildHeaderIcon(),
              const SizedBox(height: 25),

              // ---- Títulos ----
              const Text(
                'Cadastrar carro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informe os dados do seu veículo',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // ---- Campos do formulário ----
              AppTextField(
                label: 'Nome do carro',
                hint: 'Ex: Honda Civic',
                controller: nomeCarroController,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Placa',
                hint: 'ABC-1234',
                controller: placaController,
                onChanged: atualizarPlaca, // formata enquanto digita
              ),
              const SizedBox(height: 35),

              // ---- Botão de cadastro ----
              // TODO: salvar de verdade (banco de dados / API).
              PrimaryButton(
                text: 'Cadastrar carro',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Carro cadastrado com sucesso!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // ---- Pré-visualização do carro ----
              _buildPreviewCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  /// Círculo com o ícone de carro no topo da tela.
  Widget _buildHeaderIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12),
      ),
      child: const Icon(
        Icons.directions_car,
        size: 45,
        color: AppColors.primary,
      ),
    );
  }

  /// Card que mostra o nome e a placa digitados.
  /// Se os campos estiverem vazios, mostra textos padrão.
  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Ícone do carro
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car, color: Colors.white),
          ),
          const SizedBox(width: 15),

          // Nome + placa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeCarroController.text.isEmpty
                      ? 'Meu carro'
                      : nomeCarroController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  placaController.text.isEmpty
                      ? 'Sem placa cadastrada'
                      : placaController.text,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
