// ============================================================
// core/auth_service.dart
// CRUD de USUÁRIO (cadastro e login) usando SQLite (sqflite),
// baseado no CRUD_Usuario de exemplo.
//
// Correspondência com o exemplo:
//   _salvarDados       -> cadastrar()
//   _listarUmUsuario   -> _buscarPorEmail() / usuarioAtual()
//   _atualizarUsuario  -> atualizarUsuario()
//   _excluirUsuario    -> excluirConta()
//   (login)            -> entrar(): busca por e-mail e confere a senha
//
// A sessão (quem está logado) guarda só o ID do usuário em
// SharedPreferences, assim o login continua ao reabrir o app
// até apertar "Sair".
//
// ATENÇÃO: a senha está sendo gravada em texto puro porque este
// é um app de estudo. Em um app real guarde apenas um hash dela.
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';

/// Resultado de uma tentativa de login/cadastro.
/// Se [erro] for null, deu certo.
class AuthResult {
  final String? erro;
  const AuthResult.ok() : erro = null;
  const AuthResult.erro(String mensagem) : erro = mensagem;

  bool get sucesso => erro == null;
}

/// Dados do usuário que está logado.
class UsuarioLogado {
  final int id;
  final String nome;
  final String email;
  const UsuarioLogado({
    required this.id,
    required this.nome,
    required this.email,
  });
}

class AuthService {
  AuthService._();

  static const String _tabela = 'usuarios';
  static const String _chaveSessao = 'usuario_atual_id';

  // ----------------------------------------------------------
  // Auxiliares
  // ----------------------------------------------------------

  /// E-mail sempre comparado sem espaços e em minúsculas.
  static String _normalizar(String email) => email.trim().toLowerCase();

  /// Procura um usuário pelo e-mail (null se não existir).
  static Future<Map<String, dynamic>?> _buscarPorEmail(String email) async {
    final bd = await DatabaseHelper.banco;
    final usuarios = await bd.query(
      _tabela,
      columns: ['id', 'nome', 'email', 'senha'],
      where: 'email = ?',
      whereArgs: [_normalizar(email)],
    );
    return usuarios.isEmpty ? null : usuarios.first;
  }

  // ----------------------------------------------------------
  // Sessão
  // ----------------------------------------------------------

  /// Retorna o usuário logado, ou null se ninguém estiver logado.
  static Future<UsuarioLogado?> usuarioAtual() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_chaveSessao);
    if (id == null) return null;

    final bd = await DatabaseHelper.banco;
    final usuarios = await bd.query(
      _tabela,
      columns: ['id', 'nome', 'email'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (usuarios.isEmpty) {
      // Usuário da sessão não existe mais: encerra a sessão.
      await prefs.remove(_chaveSessao);
      return null;
    }

    final dados = usuarios.first;
    return UsuarioLogado(
      id: dados['id'] as int,
      nome: dados['nome'] as String,
      email: dados['email'] as String,
    );
  }

  /// Encerra a sessão (os dados do usuário continuam salvos).
  static Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }

  // ----------------------------------------------------------
  // CREATE: cadastro
  // ----------------------------------------------------------

  /// Cria uma conta nova e já deixa o usuário logado.
  static Future<AuthResult> cadastrar(
    String nome,
    String email,
    String senha,
  ) async {
    if (nome.trim().length < 3) {
      return const AuthResult.erro('O nome precisa ter ao menos 3 letras.');
    }
    final emailLimpo = _normalizar(email);
    if (!emailLimpo.contains('@') || !emailLimpo.contains('.')) {
      return const AuthResult.erro('Digite um e-mail válido.');
    }
    if (senha.length < 4) {
      return const AuthResult.erro('A senha precisa ter ao menos 4 caracteres.');
    }
    if (await _buscarPorEmail(emailLimpo) != null) {
      return const AuthResult.erro('Esse e-mail já está cadastrado. Faça login.');
    }

    final bd = await DatabaseHelper.banco;
    final idUsuario = await bd.insert(_tabela, {
      'nome': nome.trim(),
      'email': emailLimpo,
      'senha': senha,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveSessao, idUsuario);
    return const AuthResult.ok();
  }

  // ----------------------------------------------------------
  // READ: login
  // ----------------------------------------------------------

  /// Confere e-mail e senha; se estiverem certos, abre a sessão.
  static Future<AuthResult> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      return const AuthResult.erro('Preencha e-mail e senha.');
    }

    final dados = await _buscarPorEmail(email);
    if (dados == null) {
      return const AuthResult.erro('Usuário não encontrado.');
    }
    if (dados['senha'] != senha) {
      return const AuthResult.erro('Senha incorreta.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveSessao, dados['id'] as int);
    return const AuthResult.ok();
  }

  // ----------------------------------------------------------
  // UPDATE e DELETE (ainda sem tela; prontos para usar)
  // ----------------------------------------------------------

  /// Atualiza nome, e-mail e senha de um usuário.
  /// Retorna quantos registros foram alterados (1 = deu certo).
  static Future<int> atualizarUsuario(
    int id, {
    required String nome,
    required String email,
    required String senha,
  }) async {
    final bd = await DatabaseHelper.banco;
    return bd.update(
      _tabela,
      {'nome': nome.trim(), 'email': _normalizar(email), 'senha': senha},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Exclui a conta (e, por causa do CASCADE, os carros dela) e sai.
  static Future<int> excluirConta(int id) async {
    final bd = await DatabaseHelper.banco;
    final retorno = await bd.delete(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
    );
    await sair();
    return retorno;
  }
}
