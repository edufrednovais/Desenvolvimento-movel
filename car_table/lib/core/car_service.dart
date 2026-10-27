// ============================================================
// core/car_service.dart
// CRUD de CARROS usando SQLite (sqflite), baseado no CRUDcarros
// de exemplo. Cada carro pertence a um usuário (usuarioId).
//
// Correspondência com o exemplo:
//   _salvarDados     -> CarService.salvar()
//   _listarCarros    -> CarService.listar()
//   _listarUmCarro   -> CarService.buscar()
//   _atualizarCarro  -> CarService.atualizar()
//   _excluirCarro    -> CarService.excluir()
// ============================================================

import 'database_helper.dart';

/// Um carro cadastrado. [id] é null enquanto ainda não foi salvo.
class Carro {
  final int? id;
  final int usuarioId;
  final String nomeCarro;
  final String marca;
  final int ano;
  final String modelo;
  final String placa;
  final String cor;

  const Carro({
    this.id,
    required this.usuarioId,
    required this.nomeCarro,
    required this.marca,
    required this.ano,
    required this.modelo,
    required this.placa,
    required this.cor,
  });

  /// Expressão regular para placa antiga (ABC1234) ou Mercosul (ABC1D23).
  static final RegExp _regexPlaca = RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$');

  /// Remove espaços e traços e converte para letras maiúsculas (ex: "abc-1d23" -> "ABC1D23").
  static String formatarPlaca(String placa) {
    return placa.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  }

  /// Retorna true se a placa estiver no formato antigo (ABC1234) ou Mercosul (ABC1D23).
  static bool validarPlaca(String placa) {
    final placaLimpa = formatarPlaca(placa);
    return _regexPlaca.hasMatch(placaLimpa);
  }

  /// Converte o carro no formato que o banco entende (já com a placa padronizada).
  Map<String, dynamic> toMap() => {
    'usuario_id': usuarioId,
    'nomeCarro': nomeCarro,
    'marca': marca,
    'ano': ano,
    'modelo': modelo,
    'placa': formatarPlaca(placa),
    'cor': cor,
  };

  /// Monta um carro a partir de uma linha do banco.
  factory Carro.fromMap(Map<String, dynamic> mapa) => Carro(
    id: mapa['id'] as int,
    usuarioId: mapa['usuario_id'] as int,
    nomeCarro: mapa['nomeCarro'] as String,
    marca: mapa['marca'] as String,
    ano: mapa['ano'] as int,
    modelo: mapa['modelo'] as String,
    placa: mapa['placa'] as String,
    cor: mapa['cor'] as String,
  );
}

class CarService {
  CarService._();

  static const String _tabela = 'carros';

  /// CREATE: grava um carro novo e devolve o ID gerado.
  /// Lança um [ArgumentError] se a placa for inválida.
  static Future<int> salvar(Carro carro) async {
    if (!Carro.validarPlaca(carro.placa)) {
      throw ArgumentError(
        'Placa inválida (${carro.placa}). Use o formato ABC1234 ou ABC1D23.',
      );
    }

    final bd = await DatabaseHelper.banco;
    return bd.insert(_tabela, carro.toMap());
  }

  /// READ: lista todos os carros de um usuário.
  static Future<List<Carro>> listar(int usuarioId) async {
    final bd = await DatabaseHelper.banco;
    final linhas = await bd.query(
      _tabela,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'id',
    );
    return linhas.map(Carro.fromMap).toList();
  }

  /// READ: busca um carro pelo ID (null se não existir).
  static Future<Carro?> buscar(int id) async {
    final bd = await DatabaseHelper.banco;
    final linhas = await bd.query(_tabela, where: 'id = ?', whereArgs: [id]);
    return linhas.isEmpty ? null : Carro.fromMap(linhas.first);
  }

  /// UPDATE: atualiza os dados de um carro já salvo (precisa ter id).
  /// Retorna quantos registros foram alterados (1 = deu certo).
  /// Lança um [ArgumentError] se a placa for inválida.
  static Future<int> atualizar(Carro carro) async {
    if (!Carro.validarPlaca(carro.placa)) {
      throw ArgumentError(
        'Placa inválida (${carro.placa}). Use o formato ABC1234 ou ABC1D23.',
      );
    }

    final bd = await DatabaseHelper.banco;
    return bd.update(
      _tabela,
      carro.toMap(),
      where: 'id = ?',
      whereArgs: [carro.id],
    );
  }

  /// DELETE: exclui um carro pelo ID.
  static Future<int> excluir(int id) async {
    final bd = await DatabaseHelper.banco;
    return bd.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}
