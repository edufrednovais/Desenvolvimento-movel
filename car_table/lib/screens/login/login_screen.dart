// ============================================================
// screens/login/login_screen.dart
// 4. TELA LOGIN
// Campos de nome, e-mail e senha.
//
// Também demonstra o uso do SharedPreferences: o botão "Salvar"
// grava o e-mail digitado no aparelho e o botão "Recuperar"
// lê o valor gravado e mostra na tela.
//
// TODO: o botão "Entrar" ainda é só um aviso de teste
// (não valida nada de verdade).
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ---------- Controllers dos campos ----------
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  /// Chave usada para gravar/ler o e-mail no SharedPreferences.
  static const String _chaveEmail = 'email';

  /// E-mail recuperado do aparelho (exibido abaixo do campo de e-mail).
  String _textoSalvo = '';

  /// Controla se a senha está escondida (true) ou visível (false).
  bool esconderSenha = true;

  @override
  void dispose() {
    // Libera a memória dos controllers ao sair da tela.
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // LÓGICA: SALVAR / RECUPERAR (SharedPreferences)
  // ----------------------------------------------------------

  /// Grava no aparelho o e-mail que está digitado no campo.
  Future<void> _salvarDados() async {
    final valorDigitado = emailController.text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveEmail, valorDigitado);
    debugPrint('operação salvar: $valorDigitado');
  }

  /// Lê o e-mail gravado no aparelho e mostra na tela.
  Future<void> _recuperarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textoSalvo = prefs.getString(_chaveEmail) ?? '';
    });
    debugPrint('operação recuperar: $_textoSalvo');
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
          'Login',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 25),

              // ---- Cabeçalho ----
              const AppLogo(size: 65),
              const SizedBox(height: 8),
              const Text(
                'Entre na sua conta para continuar',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 40),

              // ---- Campos: nome e e-mail ----
              AppTextField(
                label: 'Nome',
                hint: 'Digite seu nome',
                controller: nomeController,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'E-mail',
                hint: 'Digite seu e-mail',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // ---- E-mail recuperado do aparelho ----
              Text(
                _textoSalvo,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // ---- Botões de teste do SharedPreferences ----
              _buildBotoesSalvarRecuperar(),
              const SizedBox(height: 18),

              // ---- Campo de senha com botão de mostrar/esconder ----
              AppTextField(
                label: 'Senha',
                hint: 'Digite sua senha',
                controller: senhaController,
                obscureText: esconderSenha,
                suffixIcon: IconButton(
                  icon: Icon(
                    esconderSenha
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => esconderSenha = !esconderSenha),
                ),
              ),
              const SizedBox(height: 36),

              // ---- Botão de entrar (apenas aviso de teste) ----
              PrimaryButton(
                text: 'Entrar',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login realizado com sucesso!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ---- Link para criar conta ----
              const Text(
                'Ainda não possui uma conta?',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {}, // TODO: abrir tela de cadastro
                child: const Text(
                  'Criar conta',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  /// Dois botões lado a lado: "Salvar" grava o e-mail e
  /// "Recuperar" mostra o e-mail gravado.
  ///
  /// Obs: o antigo `RaisedButton` foi removido do Flutter,
  /// por isso usamos `ElevatedButton`.
  Widget _buildBotoesSalvarRecuperar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: Colors.white,
          ),
          onPressed: _salvarDados,
          child: const Text('Salvar'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: Colors.white,
          ),
          onPressed: _recuperarDados,
          child: const Text('Recuperar'),
        ),
      ],
    );
  }
}
