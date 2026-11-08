import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/categoria.dart';
import '../models/produto.dart';

class ProdutoRepository {
  Database? _banco;

  // Abre o arquivo SQLite e cria as tabelas na primeira execução.
  Future<Database> get _database async {
    if (_banco != null) return _banco!;

    final pasta = await getDatabasesPath();
    final caminho = join(pasta, 'produtos.db');
    _banco = await openDatabase(
      caminho,
      // Histórico do esquema:
      // 1 = tabela produtos (Código 13)
      // 2 = coluna quantidade (A1)
      // 3 = tabela categorias + coluna categoria_id (A6)
      version: 3,
      // A6: o SQLite só confere as chaves estrangeiras (REFERENCES) com este
      // PRAGMA ligado, e ele precisa ser ligado toda vez que o banco abre.
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      // onCreate só roda quando o arquivo produtos.db ainda não existe
      // (instalação nova). Por isso ele já cria tudo na versão mais recente.
      onCreate: (db, version) async {
        await _criarCategorias(db);
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL,
            quantidade INTEGER NOT NULL DEFAULT 0,
            categoria_id INTEGER REFERENCES categorias(id)
          )
        ''');
      },
      // onUpgrade roda quando o banco já existe com uma versão menor.
      // Mudar só o onCreate não alteraria esses bancos (seção 3.6).
      // Cada 'if' aplica uma mudança; um banco da versão 1 passa pelos dois.
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // A1: DEFAULT 0 preenche as linhas antigas.
          await db.execute(
            'ALTER TABLE produtos ADD COLUMN quantidade INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 3) {
          // A6: produtos antigos ficam com categoria_id NULL (sem categoria).
          await _criarCategorias(db);
          await db.execute(
            'ALTER TABLE produtos ADD COLUMN categoria_id INTEGER REFERENCES categorias(id)',
          );
        }
      },
    );
    return _banco!;
  }

  // A6: cria a tabela categorias com algumas categorias iniciais.
  // É usado pelo onCreate (instalação nova) e pelo onUpgrade (banco antigo).
  Future<void> _criarCategorias(Database db) async {
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE
      )
    ''');
    for (final nome in ['Papelaria', 'Escritório', 'Informática']) {
      await db.insert('categorias', {'nome': nome});
    }
  }

  // A6: lista as categorias para o DropdownButtonFormField do formulário.
  Future<List<Categoria>> listarCategorias() async {
    final db = await _database;
    final registros = await db.query(
      'categorias',
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    return registros.map(Categoria.fromMap).toList();
  }

  // READ: produtos + nome da categoria numa consulta só (A6: LEFT JOIN).
  // LEFT JOIN mantém os produtos sem categoria (categoria_nome vem NULL).
  // A3: a ordem vem de dois textos fixos escritos aqui no código, nunca do
  // usuário, por isso pode entrar direto no SQL.
  // A4: o texto digitado vai como parâmetro '?', nunca concatenado (seção 3.7).
  Future<List<Produto>> listar({
    bool ordenarPorNome = false,
    String busca = '',
  }) async {
    final db = await _database;
    final termo = busca.trim();
    final filtro = termo.isEmpty ? '' : 'WHERE p.nome LIKE ?';
    final ordem = ordenarPorNome ? 'p.nome COLLATE NOCASE ASC' : 'p.id DESC';
    final registros = await db.rawQuery(
      '''
      SELECT p.id, p.nome, p.preco, p.quantidade, p.categoria_id,
             c.nome AS categoria_nome
      FROM produtos p
      LEFT JOIN categorias c ON c.id = p.categoria_id
      $filtro
      ORDER BY $ordem
      ''',
      termo.isEmpty ? [] : ['%$termo%'],
    );
    return registros.map(Produto.fromMap).toList();
  }

  // CREATE: INSERT INTO produtos (nome, preco, quantidade, categoria_id)
  // VALUES (?, ?, ?, ?). O banco gera automaticamente o ID.
  Future<void> inserir(
    String nome,
    double preco,
    int quantidade,
    int? categoriaId,
  ) async {
    final db = await _database;
    await db.insert('produtos', {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'categoria_id': categoriaId,
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
        'categoria_id': produto.categoriaId,
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
