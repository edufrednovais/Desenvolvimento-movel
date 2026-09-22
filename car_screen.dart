import 'package:flutter/material.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final nomeCarroController = TextEditingController();
  final placaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Atualiza o card sempre que o nome do carro mudar
    nomeCarroController.addListener(() {
      setState(() {});
    });

    // Atualiza o card sempre que a placa mudar
    placaController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nomeCarroController.dispose();
    placaController.dispose();

    super.dispose();
  }

  // Formata a placa automaticamente
  String formatarPlaca(String placa) {
    // Remove tudo que não for letra ou número
    String texto = placa.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Limita a 7 caracteres
    if (texto.length > 7) {
      texto = texto.substring(0, 7);
    }

    // Coloca o hífen depois dos 3 primeiros caracteres
    if (texto.length > 3) {
      texto =
          '${texto.substring(0, 3)}-${texto.substring(3)}';
    }

    return texto.toUpperCase();
  }

  // Quando o usuário digita a placa
  void atualizarPlaca(String valor) {
    final placaFormatada = formatarPlaca(valor);

    // Evita ficar atualizando o controller desnecessariamente
    if (placaController.text != placaFormatada) {
      placaController.value = TextEditingValue(
        text: placaFormatada,
        selection: TextSelection.collapsed(
          offset: placaFormatada.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CarTableApp.background,
        elevation: 0,
        title: const Text(
          'Carro',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            children: [
              const SizedBox(height: 30),

              // Ícone do carro
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: CarTableApp.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),

                child: const Icon(
                  Icons.directions_car,
                  size: 45,
                  color: CarTableApp.primary,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Cadastrar carro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Informe os dados do seu veículo',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // Nome do carro
              AppTextField(
                label: 'Nome do carro',
                hint: 'Ex: Honda Civic',
                controller: nomeCarroController,
              ),

              const SizedBox(height: 20),

              // Placa
              AppTextField(
                label: 'Placa',
                hint: 'ABC-1234',
                controller: placaController,

                // Quando digitar, formata automaticamente
                onChanged: atualizarPlaca,
              ),

              const SizedBox(height: 35),

              // Botão cadastrar
              PrimaryButton(
                text: 'Cadastrar carro',

                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Carro cadastrado com sucesso!',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Card mostrando o veículo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: CarTableApp.surface,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),

                child: Row(
                  children: [
                    // Ícone
                    Container(
                      width: 50,
                      height: 50,

                      decoration:
                          const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 15),

                    // Informações do carro
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            nomeCarroController
                                    .text
                                    .isEmpty
                                ? 'Meu carro'
                                : nomeCarroController.text,

                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            placaController
                                    .text
                                    .isEmpty
                                ? 'Sem placa cadastrada'
                                : placaController.text,

                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          const AppBottomNavigation(
        currentIndex: 1,
      ),
    );
  }
}
