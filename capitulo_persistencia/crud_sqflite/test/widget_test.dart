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
    expect(find.text('Informe um preço válido (maior ou igual a zero).'), findsOneWidget);
  });
}
