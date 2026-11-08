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
      // A1: a versão sobe de 1 para 2 porque a tabela ganhou a coluna quantidade.
      version: 2,
      // onCreate só roda quando o arquivo produtos.db ainda não existe
      // (instalação nova). Por isso ele já cria a tabela com a coluna nova.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL,
            quantidade INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      // onUpgrade roda quando o banco já existe com uma versão menor.
      // Mudar só o onCreate não alteraria esses bancos (seção 3.6), então a
      // coluna é acrescentada aqui. DEFAULT 0 preenche as linhas antigas.
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE produtos ADD COLUMN quantidade INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
    return _banco!;
  }

  // READ: SELECT * FROM produtos ORDER BY ...
  // A3: quem ordena é o banco (cláusula ORDER BY). COLLATE NOCASE faz o
  // SQLite ignorar maiúsculas/minúsculas ao comparar os nomes.
  Future<List<Produto>> listar({bool ordenarPorNome = false}) async {
    final db = await _database;
    final registros = await db.query(
      'produtos',
      orderBy: ordenarPorNome ? 'nome COLLATE NOCASE ASC' : 'id DESC',
    );
    return registros.map(Produto.fromMap).toList();
  }

  // CREATE: INSERT INTO produtos (nome, preco, quantidade) VALUES (?, ?, ?).
  // O banco gera automaticamente o ID.
  Future<void> inserir(String nome, double preco, int quantidade) async {
    final db = await _database;
    await db.insert('produtos', {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
    });
  }

  // UPDATE: modifica somente o produto com o ID informado.
  Future<void> atualizar(Produto produto) async {
    final db = await _database;
    final alterados = await db.update(
      'produtos',
      {
        'nome': produto.nome,
        'preco': produto.preco,
        'quantidade': produto.quantidade,
      },
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
