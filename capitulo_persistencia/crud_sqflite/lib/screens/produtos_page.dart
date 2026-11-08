import 'package:flutter/material.dart';
import '../data/produto_repository.dart';
import '../models/categoria.dart';
import '../models/produto.dart';
import '../widgets/produto_dialog.dart';

class ProdutosPage extends StatefulWidget {
  final String titulo;

  const ProdutosPage({super.key, required this.titulo});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final ProdutoRepository _repositorio = ProdutoRepository();
  List<Produto> _produtos = [];
  List<Categoria> _categorias = []; // A6: opções do formulário.
  bool _carregando = true;
  bool _processando = false;
  String? _erro;
  bool _ordenarPorNome = false; // A3: false = ID decrescente; true = nome crescente.
  late final TextEditingController _buscaController; // A4: texto da busca.

  @override
  void initState() {
    super.initState();
    // O controller é criado antes de _carregar(), que lê o texto da busca.
    _buscaController = TextEditingController();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // READ: obtém os produtos armazenados e atualiza a tela.
  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final produtos = await _repositorio.listar(
        ordenarPorNome: _ordenarPorNome,
        busca: _buscaController.text,
      );
      // A6: as categorias também vêm do banco.
      final categorias = await _repositorio.listarCategorias();
      if (!mounted) return;
      setState(() {
        _produtos = produtos;
        _categorias = categorias;
        _erro = null;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erro = 'Falha ao carregar: $erro');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // CREATE e UPDATE: o mesmo formulário serve para cadastrar e editar.
  Future<void> _abrirFormulario([Produto? produtoOriginal]) async {
    if (_processando) return;

    final produto = await showDialog<Produto>(
      context: context,
      builder: (_) => ProdutoDialog(
        produto: produtoOriginal,
        categorias: _categorias,
      ),
    );
    if (produto == null || !mounted) return;

    setState(() => _processando = true);
    try {
      if (produtoOriginal == null) {
        await _repositorio.inserir(
          produto.nome,
          produto.preco,
          produto.quantidade,
          produto.categoriaId,
        );
      } else {
        await _repositorio.atualizar(produto);
      }
      await _carregar();
      if (!mounted) return;
      _mensagem(produtoOriginal == null ? 'Produto cadastrado.' : 'Produto atualizado.');
    } catch (erro) {
      if (mounted) _mensagem('Erro ao salvar: $erro');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  // DELETE: solicita confirmação antes de excluir.
  Future<void> _excluir(Produto produto) async {
    if (_processando) return;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('Deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() => _processando = true);
    try {
      await _repositorio.excluir(produto.id);
      await _carregar();
      if (mounted) _mensagem('Produto excluído.');
    } catch (erro) {
      if (mounted) _mensagem('Erro ao excluir: $erro');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        actions: [
          // A3: alterna a ordenação e pede a lista de novo ao repositório.
          // O ícone e o tooltip mostram o que acontece ao tocar.
          IconButton(
            tooltip: _ordenarPorNome ? 'Ordenar por ID' : 'Ordenar por nome',
            onPressed: _processando
                ? null
                : () {
                    setState(() => _ordenarPorNome = !_ordenarPorNome);
                    _carregar();
                  },
            icon: Icon(
              _ordenarPorNome ? Icons.format_list_numbered : Icons.sort_by_alpha,
            ),
          ),
        ],
      ),
      // A4: Column com o campo de busca em cima e a lista ocupando o resto
      // da tela com Expanded (como no Material 2).
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // A cada letra digitada, o repositório é consultado de novo.
              onChanged: (_) => _carregar(),
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_erro!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _carregar,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : _produtos.isEmpty
                        // A4: mensagens diferentes para "nada cadastrado" e "busca sem resultado".
                        ? Center(
                            child: Text(
                              _buscaController.text.trim().isEmpty
                                  ? 'Nenhum produto cadastrado.'
                                  : 'Nenhum produto encontrado.',
                            ),
                          )
                        : ListView.separated(
                            itemCount: _produtos.length,
                            // Dart 3.7+: '_' pode se repetir; o Código 08 usava (_, __).
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, indice) {
                              final produto = _produtos[indice];
                              // A4: editar e excluir recebem o próprio objeto
                              // (e o repositório usa produto.id), nunca o
                              // 'indice', que é a posição na lista filtrada.
                              return ListTile(
                                leading: CircleAvatar(child: Text('${produto.id}')),
                                title: Text(produto.nome),
                                // A1: preço e estoque na mesma linha, como no Material 2.
                                subtitle: Text(
                                  'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}'
                                  ' • Estoque: ${produto.quantidade}'
                                  // A6: nome trazido pelo LEFT JOIN.
                                  '\n${produto.categoriaNome ?? 'Sem categoria'}',
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar',
                                      onPressed: _processando
                                          ? null
                                          : () => _abrirFormulario(produto),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir',
                                      onPressed: _processando
                                          ? null
                                          : () => _excluir(produto),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _processando ? null : () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}
