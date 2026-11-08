import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/produto.dart';

class ProdutoRepository {
  Database? _banco;

  // Abre o arquivo SQLite e cria a tabela na primeira execução.
  Future<Database> get _database async {
    if (_banco != null) return _banco!;

    final pasta = await getDatabasesPath();
    final caminho = join(pasta, 'produtos.db');
    _banco = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
          )
        ''');
      },
    );
    return _banco!;
  }

  // READ: SELECT id, nome, preco FROM produtos ORDER BY id DESC.
  Future<List<Produto>> listar() async {
    final db = await _database;
    final registros = await db.query('produtos', orderBy: 'id DESC');
    return registros.map(Produto.fromMap).toList();
  }

  // CREATE: INSERT INTO produtos (nome, preco) VALUES (?, ?).
  // O banco gera automaticamente o ID.
  Future<void> inserir(String nome, double preco) async {
    final db = await _database;
    await db.insert('produtos', {'nome': nome, 'preco': preco});
  }

  // UPDATE: modifica somente o produto com o ID informado.
  Future<void> atualizar(Produto produto) async {
    final db = await _database;
    final alterados = await db.update(
      'produtos',
      {'nome': produto.nome, 'preco': produto.preco},
      where: 'id = ?',
      whereArgs: [produto.id],
    );
    if (alterados == 0) throw StateError('Produto não encontrado.');
  }

  // DELETE: apaga somente o registro com o ID informado.
  Future<void> excluir(int id) async {
    final db = await _database;
    final excluidos = await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (excluidos == 0) throw StateError('Produto não encontrado.');
  }
}
