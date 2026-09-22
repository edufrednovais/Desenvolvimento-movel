import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

void main() {
  runApp(const CarTableApp());
}

// ============================================================
// APP PRINCIPAL
// ============================================================

class CarTableApp extends StatelessWidget {
  const CarTableApp({super.key});

  static const Color background = Color(0xFF08080A);
  static const Color surface = Color(0xFF1D1D22);
  static const Color primary = Color(0xFFB80C09);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarTable',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,

        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: surface,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.white12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: primary,
              width: 1.5,
            ),
          ),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (_) => const HomeScreen(),
        '/car': (_) => const CarScreen(),
        '/map': (_) => const MapScreen(),
        '/login': (_) => const LoginScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}

// ============================================================
// LOGO
// ============================================================

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: CarTableApp.primary,
        ),

        const SizedBox(height: 8),

        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'CarTable',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

             
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BOTÃO PRINCIPAL
// ============================================================

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CarTableApp.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 1. TELA INICIAL
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [
                    const Spacer(),

                    const AppLogo(
                      size: 105,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Mais segurança para\no que importa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),

                    const Spacer(),

                    // Representação visual da rota
                    SizedBox(
                      height: 170,
                      width: double.infinity,

                      child: CustomPaint(
                        painter: RoutePainter(),

                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: CarTableApp.primary,
                            size: 55,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    PrimaryButton(
                      text: 'Começar',

                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/map',
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Text(
                          'Já tem uma conta? ',
                          style: TextStyle(
                            color: Colors.white54,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/login',
                            );
                          },

                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              color: CarTableApp.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Barra inferior
      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 0,
      ),
    );
  }
}

// ============================================================
// DESENHO DA ROTA DA TELA INICIAL
// ============================================================

class RoutePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 25.0;

    // Linhas verticais
    for (
      double x = 0;
      x < size.width;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Linhas horizontais
    for (
      double y = 0;
      y < size.height;
      y += spacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final routePaint = Paint()
      ..color = CarTableApp.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(
      20,
      size.height - 20,
    );

    path.lineTo(
      size.width * .20,
      size.height * .70,
    );

    path.lineTo(
      size.width * .35,
      size.height * .75,
    );

    path.lineTo(
      size.width * .48,
      size.height * .45,
    );

    path.lineTo(
      size.width * .67,
      size.height * .55,
    );

    path.lineTo(
      size.width * .82,
      size.height * .25,
    );

    path.lineTo(
      size.width - 15,
      20,
    );

    canvas.drawPath(
      path,
      routePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// 2. TELA CARRO
// ============================================================

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final nomeCarroController =
      TextEditingController();

  final placaController =
      TextEditingController();

  @override
  void dispose() {
    nomeCarroController.dispose();
    placaController.dispose();

    super.dispose();
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
              ),

              const SizedBox(height: 35),

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
                    Container(
                      width: 50,
                      height: 50,

                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 15),

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
                                : nomeCarroController
                                    .text,

                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            placaController.text
                                    .isEmpty
                                ? 'Sem placa cadastrada'
                                : placaController
                                    .text,

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

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 1,
      ),
    );
  }
}

// ============================================================
// 3. TELA MAPA
// ============================================================

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CarTableApp.background,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),

        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),

            children: [
              TextSpan(
                text: 'CarTable',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              
            ],
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // ==================================================
          // VEÍCULO
          // ==================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),

            child: Container(
              padding: const EdgeInsets.all(15),

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
                  Container(
                    height: 48,
                    width: 48,

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

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Meu Carro',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        SizedBox(height: 5),

                        Row(
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor:
                                  Colors.green,
                            ),

                            SizedBox(width: 6),

                            Text(
                              'Online • Atualizado agora',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),

          // ==================================================
          // MAPA
          // ==================================================

          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,

                  color: const Color(
                    0xFF111115,
                  ),

                  child: CustomPaint(
                    painter: MapPainter(),
                  ),
                ),

                // Ícone do veículo
                const Center(
                  child: VehicleMarker(),
                ),

                // Botão localização
                Positioned(
                  right: 20,
                  top: 20,

                  child: CircleAvatar(
                    backgroundColor:
                        CarTableApp.surface,

                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        size: 20,
                      ),

                      onPressed: () {},
                    ),
                  ),
                ),

                // ==================================================
                // ENDEREÇO
                // ==================================================

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,

                  child: Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: CarTableApp.surface,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color:
                              CarTableApp.primary,
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                'Rua das Flores, 123',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 3),

                              Text(
                                'São Paulo - SP',
                                style: TextStyle(
                                  color:
                                      Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // STATUS
                // ==================================================

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,

                  child: Container(
                    height: 72,

                    decoration: BoxDecoration(
                      color: CarTableApp.surface,
                      borderRadius:
                          BorderRadius.circular(18),
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

                        VerticalDivider(
                          color: Colors.white12,
                        ),

                        Expanded(
                          child: StatusItem(
                            icon:
                                Icons.battery_5_bar,
                            title: 'Bateria',
                            value: '78%',
                          ),
                        ),

                        VerticalDivider(
                          color: Colors.white12,
                        ),

                        Expanded(
                          child: StatusItem(
                            icon: Icons.gps_fixed,
                            title: 'Precisão',
                            value: '5 m',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 2,
      ),
    );
  }
}

// ============================================================
// MARCADOR DO CARRO NO MAPA
// ============================================================

class VehicleMarker extends StatelessWidget {
  const VehicleMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,

      decoration: BoxDecoration(
        color: CarTableApp.primary.withOpacity(.22),
        shape: BoxShape.circle,
      ),

      child: Center(
        child: Container(
          width: 48,
          height: 48,

          decoration: const BoxDecoration(
            color: CarTableApp.primary,
            shape: BoxShape.circle,
          ),

          child: const Icon(
            Icons.directions_car,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DESENHO DO MAPA
// ============================================================

class MapPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final streetPaint = Paint()
      ..color = const Color(0xFF29292F)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final smallStreetPaint = Paint()
      ..color = const Color(0xFF202025)
      ..strokeWidth = 4;

    // Ruas maiores

    canvas.drawLine(
      Offset(
        0,
        size.height * .2,
      ),
      Offset(
        size.width,
        size.height * .8,
      ),
      streetPaint,
    );

    canvas.drawLine(
      Offset(
        size.width * .2,
        0,
      ),
      Offset(
        size.width * .7,
        size.height,
      ),
      streetPaint,
    );

    canvas.drawLine(
      Offset(
        0,
        size.height * .8,
      ),
      Offset(
        size.width,
        size.height * .3,
      ),
      streetPaint,
    );

    // Ruas menores

    for (
      double i = 30;
      i < size.width;
      i += 70
    ) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(
          i - 80,
          size.height,
        ),
        smallStreetPaint,
      );
    }

    for (
      double i = 40;
      i < size.height;
      i += 80
    ) {
      canvas.drawLine(
        Offset(0, i),
        Offset(
          size.width,
          i + 90,
        ),
        smallStreetPaint,
      );
    }

    // Rota vermelha

    final routePaint = Paint()
      ..color = CarTableApp.primary
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(
      size.width * .1,
      size.height * .8,
    );

    path.lineTo(
      size.width * .3,
      size.height * .67,
    );

    path.lineTo(
      size.width * .45,
      size.height * .62,
    );

    path.lineTo(
      size.width * .55,
      size.height * .5,
    );

    path.lineTo(
      size.width * .7,
      size.height * .55,
    );

    path.lineTo(
      size.width * .85,
      size.height * .25,
    );

    canvas.drawPath(
      path,
      routePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// 4. TELA LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final nomeController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final senhaController =
      TextEditingController();

  bool esconderSenha = true;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            CarTableApp.background,

        elevation: 0,

        title: const Text(
          'Login',
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
              const SizedBox(height: 25),

              const AppLogo(
                size: 65,
              ),

              const SizedBox(height: 8),

              const Text(
                'Entre na sua conta para continuar',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 40),

              // Nome
              AppTextField(
                label: 'Nome',
                hint: 'Digite seu nome',
                controller: nomeController,
              ),

              const SizedBox(height: 18),

              // E-mail
              AppTextField(
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // Senha
              AppTextField(
                label: 'Senha',
                hint: 'Digite sua senha',
                controller: senhaController,
                obscureText: esconderSenha,

                suffixIcon: IconButton(
                  icon: Icon(
                    esconderSenha
                        ? Icons
                            .visibility_off_outlined
                        : Icons
                            .visibility_outlined,
                  ),

                  onPressed: () {
                    setState(() {
                      esconderSenha =
                          !esconderSenha;
                    });
                  },
                ),
              ),

              const SizedBox(height: 36),

              PrimaryButton(
                text: 'Entrar',

                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Login realizado com sucesso!',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Ainda não possui uma conta?',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () {},

                child: const Text(
                  'Criar conta',
                  style: TextStyle(
                    color: CarTableApp.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 3,
      ),
    );
  }
}

// ============================================================
// CAMPO DE TEXTO
// ============================================================

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;

  final TextEditingController controller;

  final TextInputType? keyboardType;

  final bool obscureText;

  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,

          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 5. TELA SOBRE
// ============================================================

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            CarTableApp.background,

        title: const Text(
          'Sobre o App',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 16),

            const AppLogo(
              size: 70,
            ),

            const SizedBox(height: 8),

            const Text(
              'Versão 1.0.0',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'O CarTable é um aplicativo de '
              'rastreamento em tempo real, '
              'desenvolvido para oferecer mais '
              'segurança, controle e tranquilidade '
              'no seu dia a dia.',

              style: TextStyle(
                color: Colors.white70,
                height: 1.6,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            const Divider(
              color: Colors.white12,
            ),

            const FeatureItem(
              icon: Icons.location_on_outlined,
              title:
                  'Rastreamento em tempo real',

              description:
                  'Saiba exatamente onde estão '
                  'seus veículos ou pessoas.',
            ),

            const FeatureItem(
              icon: Icons.shield_outlined,
              title: 'Mais segurança',

              description:
                  'Receba alertas e acompanhe '
                  'movimentos suspeitos.',
            ),

            const FeatureItem(
              icon: Icons.history,
              title: 'Histórico de trajetos',

              description:
                  'Acesse trajetos realizados '
                  'de forma simples e rápida.',
            ),

            const FeatureItem(
              icon: Icons.settings_outlined,
              title: 'Fácil de usar',

              description:
                  'Uma interface intuitiva e '
                  'completa para seu dia a dia.',
            ),

            const SizedBox(height: 16),

            const Divider(
              color: Colors.white12,
            ),

            const SizedBox(height: 18),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                children: [
                  TextSpan(
                    text: 'CarTable',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                 
                ],
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Conectando você ao que importa.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Feito por',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Arthur, Hugo e Eduardo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 4,
      ),
    );
  }
}

// ============================================================
// ITEM DA TELA SOBRE
// ============================================================

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: CarTableApp.primary,
            size: 30,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BARRA DE NAVEGAÇÃO
//
// 0 - Inicial
// 1 - Carro
// 2 - Mapa
// 3 - Login
// 4 - Sobre
// ============================================================

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,

      // Cor do fundo que aparece atrás da barra
      backgroundColor: CarTableApp.background,

      // Cor da barra
      color: CarTableApp.surface,

      // Cor do botão que fica levantado
      buttonBackgroundColor: CarTableApp.primary,

      animationCurve: Curves.easeInOut,

      animationDuration:
          const Duration(milliseconds: 600),

      items: const [
        // ==========================================
        // INICIAL
        // ==========================================

        CurvedNavigationBarItem(
          child: Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          label: 'Inicial',
        ),

        // ==========================================
        // CARRO
        // ==========================================

        CurvedNavigationBarItem(
          child: Icon(
            Icons.directions_car_outlined,
            color: Colors.white,
          ),
          label: 'Carro',
        ),

        // ==========================================
        // MAPA
        // ==========================================

        CurvedNavigationBarItem(
          child: Icon(
            Icons.map_outlined,
            color: Colors.white,
          ),
          label: 'Mapa',
        ),

        // ==========================================
        // LOGIN
        // ==========================================

        CurvedNavigationBarItem(
          child: Icon(
            Icons.person_outline,
            color: Colors.white,
          ),
          label: 'Login',
        ),

        // ==========================================
        // SOBRE
        // ==========================================

        CurvedNavigationBarItem(
          child: Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          label: 'Sobre',
        ),
      ],

      onTap: (index) {
        switch (index) {
          // Inicial
          case 0:
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
            break;

          // Carro
          case 1:
            Navigator.pushNamed(
              context,
              '/car',
            );
            break;

          // Mapa
          case 2:
            Navigator.pushNamed(
              context,
              '/map',
            );
            break;

          // Login
          case 3:
            Navigator.pushNamed(
              context,
              '/login',
            );
            break;

          // Sobre
          case 4:
            Navigator.pushNamed(
              context,
              '/about',
            );
            break;
        }
      },
    );
  }
}

// ============================================================
// STATUS DO MAPA
// ============================================================

class StatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatusItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Icon(
          icon,
          size: 19,
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
