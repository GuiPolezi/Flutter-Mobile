// Fixação 5 — Estoque simples
// Produto com nome, preço e quantidade; cadastro dinâmico em Cards e
// mensagem quando a lista está vazia. Integra tudo do material:
// classe de modelo + lista como estado + add()/removeAt() + Expanded.

import 'package:flutter/material.dart';

class Produto {
  final String nome;
  final double preco;
  final int quantidade;

  Produto({
    required this.nome,
    required this.preco,
    required this.quantidade,
  });
}

class TelaEstoqueProdutos extends StatefulWidget {
  const TelaEstoqueProdutos({super.key});

  @override
  State<TelaEstoqueProdutos> createState() => _TelaEstoqueProdutosState();
}

class _TelaEstoqueProdutosState extends State<TelaEstoqueProdutos> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();

  final List<Produto> produtos = [];

  void adicionarProduto() {
    final String nome = nomeController.text.trim();
    final double preco = double.tryParse(precoController.text) ?? 0;
    final int quantidade = int.tryParse(quantidadeController.text) ?? 0;

    // Validação: nome preenchido, preço e quantidade positivos
    if (nome.isEmpty || preco <= 0 || quantidade <= 0) {
      return;
    }

    setState(() {
      produtos.add(
        Produto(
          nome: nome,
          preco: preco,
          quantidade: quantidade,
        ),
      );
    });

    nomeController.clear();
    precoController.clear();
    quantidadeController.clear();
  }

  void removerProduto(int index) {
    setState(() {
      produtos.removeAt(index);
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque de Produtos'),
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
            // Preço e quantidade lado a lado, cada um ocupando metade da Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: precoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: adicionarProduto,
              child: const Text('Cadastrar produto'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: produtos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum produto no estoque.',
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
                            title: Text(
                              produto.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'R\$ ${produto.preco.toStringAsFixed(2)} '
                              '• Quantidade: ${produto.quantidade}',
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
