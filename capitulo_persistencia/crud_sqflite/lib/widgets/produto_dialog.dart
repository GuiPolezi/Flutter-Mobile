import 'package:flutter/material.dart';
import '../models/produto.dart';

class ProdutoDialog extends StatefulWidget {
  final Produto? produto;

  const ProdutoDialog({super.key, this.produto});

  @override
  State<ProdutoDialog> createState() => _ProdutoDialogState();
}

class _ProdutoDialogState extends State<ProdutoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _quantidadeController; // A1

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto?.nome ?? '');
    _precoController = TextEditingController(
      text: widget.produto == null
          ? ''
          : widget.produto!.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
    // A1: na edição, o campo já vem com a quantidade atual.
    _quantidadeController = TextEditingController(
      text: widget.produto == null ? '' : '${widget.produto!.quantidade}',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();
    final preco = double.parse(
      _precoController.text.trim().replaceAll(',', '.'),
    );
    // O validator já garantiu que o texto é um inteiro válido.
    final quantidade = int.parse(_quantidadeController.text.trim());

    // No cadastro, o repositório define o ID. Na edição, mantemos o ID.
    Navigator.of(context).pop(
      Produto(
        id: widget.produto?.id ?? 0,
        nome: nome,
        preco: preco,
        quantidade: quantidade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.produto == null ? 'Cadastrar produto' : 'Editar produto'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome do produto',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Preço (ex.: 19,90)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final preco = double.tryParse(
                      (valor ?? '').trim().replaceAll(',', '.'),
                    );
                    if (preco == null || !preco.isFinite || preco < 0) {
                      return 'Informe um preço válido (maior ou igual a zero).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // A1: quantidade em estoque, só números inteiros.
                TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade em estoque',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final quantidade = int.tryParse((valor ?? '').trim());
                    if (quantidade == null) {
                      return 'Informe a quantidade (número inteiro).';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: const Text('Salvar')),
      ],
    );
  }
}
