// Fixação 2 — Catálogo de livros
// Classe Livro com título e autor; List<Livro> apresentada em Cards
// (mesmo padrão da List<Produto> do Exercício 4).

import 'package:flutter/material.dart';

class Livro {
  final String titulo;
  final String autor;

  Livro({
    required this.titulo,
    required this.autor,
  });
}

class TelaLivros extends StatelessWidget {
  const TelaLivros({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Livro> livros = [
      Livro(
        titulo: 'Dom Casmurro',
        autor: 'Machado de Assis',
      ),
      Livro(
        titulo: 'O Cortiço',
        autor: 'Aluísio Azevedo',
      ),
      Livro(
        titulo: 'Vidas Secas',
        autor: 'Graciliano Ramos',
      ),
      Livro(
        titulo: 'Grande Sertão: Veredas',
        autor: 'João Guimarães Rosa',
      ),
      Livro(
        titulo: 'A Hora da Estrela',
        autor: 'Clarice Lispector',
      ),
      Livro(
        titulo: 'Iracema',
        autor: 'José de Alencar',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Livros'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: livros.length,
        itemBuilder: (context, index) {
          final Livro livro = livros[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(
                Icons.menu_book,
                size: 35,
              ),
              title: Text(
                livro.titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(livro.autor),
            ),
          );
        },
      ),
    );
  }
}
