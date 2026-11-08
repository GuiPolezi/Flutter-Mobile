import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';

class ProdutoRepository {
  static const String _chave = 'crud.produtos';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // READ: uma chave guarda toda a lista, codificada em JSON.
  Future<List<Produto>> listar() async {
    final texto = await _prefs.getString(_chave);
    if (texto == null || texto.isEmpty) return [];

    final dados = jsonDecode(texto) as List<dynamic>;
    final produtos = dados.map((item) {
      return Produto.fromMap(Map<String, Object?>.from(item as Map));
    }).toList();
    produtos.sort((a, b) => b.id.compareTo(a.id));
    return produtos;
  }

  // Salva a lista completa após CREATE, UPDATE ou DELETE.
  Future<void> _salvarLista(List<Produto> produtos) async {
    final listaDeMapas = produtos.map((p) => p.toMap()).toList();
    await _prefs.setString(_chave, jsonEncode(listaDeMapas));
  }

  // CREATE: gera um ID simples, acrescenta o produto e regrava o JSON.
  Future<void> inserir(String nome, double preco) async {
    final produtos = await listar();
    final maiorId = produtos.fold<int>(
      0,
      (maior, p) => p.id > maior ? p.id : maior,
    );
    produtos.add(Produto(id: maiorId + 1, nome: nome, preco: preco));
    await _salvarLista(produtos);
  }

  // UPDATE: localiza o produto pelo ID e regrava a lista.
  Future<void> atualizar(Produto produto) async {
    final produtos = await listar();
    final indice = produtos.indexWhere((p) => p.id == produto.id);
    if (indice == -1) throw StateError('Produto não encontrado.');
    produtos[indice] = produto;
    await _salvarLista(produtos);
  }

  // DELETE: remove pelo ID e regrava a lista.
  Future<void> excluir(int id) async {
    final produtos = await listar();
    final quantidadeAnterior = produtos.length;
    produtos.removeWhere((p) => p.id == id);
    if (produtos.length == quantidadeAnterior) {
      throw StateError('Produto não encontrado.');
    }
    await _salvarLista(produtos);
  }
}
