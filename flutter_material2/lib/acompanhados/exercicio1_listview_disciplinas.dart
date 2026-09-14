// Material 2 — Exercício 1: Primeira lista com ListView
// ListView(children: [...]) lembra uma Column, mas já possui rolagem.
// Divider() cria a linha divisória entre os itens.

import 'package:flutter/material.dart';

class TelaDisciplinas extends StatelessWidget {
  const TelaDisciplinas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Disciplinas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Programação',
            style: TextStyle(fontSize: 20),
          ),
          Divider(),
          Text(
            'Banco de Dados',
            style: TextStyle(fontSize: 20),
          ),
          Divider(),
          Text(
            'Redes de Computadores',
            style: TextStyle(fontSize: 20),
          ),
          Divider(),
          Text(
            'Flutter',
            style: TextStyle(fontSize: 20),
          ),
          Divider(),
          Text(
            'Segurança da Informação',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
