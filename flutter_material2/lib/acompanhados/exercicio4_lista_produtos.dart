// Material 2 — Exercício 4: Lista de objetos com List<Produto>
// Cada posição da lista contém um objeto completo do domínio da aplicação.

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

class TelaProdutos extends StatelessWidget {
  const TelaProdutos({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Produto> produtos = [
      Produto(
        nome: 'Teclado',
        preco: 120.00,
        quantidade: 5,
      ),
      Produto(
        nome: 'Mouse',
        preco: 80.00,
        quantidade: 10,
      ),
      Produto(
        nome: 'Monitor',
        preco: 950.00,
        quantidade: 3,
      ),
      Produto(
        nome: 'Headset',
        preco: 250.00,
        quantidade: 7,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final Produto produto = produtos[index];

          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.inventory_2,
                size: 35,
              ),
              title: Text(
                produto.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'R\$ ${produto.preco.toStringAsFixed(2)} '
                '• Estoque: ${produto.quantidade}',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
            ),
          );
        },
      ),
    );
  }
}
