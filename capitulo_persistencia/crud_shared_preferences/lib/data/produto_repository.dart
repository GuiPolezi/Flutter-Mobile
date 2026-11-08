import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';

class ProdutoRepository {
  static const String _chave = 'crud.produtos';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // Lê a lista COMPLETA gravada na chave, sem ordenar.
  // A3: inserir, atualizar e excluir usam este método, e não listar(),
  // porque regravam todos os produtos. Se usassem uma lista ordenada ou
  // filtrada, os produtos fora do filtro seriam apagados ao regravar.
  Future<List<Produto>> _lerTodos() async {
    final texto = await _prefs.getString(_chave);
    if (texto == null || texto.isEmpty) return [];

    final dados = jsonDecode(texto) as List<dynamic>;
    return dados.map((item) {
      return Produto.fromMap(Map<String, Object?>.from(item as Map));
    }).toList();
  }

  // READ: uma chave guarda toda a lista, codificada em JSON.
  // A3/A4: filtro e ordenação são feitos aqui, em Dart, depois de carregar
  // a lista inteira (o SharedPreferences não sabe consultar, só guardar).
  Future<List<Produto>> listar({
    bool ordenarPorNome = false,
    String busca = '',
  }) async {
    var produtos = await _lerTodos();

    // A4: mantém só os produtos cujo nome contém o texto digitado,
    // ignorando maiúsculas/minúsculas.
    final termo = busca.trim().toLowerCase();
    if (termo.isNotEmpty) {
      produtos = produtos
          .where((p) => p.nome.toLowerCase().contains(termo))
          .toList();
    }

    if (ordenarPorNome) {
      // Nome crescente; minúsculas para "caneta" não ficar depois de "Zebra".
      produtos.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );
    } else {
      // ID decrescente: os mais recentes primeiro (como no Código 06).
      produtos.sort((a, b) => b.id.compareTo(a.id));
    }
    return produtos;
  }

  // Salva a lista completa após CREATE, UPDATE ou DELETE.
  Future<void> _salvarLista(List<Produto> produtos) async {
    final listaDeMapas = produtos.map((p) => p.toMap()).toList();
    await _prefs.setString(_chave, jsonEncode(listaDeMapas));
  }

  // CREATE: gera um ID simples, acrescenta o produto e regrava o JSON.
  Future<void> inserir(String nome, double preco, int quantidade) async {
    final produtos = await _lerTodos();
    final maiorId = produtos.fold<int>(
      0,
      (maior, p) => p.id > maior ? p.id : maior,
    );
    produtos.add(Produto(
      id: maiorId + 1,
      nome: nome,
      preco: preco,
      quantidade: quantidade,
    ));
    await _salvarLista(produtos);
  }

  // UPDATE: localiza o produto pelo ID e regrava a lista.
  Future<void> atualizar(Produto produto) async {
    final produtos = await _lerTodos();
    final indice = produtos.indexWhere((p) => p.id == produto.id);
    if (indice == -1) throw StateError('Produto não encontrado.');
    produtos[indice] = produto;
    await _salvarLista(produtos);
  }

  // DELETE: remove pelo ID e regrava a lista.
  Future<void> excluir(int id) async {
    final produtos = await _lerTodos();
    final quantidadeAnterior = produtos.length;
    produtos.removeWhere((p) => p.id == id);
    if (produtos.length == quantidadeAnterior) {
      throw StateError('Produto não encontrado.');
    }
    await _salvarLista(produtos);
  }
}
