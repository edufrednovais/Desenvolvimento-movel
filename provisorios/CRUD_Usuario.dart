
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<Database> _recuperarBancoDados() async {
    final caminhoBD = await getDatabasesPath();
    final localBD = join(caminhoBD, "banco.db");

    var db = await openDatabase(
      localBD,
      version: 1,
      onCreate: (db, dbVersaoRecente) async {
        String sql = """
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR,
            email VARCHAR,
            senha VARCHAR
          )
        """;
        await db.execute(sql);
      },
    );
    return db;
  }

  _salvarDados(String nome, String email, String senha) async {
    Database bd = await _recuperarBancoDados();

    Map<String, dynamic> dadosUsuario = {
      "nome": nome,
      "email": email,
      "senha": senha
    };

    int idUsuario = await bd.insert("usuarios", dadosUsuario);
    print("Salvo com ID: $idUsuario");
  }

  _listarUsuarios() async {
    Database bd = await _recuperarBancoDados();
    String sql = "SELECT * FROM usuarios";
    List usuarios = await bd.rawQuery(sql);

    for (var usuario in usuarios) {
      print(
        "Usuário: ${usuario["nome"]} - ${usuario["email"]} - ${usuario["senha"]}"
      );
    }
  }

  _listarUmUsuario(int id) async {
    Database bd = await _recuperarBancoDados();
    List usuarios = await bd.query(
      "usuarios",
      columns: ["id", "nome", "email", "senha"],
      where: "id = ?",
      whereArgs: [id]
    );

    for (var usuario in usuarios) {
      print(
        "Usuário ID $id: ${usuario["nome"]} - ${usuario["email"]} - ${usuario["senha"]}"
      );
    }
  }

  _atualizarUsuario(int id) async {
    Database bd = await _recuperarBancoDados();

    Map<String, dynamic> dadosUsuario = {
      "nome": "Novo nome",
      "email": "novo@email.com",
      "senha": "nova senha"
    };

    int retorno = await bd.update(
      "usuarios",
      dadosUsuario,
      where: "id = ?",
      whereArgs: [id]
    );

    print("Atualizado: $retorno registro(s)");
  }

  _excluirUsuario(int id) async {
    Database bd = await _recuperarBancoDados();

    int retorno = await bd.delete(
      "usuarios",
      where: "id = ?",
      whereArgs: [id]
    );

    print("Excluído: $retorno registro(s)");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD de Usuários"),
      ),
      body: Container(),
    );
  }
}
