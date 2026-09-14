// Fixação 3 — Lista de alunos
// Classe Aluno com nome e nota; nome no title e nota no subtitle.

import 'package:flutter/material.dart';

class Aluno {
  final String nome;
  final double nota;

  Aluno({
    required this.nome,
    required this.nota,
  });
}

class TelaAlunos extends StatelessWidget {
  const TelaAlunos({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Aluno> alunos = [
      Aluno(nome: 'Ana Souza', nota: 8.5),
      Aluno(nome: 'Bruno Lima', nota: 6.0),
      Aluno(nome: 'Carla Mendes', nota: 9.2),
      Aluno(nome: 'Diego Santos', nota: 4.7),
      Aluno(nome: 'Eduarda Alves', nota: 7.8),
      Aluno(nome: 'Felipe Costa', nota: 5.5),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Alunos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: alunos.length,
        itemBuilder: (context, index) {
          final Aluno aluno = alunos[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(
                Icons.person,
                size: 35,
              ),
              title: Text(
                aluno.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Nota: ${aluno.nota.toStringAsFixed(1)}'),
            ),
          );
        },
      ),
    );
  }
}
