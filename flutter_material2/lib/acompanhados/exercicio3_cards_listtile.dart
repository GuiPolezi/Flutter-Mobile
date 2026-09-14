// Material 2 — Exercício 3: Cards com Card e ListTile
// leading | title / subtitle | trailing
//
// Obs.: no PDF esta classe também se chama TelaCursos; foi renomeada para
// TelaCursosCards para não conflitar com a do Exercício 2 no mesmo projeto.

import 'package:flutter/material.dart';

class TelaCursosCards extends StatelessWidget {
  const TelaCursosCards({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> cursos = [
      'Flutter',
      'Python',
      'Java',
      'Banco de Dados',
      'Redes de Computadores',
      'Segurança da Informação',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos Disponíveis'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: cursos.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(
                Icons.computer,
                size: 35,
              ),
              title: Text(
                cursos[index],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Curso ${index + 1}'),
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
