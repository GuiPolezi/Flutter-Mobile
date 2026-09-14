// Material 2 — Exercício 5: Cadastro dinâmico de produtos
// Lista como estado: add(), removeAt(), isEmpty e Expanded.
//
// Obs.: no PDF esta classe também se chama TelaProdutos; foi renomeada para
// TelaCadastroProdutos para não conflitar com a do Exercício 4 no projeto.

import 'package:flutter/material.dart';

class Produto {
  final String nome;
  final double preco;

  Produto({
    required this.nome,
    required this.preco,
  });
}

class TelaCadastroProdutos extends StatefulWidget {
  const TelaCadastroProdutos({super.key});

  @override
  State<TelaCadastroProdutos> createState() => _TelaCadastroProdutosState();
}

class _TelaCadastroProdutosState extends State<TelaCadastroProdutos> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();

  final List<Produto> produtos = [];

  void adicionarProduto() {
    final String nome = nomeController.text.trim();
    final double preco = double.tryParse(precoController.text) ?? 0;

    if (nome.isEmpty || preco <= 0) {
      return;
    }

    setState(() {
      produtos.add(
        Produto(
          nome: nome,
          preco: preco,
        ),
      );
    });

    nomeController.clear();
    precoController.clear();
  }

  void removerProduto(int index) {
    setState(() {
      produtos.removeAt(index);
    });
  }

  void limparCampos() {
    nomeController.clear();
    precoController.clear();
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produtos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preço',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: adicionarProduto,
                  child: const Text('Adicionar'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: limparCampos,
                  child: const Text('Limpar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: produtos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum produto cadastrado.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: produtos.length,
                      itemBuilder: (context, index) {
                        final Produto produto = produtos[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.inventory_2,
                            ),
                            title: Text(produto.nome),
                            subtitle: Text(
                              'R\$ ${produto.preco.toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                              ),
                              onPressed: () {
                                removerProduto(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
