// Material 2 — Exercício 2: List<String> e ListView.builder
// Modelo mental: lista de dados -> index -> itemBuilder -> widget.

import 'package:flutter/material.dart';

class TelaCursos extends StatelessWidget {
  const TelaCursos({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> cursos = [
      'Flutter',
      'Python',
      'Java',
      'Banco de Dados',
      'Redes',
      'Segurança da Informação',
      'Inteligência Artificial',
      'Desenvolvimento Web',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
      ),
      body: ListView.builder(
        itemCount: cursos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.school),
            title: Text(cursos[index]),
          );
        },
      ),
    );
  }
}
