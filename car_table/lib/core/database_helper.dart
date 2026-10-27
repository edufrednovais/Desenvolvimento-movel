// ============================================================
// core/database_helper.dart
// Abre o banco SQLite (sqflite) e cria as tabelas.
// É a mesma ideia do _recuperarBancoDados() dos CRUDs de exemplo,
// só que agora num arquivo único, compartilhado por usuários e
// carros (antes cada exemplo abria o banco por conta própria).
//
// Tabelas:
//   usuarios -> id, nome, email, senha
//   carros   -> id, usuario_id, nomeCarro, marca, ano, modelo,
//               placa, cor
//
// Cada carro pertence a um usuário (usuario_id). Se o usuário for
// excluído, os carros dele são excluídos junto (ON DELETE CASCADE).
// ============================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  /// Guarda a abertura do banco para abrir uma única vez.
  static Future<Database>? _futuroBanco;

  /// Retorna o banco aberto (abre na primeira chamada).
  static Future<Database> get banco => _futuroBanco ??= _abrirBanco();

  static Future<Database> _abrirBanco() async {
    final caminhoBD = await getDatabasesPath();
    final localBD = join(caminhoBD, 'cartable.db');

    return openDatabase(
      localBD,
      version: 1,
      // Liga as chaves estrangeiras (o SQLite deixa desligado por padrão).
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, versao) async {
        await db.execute("""
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR,
            email VARCHAR,
            senha VARCHAR
          )
        """);

        await db.execute("""
          CREATE TABLE carros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER NOT NULL,
            nomeCarro VARCHAR,
            marca VARCHAR,
            ano INTEGER,
            modelo VARCHAR,
            placa VARCHAR,
            cor VARCHAR,
            FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
              ON DELETE CASCADE
          )
        """);
      },
    );
  }
}
