// Teste mínimo do formulário (ProdutoDialog), usando só o flutter_test.
// O app inteiro não é testado aqui porque o sqflite precisa
// da plataforma real (Android). O teste principal do CRUD é o roteiro
// manual da seção 4 (pasta testes/).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crud_sqflite/widgets/produto_dialog.dart';

void main() {
  testWidgets('Formulário impede salvar com campos vazios', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProdutoDialog())),
    );

    // Sem produto, o diálogo abre em modo de cadastro.
    expect(find.text('Cadastrar produto'), findsOneWidget);

    // Tocar em Salvar sem preencher mostra as mensagens dos validators.
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(find.text('Informe um preço válido (ex.: 19,90).'), findsOneWidget);
    expect(find.text('Informe a quantidade (número inteiro).'), findsOneWidget);
  });

  testWidgets('A2: preço zero e quantidade negativa são rejeitados', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProdutoDialog())),
    );

    // Os três campos aparecem na ordem: nome, preço, quantidade.
    await tester.enterText(find.byType(TextFormField).at(0), 'Caderno');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.enterText(find.byType(TextFormField).at(2), '-1');
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('O preço deve ser maior que zero.'), findsOneWidget);
    expect(find.text('A quantidade não pode ser negativa.'), findsOneWidget);
  });
}
