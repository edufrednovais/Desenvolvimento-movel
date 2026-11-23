import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

void main() => runApp(const CarTableApp());

class CarTableApp extends StatelessWidget {
  const CarTableApp({super.key});
  static const Color background = Color(0xFF08080A);
  static const Color surface = Color(0xFF1D1D22);
  static const Color primary = Color(0xFFB80C09);

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'CarTable',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(primary: primary, surface: surface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: Colors.white38),
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
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

// Banco único para usuários, veículos, manutenções e lembretes.
class BancoDados {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    final caminho = p.join(await getDatabasesPath(), 'banco.db');

    _database = await openDatabase(
      caminho,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE carros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nomeCarro TEXT NOT NULL,
            marca TEXT,
            ano INTEGER,
            modelo TEXT,
            placa TEXT,
            cor TEXT,
            usuarioId INTEGER,
            FOREIGN KEY(usuarioId) REFERENCES usuarios(id)
          )
        ''');

        await criarTabelasExtras(db);
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL,
            senha TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS carros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nomeCarro TEXT NOT NULL,
            marca TEXT,
            ano INTEGER,
            modelo TEXT,
            placa TEXT,
            cor TEXT
          )
        ''');

        final colunas = await db.rawQuery('PRAGMA table_info(carros)');
        final temUsuarioId =
            colunas.any((c) => c['name'] == 'usuarioId');

        if (!temUsuarioId) {
          await db.execute(
            'ALTER TABLE carros ADD COLUMN usuarioId INTEGER',
          );
        }

        if (oldVersion < 3) {
          await criarTabelasExtras(db);
        }
        // Garante a unicidade dos e-mails em bancos antigos.
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email)');
      },
    );

    return _database!;
  }

  static Future<void> criarTabelasExtras(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS manutencoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carroId INTEGER NOT NULL,
        servico TEXT NOT NULL,
        data TEXT NOT NULL,
        quilometragem INTEGER NOT NULL,
        valor REAL,
        descricao TEXT,
        FOREIGN KEY(carroId) REFERENCES carros(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lembretes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carroId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data TEXT NOT NULL,
        concluido INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(carroId) REFERENCES carros(id)
      )
    ''');
  }

  // USUÁRIOS

  static Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final db = await database;
    return db.query('usuarios', orderBy: 'nome COLLATE NOCASE');
  }

  static Future<int> salvarUsuario(
      String nome, String email, String senha) async {
    final db = await database;
    return db.insert('usuarios', {
      'nome': nome,
      'email': email,
      'senha': senha,
    });
  }

  static Future<int> atualizarUsuario(
      int id, String nome, String email, String senha) async {
    final db = await database;
    return db.update(
      'usuarios',
      {'nome': nome, 'email': email, 'senha': senha},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> excluirUsuario(int id) async {
    final db = await database;
    return db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // VEÍCULOS

  static Future<List<Map<String, dynamic>>> listarCarros() async {
    final db = await database;
    return db.rawQuery('''
      SELECT carros.*, usuarios.nome AS dono
      FROM carros
      LEFT JOIN usuarios ON carros.usuarioId = usuarios.id
      ORDER BY carros.id DESC
    ''');
  }

  static Future<int> salvarCarro(Map<String, dynamic> carro) async {
    final db = await database;
    return db.insert('carros', carro);
  }

  static Future<int> atualizarCarro(
      int id, Map<String, dynamic> carro) async {
    final db = await database;
    return db.update(
      'carros',
      carro,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> excluirCarro(int id) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.delete('manutencoes', where: 'carroId = ?', whereArgs: [id]);
      await txn.delete('lembretes', where: 'carroId = ?', whereArgs: [id]);
      return txn.delete('carros', where: 'id = ?', whereArgs: [id]);
    });
  }

  // MANUTENÇÕES

  static Future<List<Map<String, dynamic>>> listarManutencoes() async {
    final db = await database;
    return db.rawQuery('''
      SELECT manutencoes.*, carros.nomeCarro
      FROM manutencoes
      INNER JOIN carros ON manutencoes.carroId = carros.id
      ORDER BY manutencoes.data DESC, manutencoes.id DESC
    ''');
  }

  static Future<int> salvarManutencao(
      Map<String, dynamic> manutencao) async {
    final db = await database;
    return db.insert('manutencoes', manutencao);
  }

  static Future<int> excluirManutencao(int id) async {
    final db = await database;
    return db.delete(
      'manutencoes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // LEMBRETES

  static Future<List<Map<String, dynamic>>> listarLembretes() async {
    final db = await database;
    return db.rawQuery('''
      SELECT lembretes.*, carros.nomeCarro
      FROM lembretes
      INNER JOIN carros ON lembretes.carroId = carros.id
      ORDER BY concluido ASC, data ASC
    ''');
  }

  static Future<int> salvarLembrete(
      Map<String, dynamic> lembrete) async {
    final db = await database;
    return db.insert('lembretes', lembrete);
  }

  static Future<int> atualizarStatusLembrete(
      int id, bool concluido) async {
    final db = await database;
    return db.update(
      'lembretes',
      {'concluido': concluido ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> excluirLembrete(int id) async {
    final db = await database;
    return db.delete(
      'lembretes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 90});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(Icons.location_on, size: size, color: CarTableApp.primary),
    const SizedBox(height: 8),
    const Text('CarTable', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
  ]);
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 54,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: CarTableApp.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ));
}

class AppTextField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  const AppTextField({super.key, required this.label, required this.hint, required this.controller, this.keyboardType, this.obscureText = false, this.suffixIcon});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    TextField(controller: controller, keyboardType: keyboardType, obscureText: obscureText, decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon)),
  ]);
}

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) => CurvedNavigationBar(
    index: currentIndex,
    backgroundColor: CarTableApp.background,
    color: CarTableApp.surface,
    buttonBackgroundColor: CarTableApp.primary,
    animationCurve: Curves.easeInOut,
    animationDuration: const Duration(milliseconds: 400),
    items: const [
      CurvedNavigationBarItem(child: Icon(Icons.home_outlined, color: Colors.white), label: 'Inicial'),
      CurvedNavigationBarItem(child: Icon(Icons.map_outlined, color: Colors.white), label: 'Mapa'),
      CurvedNavigationBarItem(child: Icon(Icons.info_outline, color: Colors.white), label: 'Sobre'),
    ],
    onTap: (index) {
      if (index == currentIndex) return;
      const rotas = ['/', '/map', '/about'];
      Navigator.pushReplacementNamed(context, rotas[index]);
    },
  );
}

// Guarda o usuário que está conectado no momento.
class Sessao {
  static Map<String, dynamic>? usuario;

  static bool get estaLogado => usuario != null;

  static void sair() {
    usuario = null;
  }
}

// PAINEL INICIAL
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> carros = [];
  int totalUsuarios = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final usuarios = await BancoDados.listarUsuarios();
    final listaCarros = await BancoDados.listarCarros();
    if (!mounted) return;
    setState(() {
      totalUsuarios = usuarios.length;
      carros = listaCarros;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: CarTableApp.background,
      elevation: 0,
      title: const Text('CarTable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
      actions: [
        Builder(builder: (context) => IconButton(
          tooltip: Sessao.estaLogado ? 'Meu perfil' : 'Cadastrar usuário',
          onPressed: () async {
            if (Sessao.estaLogado) {
              Scaffold.of(context).openEndDrawer();
            } else {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroUsuarioScreen()));
              await carregarDados();
              if (mounted) setState(() {});
            }
          },
          icon: Icon(Sessao.estaLogado ? Icons.account_circle_outlined : Icons.person_add_alt_1),
        )),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: carregarDados,
      child: carregando ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Bem-vindo ao CarTable', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Acompanhe seus usuários e veículos cadastrados.', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: _CardResumo(titulo: 'Veículos', total: carros.length, icone: Icons.directions_car)),
            const SizedBox(width: 12),
            Expanded(child: _CardResumo(titulo: 'Usuários', total: totalUsuarios, icone: Icons.people_alt_outlined)),
          ]),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Veículos cadastrados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${carros.length} total', style: const TextStyle(color: Colors.white54)),
          ]),
          const SizedBox(height: 12),
          if (carros.isEmpty) _EstadoVazio(onCadastrar: () async {
            await Navigator.pushNamed(context, '/car');
            carregarDados();
          }) else ...carros.map((carro) => _CardCarro(carro: carro, onAlterado: carregarDados)),
          const SizedBox(height: 18),
          PrimaryButton(text: 'Cadastrar veículo', onPressed: () async {
            await Navigator.pushNamed(context, '/car');
            carregarDados();
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroUsuarioScreen()));
              await carregarDados();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.person_add_alt_1), label: const Text('Cadastrar usuário'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/login');
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.login),
            label: const Text('Entrar'),
          ),
        ],
      ),
    ),
    endDrawer: Sessao.estaLogado ? Drawer(
      backgroundColor: CarTableApp.surface,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 38, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Bem-vindo(a), ${Sessao.usuario?['nome'] ?? ''}!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${Sessao.usuario?['email'] ?? ''}',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Divider(color: Colors.white12),
            ),
            _itemMenu(Icons.directions_car_outlined, 'Meu Veículo', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/car').then((_) => carregarDados());
            }),
            _itemMenu(Icons.build_outlined, 'Manutenções', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManutencoesScreen(),
                ),
              );
            }),
            _itemMenu(Icons.notifications_none, 'Lembretes', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LembretesScreen(),
                ),
              );
            }),
            const Divider(color: Colors.white12, indent: 20, endIndent: 20),
            _itemMenu(Icons.settings_outlined, 'Configurações', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações ainda não disponíveis.')),
              );
            }),
            _itemMenu(Icons.help_outline, 'Ajuda', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Central de ajuda ainda não disponível.')),
              );
            }),
            const Spacer(),
            _itemMenu(Icons.logout, 'Sair da Conta', () {
              Sessao.sair();
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Você saiu da sua conta.')),
              );
            }),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('CarTable v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
          ],
        ),
      ),
    ) : null,
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
  );

  Widget _itemMenu(IconData icone, String titulo, VoidCallback acao) => ListTile(
    leading: Icon(icone, color: Colors.white70),
    title: Text(titulo, style: const TextStyle(color: Colors.white)),
    onTap: acao,
    dense: true,
  );
}

class _CardResumo extends StatelessWidget {
  final String titulo;
  final int total;
  final IconData icone;
  const _CardResumo({required this.titulo, required this.total, required this.icone});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: CarTableApp.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icone, color: CarTableApp.primary, size: 25),
      const SizedBox(height: 14),
      Text('$total', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
      Text(titulo, style: const TextStyle(color: Colors.white60)),
    ]),
  );
}

class _EstadoVazio extends StatelessWidget {
  final VoidCallback onCadastrar;
  const _EstadoVazio({required this.onCadastrar});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: CarTableApp.surface, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      const Icon(Icons.directions_car_outlined, size: 48, color: Colors.white38),
      const SizedBox(height: 12),
      const Text('Nenhum veículo cadastrado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 6),
      const Text('Cadastre seu primeiro veículo para ele aparecer aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: onCadastrar, child: const Text('Cadastrar veículo')),
    ]),
  );
}

class _CardCarro extends StatelessWidget {
  final Map<String, dynamic> carro;
  final Future<void> Function() onAlterado;
  const _CardCarro({required this.carro, required this.onAlterado});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: CarTableApp.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white10)),
    child: Row(children: [
      const CircleAvatar(backgroundColor: Color(0x33B80C09), child: Icon(Icons.directions_car, color: CarTableApp.primary)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${carro['nomeCarro'] ?? 'Veículo'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('${carro['marca'] ?? ''} ${carro['modelo'] ?? ''} ${carro['ano'] ?? ''}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text('Placa: ${carro['placa'] ?? 'Não informada'}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text('Proprietário: ${carro['dono'] ?? 'Não definido'}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
      PopupMenuButton<String>(onSelected: (opcao) async {
        if (opcao == 'editar') {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CarScreen(carro: carro)));
          await onAlterado();
        } else if (opcao == 'excluir') {
          final confirma = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Excluir veículo?'), content: const Text('Essa ação não poderá ser desfeita.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir'))],
          ));
          if (confirma == true) { await BancoDados.excluirCarro(carro['id'] as int); await onAlterado(); }
        }
      }, itemBuilder: (_) => const [PopupMenuItem(value: 'editar', child: Text('Editar')), PopupMenuItem(value: 'excluir', child: Text('Excluir'))]),
    ]),
  );
}

// CADASTRO E EDIÇÃO DE VEÍCULO
class CarScreen extends StatefulWidget {
  final Map<String, dynamic>? carro;
  const CarScreen({super.key, this.carro});
  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final nome = TextEditingController(), marca = TextEditingController(), ano = TextEditingController(), modelo = TextEditingController(), placa = TextEditingController(), cor = TextEditingController();
  List<Map<String, dynamic>> usuarios = [];
  int? usuarioId;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.carro;
    if (c != null) {
      nome.text = c['nomeCarro']?.toString() ?? '';
      marca.text = c['marca']?.toString() ?? '';
      ano.text = c['ano']?.toString() ?? '';
      modelo.text = c['modelo']?.toString() ?? '';
      placa.text = c['placa']?.toString() ?? '';
      cor.text = c['cor']?.toString() ?? '';
      usuarioId = c['usuarioId'] as int?;
    }
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    final lista = await BancoDados.listarUsuarios();
    if (!mounted) return;
    setState(() {
      usuarios = lista;
      if (usuarioId != null && !usuarios.any((u) => u['id'] == usuarioId)) usuarioId = null;
    });
  }

  @override
  void dispose() { nome.dispose(); marca.dispose(); ano.dispose(); modelo.dispose(); placa.dispose(); cor.dispose(); super.dispose(); }

  Future<void> salvar() async {
    if (nome.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do veículo.')));
      return;
    }
    setState(() => salvando = true);
    final dados = {
      'nomeCarro': nome.text.trim(), 'marca': marca.text.trim(),
      'ano': int.tryParse(ano.text.trim()), 'modelo': modelo.text.trim(),
      'placa': placa.text.trim().toUpperCase(), 'cor': cor.text.trim(),
      'usuarioId': usuarioId,
    };
    try {
      if (widget.carro == null) {
        await BancoDados.salvarCarro(dados);
      } else {
        await BancoDados.atualizarCarro(widget.carro!['id'] as int, dados);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o veículo.')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.carro == null ? 'Cadastrar veículo' : 'Editar veículo'), backgroundColor: CarTableApp.background),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const Icon(Icons.directions_car, size: 65, color: CarTableApp.primary),
      const SizedBox(height: 20),
      _campo('Nome do carro', 'Ex: Meu Honda Civic', nome),
      _campo('Marca', 'Ex: Honda', marca),
      _campo('Modelo', 'Ex: Civic EXL', modelo),
      _campo('Ano', 'Ex: 2022', ano, teclado: TextInputType.number),
      _campo('Placa', 'ABC-1234', placa),
      _campo('Cor', 'Ex: Preto', cor),
      const SizedBox(height: 16),
      const Text('Proprietário', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        value: usuarioId,
        decoration: const InputDecoration(hintText: 'Selecione o proprietário'),
        items: usuarios.map((u) => DropdownMenuItem<int>(value: u['id'] as int, child: Text('${u['nome']}'))).toList(),
        onChanged: (valor) => setState(() => usuarioId = valor),
      ),
      if (usuarios.isEmpty) ...[
        const SizedBox(height: 8),
        const Text('Cadastre um usuário antes de vincular um proprietário.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        TextButton(onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroUsuarioScreen()));
          carregarUsuarios();
        }, child: const Text('Cadastrar usuário')),
      ],
      const SizedBox(height: 25),
      PrimaryButton(text: salvando ? 'Salvando...' : 'Salvar veículo', onPressed: salvando ? () {} : salvar),
    ]),
  );

  Widget _campo(String label, String hint, TextEditingController controller, {TextInputType? teclado}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: AppTextField(label: label, hint: hint, controller: controller, keyboardType: teclado),
  );
}

// CADASTRO DE USUÁRIO
class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});
  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final nome = TextEditingController(), email = TextEditingController(), senha = TextEditingController();
  bool ocultar = true;
  @override
  void dispose() { nome.dispose(); email.dispose(); senha.dispose(); super.dispose(); }
  Future<void> salvar() async {
    if (nome.text.trim().isEmpty || email.text.trim().isEmpty || senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha nome, e-mail e senha.')));
      return;
    }
    try {
      final id = await BancoDados.salvarUsuario(nome.text.trim(), email.text.trim(), senha.text);
      Sessao.usuario = {
        'id': id,
        'nome': nome.text.trim(),
        'email': email.text.trim(),
      };
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível cadastrar. Verifique se o e-mail já existe.')));
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cadastrar usuário'), backgroundColor: CarTableApp.background),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const AppLogo(size: 55), const SizedBox(height: 28),
      AppTextField(label: 'Nome', hint: 'Digite o nome', controller: nome),
      const SizedBox(height: 18),
      AppTextField(label: 'E-mail', hint: 'Digite o e-mail', controller: email, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 18),
      AppTextField(label: 'Senha', hint: 'Digite a senha', controller: senha, obscureText: ocultar, suffixIcon: IconButton(icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => ocultar = !ocultar))),
      const SizedBox(height: 28), PrimaryButton(text: 'Cadastrar usuário', onPressed: salvar),
    ]),
  );
}

// LOGIN SIMPLES COM VALIDAÇÃO NO SQLITE
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(), senha = TextEditingController();
  bool ocultar = true;
  @override
  void dispose() { email.dispose(); senha.dispose(); super.dispose(); }
  Future<void> entrar() async {
    if (email.text.trim().isEmpty || senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o e-mail e a senha.')),
      );
      return;
    }
    final db = await BancoDados.database;
    final resultado = await db.query('usuarios', where: 'email = ? AND senha = ?', whereArgs: [email.text.trim(), senha.text]);
    if (!mounted) return;
    if (resultado.isNotEmpty) {
      Sessao.usuario = resultado.first;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha inválidos.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Login'), backgroundColor: CarTableApp.background, centerTitle: true),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const AppLogo(size: 65), const SizedBox(height: 35),
      AppTextField(label: 'E-mail', hint: 'Digite seu e-mail', controller: email, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 18),
      AppTextField(label: 'Senha', hint: 'Digite sua senha', controller: senha, obscureText: ocultar, suffixIcon: IconButton(icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => ocultar = !ocultar))),
      const SizedBox(height: 28), PrimaryButton(text: 'Entrar', onPressed: entrar),
      const SizedBox(height: 15), TextButton(
        onPressed: () async {
          final cadastrado = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CadastroUsuarioScreen()));
          if (cadastrado == true && mounted) Navigator.pop(context, true);
        },
        child: const Text('Criar conta'),
      ),
    ]),
  );
}

// MAPA DEMONSTRATIVO
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CarTable'), backgroundColor: CarTableApp.background, centerTitle: true),
    body: Column(children: [
      const Padding(padding: EdgeInsets.all(16), child: ListTile(leading: CircleAvatar(child: Icon(Icons.directions_car)), title: Text('Meu veículo'), subtitle: Text('Demonstração de localização'))),
      Expanded(child: Container(color: const Color(0xFF111115), child: const Center(child: Icon(Icons.location_on, color: CarTableApp.primary, size: 65)))),
      const Padding(padding: EdgeInsets.all(20), child: Text('Mapa ilustrativo. A localização real ainda não está conectada.', style: TextStyle(color: Colors.white54))),
    ]),
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
  );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sobre o App'), backgroundColor: CarTableApp.background, centerTitle: true),
    body: ListView(padding: const EdgeInsets.all(24), children: const [
      SizedBox(height: 16), AppLogo(size: 70), SizedBox(height: 18),
      Text('Versão 1.0.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
      SizedBox(height: 28),
      Text('O CarTable é um aplicativo de monitoramento de veículos, desenvolvido para oferecer mais segurança e controle.', style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 15)),
      SizedBox(height: 25), Divider(color: Colors.white12),
      ListTile(leading: Icon(Icons.location_on_outlined, color: CarTableApp.primary), title: Text('Rastreamento'), subtitle: Text('Acompanhe a localização dos veículos quando a integração estiver disponível.')),
      ListTile(leading: Icon(Icons.shield_outlined, color: CarTableApp.primary), title: Text('Mais segurança'), subtitle: Text('Centralize informações dos seus veículos.')),
      SizedBox(height: 20), Text('Feito por Arthur, Hugo e Eduardo', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
    ]),
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
  );
}

// HELPER PARA FORMATAR VALOR MONETÁRIO
class NumberFormatHelper {
  static String moeda(dynamic valor) {
    if (valor == null) return '0,00';
    final texto = valor.toString().trim().replaceAll(' ', '').replaceAll(r'R$', '');
    final normalizado = texto.contains(',')
        ? texto.replaceAll('.', '').replaceAll(',', '.')
        : texto;
    final numero = double.tryParse(normalizado) ?? 0.0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }
}

// TELA DE MANUTENÇÕES
class ManutencoesScreen extends StatefulWidget {
  const ManutencoesScreen({super.key});

  @override
  State<ManutencoesScreen> createState() => _ManutencoesScreenState();
}

class _ManutencoesScreenState extends State<ManutencoesScreen> {
  List<Map<String, dynamic>> manutencoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final lista = await BancoDados.listarManutencoes();

    if (!mounted) return;

    setState(() {
      manutencoes = lista;
      carregando = false;
    });
  }

  String formatarData(String data) {
    final partes = data.split('-');
    if (partes.length != 3) return data;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Future<void> adicionarManutencao() async {
    final carros = await BancoDados.listarCarros();

    if (!mounted) return;

    if (carros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um veículo antes de adicionar uma manutenção.'),
        ),
      );
      return;
    }

    final servico = TextEditingController();
    final quilometragem = TextEditingController();
    final valor = TextEditingController();
    final descricao = TextEditingController();

    int? carroId;
    DateTime data = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, atualizarDialog) => AlertDialog(
          title: const Text('Nova manutenção'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: carroId,
                  decoration: const InputDecoration(
                    labelText: 'Veículo',
                  ),
                  items: carros.map((carro) {
                    return DropdownMenuItem<int>(
                      value: carro['id'] as int,
                      child: Text('${carro['nomeCarro']}'),
                    );
                  }).toList(),
                  onChanged: (valorSelecionado) {
                    atualizarDialog(() {
                      carroId = valorSelecionado;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: servico,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de serviço',
                    hintText: 'Ex: Troca de óleo',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data da manutenção'),
                  subtitle: Text(
                    '${data.day.toString().padLeft(2, '0')}/'
                    '${data.month.toString().padLeft(2, '0')}/'
                    '${data.year}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final escolhida = await showDatePicker(
                      context: ctx,
                      initialDate: data,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );

                    if (escolhida != null) {
                      atualizarDialog(() {
                        data = escolhida;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: quilometragem,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem',
                    hintText: 'Ex: 50000',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valor,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor gasto (opcional)',
                    hintText: 'Ex: 250,00',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricao,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Detalhes da manutenção',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (carroId == null ||
                    servico.text.trim().isEmpty ||
                    quilometragem.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Selecione o veículo e preencha serviço e quilometragem.',
                      ),
                    ),
                  );
                  return;
                }

                final km = int.tryParse(quilometragem.text.trim());

                if (km == null || km < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe uma quilometragem válida.'),
                    ),
                  );
                  return;
                }

                final valorTexto = valor.text.trim();
                final valorNormalizado = valorTexto.contains(',')
                    ? valorTexto.replaceAll('.', '').replaceAll(',', '.')
                    : valorTexto;
                final valorNumerico = valorTexto.isEmpty
                    ? null
                    : double.tryParse(valorNormalizado);

                if (valorTexto.isNotEmpty &&
                    (valorNumerico == null || valorNumerico < 0)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe um valor válido.'),
                    ),
                  );
                  return;
                }

                final dataFormatada =
                    '${data.year.toString().padLeft(4, '0')}-'
                    '${data.month.toString().padLeft(2, '0')}-'
                    '${data.day.toString().padLeft(2, '0')}';

                await BancoDados.salvarManutencao({
                  'carroId': carroId,
                  'servico': servico.text.trim(),
                  'data': dataFormatada,
                  'quilometragem': km,
                  'valor': valorNumerico,
                  'descricao': descricao.text.trim(),
                });

                if (ctx.mounted) Navigator.pop(ctx);
                await carregar();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    servico.dispose();
    quilometragem.dispose();
    valor.dispose();
    descricao.dispose();
  }

  Future<void> excluir(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir manutenção?'),
        content: const Text(
          'Deseja realmente excluir este registro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await BancoDados.excluirManutencao(id);
      await carregar();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Manutenções'),
          backgroundColor: CarTableApp.background,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: CarTableApp.primary,
          onPressed: adicionarManutencao,
          child: const Icon(Icons.add),
        ),
        body: carregando
            ? const Center(child: CircularProgressIndicator())
            : manutencoes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 60,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Nenhuma manutenção registrada',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toque no botão + para registrar a primeira manutenção.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: carregar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: manutencoes.length,
                      itemBuilder: (context, index) {
                        final item = manutencoes[index];

                        return Card(
                          color: CarTableApp.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0x33B80C09),
                              child: Icon(
                                Icons.build,
                                color: CarTableApp.primary,
                              ),
                            ),
                            title: Text(
                              '${item['servico']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Veículo: ${item['nomeCarro']}'),
                                  Text('Data: ${formatarData('${item['data']}')}'),
                                  Text('Quilometragem: ${item['quilometragem']} km'),
                                  if (item['valor'] != null)
                                    Text(
                                      'Valor: R\$ ${NumberFormatHelper.moeda(item['valor'])}',
                                    ),
                                  if ((item['descricao'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text('Descrição: ${item['descricao']}'),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => excluir(item['id'] as int),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      );
}

// TELA DE LEMBRETES
class LembretesScreen extends StatefulWidget {
  const LembretesScreen({super.key});

  @override
  State<LembretesScreen> createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {
  List<Map<String, dynamic>> lembretes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final lista = await BancoDados.listarLembretes();

    if (!mounted) return;

    setState(() {
      lembretes = lista;
      carregando = false;
    });
  }

  String formatarData(String data) {
    final partes = data.split('-');
    if (partes.length != 3) return data;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Future<void> adicionarLembrete() async {
    final carros = await BancoDados.listarCarros();

    if (!mounted) return;

    if (carros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um veículo antes de criar um lembrete.'),
        ),
      );
      return;
    }

    final titulo = TextEditingController();
    final descricao = TextEditingController();

    int? carroId;
    DateTime data = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, atualizarDialog) => AlertDialog(
          title: const Text('Novo lembrete'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: carroId,
                  decoration: const InputDecoration(
                    labelText: 'Veículo',
                  ),
                  items: carros.map((carro) {
                    return DropdownMenuItem<int>(
                      value: carro['id'] as int,
                      child: Text('${carro['nomeCarro']}'),
                    );
                  }).toList(),
                  onChanged: (valorSelecionado) {
                    atualizarDialog(() {
                      carroId = valorSelecionado;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titulo,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ex: Fazer revisão',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricao,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Detalhes do lembrete',
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data prevista'),
                  subtitle: Text(
                    '${data.day.toString().padLeft(2, '0')}/'
                    '${data.month.toString().padLeft(2, '0')}/'
                    '${data.year}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final escolhida = await showDatePicker(
                      context: ctx,
                      initialDate: data,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (escolhida != null) {
                      atualizarDialog(() {
                        data = escolhida;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (carroId == null || titulo.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Selecione o veículo e informe o título.',
                      ),
                    ),
                  );
                  return;
                }

                final dataFormatada =
                    '${data.year.toString().padLeft(4, '0')}-'
                    '${data.month.toString().padLeft(2, '0')}-'
                    '${data.day.toString().padLeft(2, '0')}';

                await BancoDados.salvarLembrete({
                  'carroId': carroId,
                  'titulo': titulo.text.trim(),
                  'descricao': descricao.text.trim(),
                  'data': dataFormatada,
                  'concluido': 0,
                });

                if (ctx.mounted) Navigator.pop(ctx);
                await carregar();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    titulo.dispose();
    descricao.dispose();
  }

  Future<void> alterarStatus(int id, bool concluido) async {
    await BancoDados.atualizarStatusLembrete(id, concluido);
    await carregar();
  }

  Future<void> excluir(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lembrete?'),
        content: const Text(
          'Deseja realmente excluir este lembrete?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await BancoDados.excluirLembrete(id);
      await carregar();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Lembretes'),
          backgroundColor: CarTableApp.background,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: CarTableApp.primary,
          onPressed: adicionarLembrete,
          child: const Icon(Icons.add),
        ),
        body: carregando
            ? const Center(child: CircularProgressIndicator())
            : lembretes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 60,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Nenhum lembrete cadastrado',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toque no botão + para criar seu primeiro lembrete.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: carregar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lembretes.length,
                      itemBuilder: (context, index) {
                        final item = lembretes[index];
                        final concluido = item['concluido'] == 1;

                        return Card(
                          color: CarTableApp.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            leading: Checkbox(
                              value: concluido,
                              activeColor: CarTableApp.primary,
                              onChanged: (valor) {
                                alterarStatus(
                                  item['id'] as int,
                                  valor ?? false,
                                );
                              },
                            ),
                            title: Text(
                              '${item['titulo']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: concluido
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: concluido
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Veículo: ${item['nomeCarro']}'),
                                  Text('Data prevista: ${formatarData('${item['data']}')}'),
                                  if ((item['descricao'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text('Descrição: ${item['descricao']}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    concluido ? 'Concluído' : 'Pendente',
                                    style: TextStyle(
                                      color: concluido
                                          ? Colors.greenAccent
                                          : Colors.orangeAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => excluir(item['id'] as int),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      );
}
