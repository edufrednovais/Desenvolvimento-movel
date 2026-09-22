import 'package:flutter/material.dart';

void main() {
  runApp(const TrackingApp());
}

class TrackingApp extends StatelessWidget {
  const TrackingApp({super.key});

  static const Color background = Color(0xFF08080A);
  static const Color surface = Color(0xFF1D1D22);
  static const Color primary = Color(0xFFB80C09);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rastreia+',
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
        '/tracking': (_) => const TrackingScreen(),
        '/register': (_) => const RegisterScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}

//
// COMPONENTES
//

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
          color: TrackingApp.primary,
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
                text: 'Rastreia',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: '+',
                style: TextStyle(color: TrackingApp.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
          backgroundColor: TrackingApp.primary,
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

//
// 1. TELA INICIAL
//

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // CustomScrollView com SliverFillRemaining permite que os Spacers
        // funcionem em telas grandes, mas cria uma área de scroll 
        // automaticamente em telas menores para evitar o overflow.
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),

                    const AppLogo(size: 105),

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

                    //
                    // Representação visual de rastreamento
                    //
                    SizedBox(
                      height: 170,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: RoutePainter(),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: TrackingApp.primary,
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
                          '/tracking',
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                              '/register',
                            );
                          },
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              color: TrackingApp.primary,
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
    );
  }
}

//
// DESENHO DA ROTA
//

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 25.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final routePaint = Paint()
      ..color = TrackingApp.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(20, size.height - 20);

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

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//
// 2. TELA PRINCIPAL
//

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TrackingApp.background,
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
                text: 'Rastreia',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '+',
                style: TextStyle(
                  color: TrackingApp.primary,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          //
          // VEÍCULO
          //
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: TrackingApp.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
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
                          'Meu Veículo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Colors.green,
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

          //
          // MAPA
          //
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF111115),
                  child: CustomPaint(
                    painter: MapPainter(),
                  ),
                ),

                //
                // ÍCONE DO VEÍCULO
                //
                const Center(
                  child: VehicleMarker(),
                ),

                //
                // LOCALIZAÇÃO
                //
                Positioned(
                  right: 20,
                  top: 20,
                  child: CircleAvatar(
                    backgroundColor:
                        TrackingApp.surface,
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),

                //
                // CARD DE ENDEREÇO
                //
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TrackingApp.surface,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: TrackingApp.primary,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rua das Flores, 123',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'São Paulo - SP',
                                style: TextStyle(
                                  color: Colors.white54,
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

                //
                // STATUS
                //
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: TrackingApp.surface,
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

      //
      // MENU INFERIOR
      //
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: TrackingApp.background,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TrackingApp.primary,
        unselectedItemColor: Colors.white38,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 3) {
            Navigator.pushNamed(
              context,
              '/about',
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

class VehicleMarker extends StatelessWidget {
  const VehicleMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: TrackingApp.primary.withOpacity(.22),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: TrackingApp.primary,
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

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = const Color(0xFF29292F)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final smallStreetPaint = Paint()
      ..color = const Color(0xFF202025)
      ..strokeWidth = 4;

    //
    // Ruas maiores
    //
    canvas.drawLine(
      Offset(0, size.height * .2),
      Offset(size.width, size.height * .8),
      streetPaint,
    );

    canvas.drawLine(
      Offset(size.width * .2, 0),
      Offset(size.width * .7, size.height),
      streetPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * .8),
      Offset(size.width, size.height * .3),
      streetPaint,
    );

    //
    // Ruas menores
    //
    for (double i = 30; i < size.width; i += 70) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - 80, size.height),
        smallStreetPaint,
      );
    }

    for (double i = 40; i < size.height; i += 80) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i + 90),
        smallStreetPaint,
      );
    }

    //
    // Rota vermelha
    //
    final routePaint = Paint()
      ..color = TrackingApp.primary
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

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
      mainAxisAlignment: MainAxisAlignment.center,
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

//
// 3. TELA CADASTRO
//

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TrackingApp.background,
        title: const Text(
          'Cadastro',
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

              const AppLogo(size: 65),

              const SizedBox(height: 8),

              const Text(
                'Crie sua conta para continuar',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 40),

              AppTextField(
                label: 'Nome completo',
                hint: 'Digite seu nome',
                controller: nameController,
              ),

              const SizedBox(height: 18),

              AppTextField(
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              AppTextField(
                label: 'Telefone',
                hint: '(00) 00000-0000',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              AppTextField(
                label: 'Senha',
                hint: 'Crie uma senha',
                controller: passwordController,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 36),

              PrimaryButton(
                text: 'Cadastrar',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cadastro realizado com sucesso!',
                      ),
                    ),
                  );

                  Navigator.pushReplacementNamed(
                    context,
                    '/tracking',
                  );
                },
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Já tem uma conta? ',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      TextSpan(
                        text: 'Entrar',
                        style: TextStyle(
                          color:
                              TrackingApp.primary,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

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

//
// 4. TELA SOBRE
//

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TrackingApp.background,
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

            const AppLogo(size: 70),

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
              'O Rastreia+ é um aplicativo de rastreamento em tempo real, '
              'desenvolvido para oferecer mais segurança, controle e '
              'tranquilidade no seu dia a dia.',
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
                  'Saiba exatamente onde estão seus veículos ou pessoas.',
            ),

            const FeatureItem(
              icon: Icons.shield_outlined,
              title: 'Mais segurança',
              description:
                  'Receba alertas e acompanhe movimentos suspeitos.',
            ),

            const FeatureItem(
              icon: Icons.history,
              title: 'Histórico de trajetos',
              description:
                  'Acesse trajetos realizados de forma simples e rápida.',
            ),

            const FeatureItem(
              icon: Icons.settings_outlined,
              title: 'Fácil de usar',
              description:
                  'Uma interface intuitiva e completa para seu dia a dia.',
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
                    text: 'Rastreia',
                    style:
                        TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: '+',
                    style: TextStyle(
                      color: TrackingApp.primary,
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
          ],
        ),
      ),
    );
  }
}

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
            color: TrackingApp.primary,
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
