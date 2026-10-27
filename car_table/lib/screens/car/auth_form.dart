// ============================================================
// screens/car/auth_form.dart
// Formulário de login / criação de conta.
// Aparece dentro da tela do Carro quando ninguém está logado.
// Quando o login (ou cadastro) dá certo, chama [onAuthenticated].
// ============================================================

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class AuthForm extends StatefulWidget {
  /// Chamado depois de entrar ou criar a conta com sucesso.
  final VoidCallback onAuthenticated;

  const AuthForm({super.key, required this.onAuthenticated});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  /// true = tela de "Criar conta"; false = tela de "Entrar".
  bool _criandoConta = false;
  bool _esconderSenha = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _alternarModo() {
    setState(() {
      _criandoConta = !_criandoConta;
      _erro = null;
      _confirmarController.clear();
    });
  }

  Future<void> _enviar() async {
    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;

    if (_criandoConta && senha != _confirmarController.text) {
      setState(() => _erro = 'As senhas não conferem.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    final resultado = _criandoConta
        ? await AuthService.cadastrar(nome, email, senha)
        : await AuthService.entrar(email, senha);

    if (!mounted) return;

    if (resultado.sucesso) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _carregando = false;
        _erro = resultado.erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 25),
            const AppLogo(size: 65),
            const SizedBox(height: 8),
            Text(
              _criandoConta
                  ? 'Crie sua conta para acessar seu carro'
                  : 'Entre na sua conta para acessar seu carro',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 36),

            // Nome só aparece ao criar conta.
            if (_criandoConta) ...[
              AppTextField(
                label: 'Nome',
                hint: 'Digite seu nome',
                controller: _nomeController,
              ),
              const SizedBox(height: 18),
            ],
            AppTextField(
              label: 'E-mail',
              hint: 'Digite seu e-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Senha',
              hint: 'Digite sua senha',
              controller: _senhaController,
              obscureText: _esconderSenha,
              suffixIcon: IconButton(
                icon: Icon(
                  _esconderSenha
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _esconderSenha = !_esconderSenha),
              ),
            ),

            // Confirmação de senha só aparece ao criar conta.
            if (_criandoConta) ...[
              const SizedBox(height: 18),
              AppTextField(
                label: 'Confirmar senha',
                hint: 'Digite a senha novamente',
                controller: _confirmarController,
                obscureText: _esconderSenha,
              ),
            ],

            // Mensagem de erro (e-mail/senha inválidos etc.)
            if (_erro != null) ...[
              const SizedBox(height: 14),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 30),

            PrimaryButton(
              text: _carregando
                  ? 'Aguarde...'
                  : (_criandoConta ? 'Criar conta' : 'Entrar'),
              onPressed: () {
                if (!_carregando) _enviar();
              },
            ),
            const SizedBox(height: 24),

            Text(
              _criandoConta ? 'Já possui uma conta?' : 'Ainda não possui uma conta?',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _alternarModo,
              child: Text(
                _criandoConta ? 'Entrar' : 'Criar conta',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
