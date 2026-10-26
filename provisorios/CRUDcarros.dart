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
          CREATE TABLE carros (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            nomeCarro VARCHAR, 
            marca VARCHAR, 
            ano INTEGER, 
            modelo VARCHAR, 
            placa VARCHAR, 
            cor VARCHAR
          )
        """;
        await db.execute(sql);
      },
    );
    return db;
  }
  _salvarDados(String nomeCarro, String marca, int ano, String modelo, String placa, String cor) async {
    Database bd = await _recuperarBancoDados();
    Map<String, dynamic> dadosCarro = {
      "nomeCarro": nomeCarro,
      "marca": marca,
      "ano": ano,
      "modelo": modelo,
      "placa": placa,
      "cor": cor
    };
    int idCarro = await bd.insert("carros", dadosCarro);
    print("Salvo com ID: $idCarro");
  }

  _listarCarros() async {
    Database bd = await _recuperarBancoDados();
    String sql = "SELECT * FROM carros";
    List carros = await bd.rawQuery(sql);
    
    for (var carro in carros) {
      print("Carro: ${carro["nomeCarro"]} - ${carro["marca"]} - ${carro["ano"]} - ${carro["modelo"]} - ${carro["placa"]} - ${carro["cor"]}");
    }
  }
  _listarUmCarro(int id) async {
    Database bd = await _recuperarBancoDados();
    List carros = await bd.query(
      "carros",
      columns: ["id", "nomeCarro", "marca", "ano", "modelo", "placa", "cor"],
      where: "id = ?",
      whereArgs: [id]
    );
    
    for (var carro in carros) {
      print("Carro ID $id: ${carro["nomeCarro"]} - ${carro["marca"]} - ${carro["ano"]} - ${carro["modelo"]} - ${carro["placa"]} - ${carro["cor"]}");
    }
  }

  _atualizarCarro(int id) async {
    Database bd = await _recuperarBancoDados();
    Map<String, dynamic> dadosCarro = {
      "nomeCarro": "Novo nome do carro",
      "marca": "Nova marca",
      "ano": 2022,
      "modelo": "Novo modelo",
      "placa": "Nova placa",
      "cor": "Nova cor"
    };
    
    int retorno = await bd.update(
      "carros",
      dadosCarro,
      where: "id = ?",
      whereArgs: [id]
    );
    print("Atualizado: $retorno registro(s)");
  }

  _excluirCarro(int id) async {
    Database bd = await _recuperarBancoDados();
    int retorno = await bd.delete(
      "carros",
      where: "id = ?",
      whereArgs: [id]
    );
    print("Excluído: $retorno registro(s)");
  }

}
