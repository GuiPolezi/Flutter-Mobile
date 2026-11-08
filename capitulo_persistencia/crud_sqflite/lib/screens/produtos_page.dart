import 'package:flutter/material.dart';
import '../data/produto_repository.dart';
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
  bool _carregando = true;
  bool _processando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // READ: obtém os produtos armazenados e atualiza a tela.
  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final produtos = await _repositorio.listar();
      if (!mounted) return;
      setState(() {
        _produtos = produtos;
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
      builder: (_) => ProdutoDialog(produto: produtoOriginal),
    );
    if (produto == null || !mounted) return;

    setState(() => _processando = true);
    try {
      if (produtoOriginal == null) {
        await _repositorio.inserir(
          produto.nome,
          produto.preco,
          produto.quantidade,
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
      appBar: AppBar(title: Text(widget.titulo)),
      body: _carregando
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
                  ? const Center(child: Text('Nenhum produto cadastrado.'))
                  : ListView.separated(
                      itemCount: _produtos.length,
                      // Dart 3.7+: '_' pode se repetir; o Código 08 usava (_, __).
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, indice) {
                        final produto = _produtos[indice];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${produto.id}')),
                          title: Text(produto.nome),
                          // A1: preço e estoque na mesma linha, como no Material 2.
                          subtitle: Text(
                            'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}'
                            ' • Estoque: ${produto.quantidade}',
                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _processando ? null : () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}
