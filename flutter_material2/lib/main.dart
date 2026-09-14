// main.dart — Único ponto de entrada do projeto.
// Menu do Material 2; cada botão abre a tela do exercício com
// Navigator.push() (o botão "voltar" do AppBar retorna ao menu).
//
// Os imports usam "show" para trazer apenas a classe da tela de cada
// arquivo, evitando conflito entre classes de modelo repetidas
// (ex.: Produto existe no Ex. 4, no Ex. 5 e na Fixação 5).

import 'package:flutter/material.dart';

// Exercícios acompanhados
import 'acompanhados/exercicio1_listview_disciplinas.dart'
    show TelaDisciplinas;
import 'acompanhados/exercicio2_listview_builder.dart' show TelaCursos;
import 'acompanhados/exercicio3_cards_listtile.dart' show TelaCursosCards;
import 'acompanhados/exercicio4_lista_produtos.dart' show TelaProdutos;
import 'acompanhados/exercicio5_cadastro_dinamico.dart'
    show TelaCadastroProdutos;

// Exercícios de fixação
import 'fixacao/fixacao1_lista_linguagens.dart' show TelaLinguagens;
import 'fixacao/fixacao2_catalogo_livros.dart' show TelaLivros;
import 'fixacao/fixacao3_lista_alunos.dart' show TelaAlunos;
import 'fixacao/fixacao4_cadastro_tarefas.dart' show TelaTarefas;
import 'fixacao/fixacao5_estoque_produtos.dart' show TelaEstoqueProdutos;

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaMenu(),
    );
  }
}

class TelaMenu extends StatelessWidget {
  const TelaMenu({super.key});

  // Abre a tela recebida por parâmetro
  void abrir(BuildContext context, Widget tela) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => tela),
    );
  }

  // Widget auxiliar: título de seção do menu
  Widget titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget auxiliar: botão de exercício
  Widget botao(BuildContext context, String rotulo, Widget tela) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: () => abrir(context, tela),
        child: Text(rotulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 2 — Listas e Cards'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          titulo('Exercícios acompanhados'),
          botao(context, 'Ex. 1 — ListView (Disciplinas)', const TelaDisciplinas()),
          botao(context, 'Ex. 2 — ListView.builder (Cursos)', const TelaCursos()),
          botao(context, 'Ex. 3 — Cards + ListTile', const TelaCursosCards()),
          botao(context, 'Ex. 4 — List<Produto>', const TelaProdutos()),
          botao(context, 'Ex. 5 — Cadastro dinâmico', const TelaCadastroProdutos()),
          titulo('Exercícios de fixação'),
          botao(context, 'Fix. 1 — Lista de Linguagens', const TelaLinguagens()),
          botao(context, 'Fix. 2 — Catálogo de Livros', const TelaLivros()),
          botao(context, 'Fix. 3 — Lista de Alunos', const TelaAlunos()),
          botao(context, 'Fix. 4 — Cadastro de Tarefas', const TelaTarefas()),
          botao(context, 'Fix. 5 — Estoque de Produtos', const TelaEstoqueProdutos()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
