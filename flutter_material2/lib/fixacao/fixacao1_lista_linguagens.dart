// Fixação 1 — Lista de linguagens
// List<String> com pelo menos oito linguagens, apresentada com
// ListView.builder e ListTile (mesmo padrão do Exercício 2).

import 'package:flutter/material.dart';

class TelaLinguagens extends StatelessWidget {
  const TelaLinguagens({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> linguagens = [
      'Dart',
      'Python',
      'Java',
      'C#',
      'JavaScript',
      'TypeScript',
      'Kotlin',
      'Swift',
      'Go',
      'PHP',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linguagens de Programação'),
      ),
      body: ListView.builder(
        itemCount: linguagens.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.code),
            title: Text(linguagens[index]),
          );
        },
      ),
    );
  }
}
