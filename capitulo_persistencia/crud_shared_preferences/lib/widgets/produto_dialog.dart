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

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto?.nome ?? '');
    _precoController = TextEditingController(
      text: widget.produto == null
          ? ''
          : widget.produto!.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();
    final preco = double.parse(
      _precoController.text.trim().replaceAll(',', '.'),
    );

    // No cadastro, o repositório define o ID. Na edição, mantemos o ID.
    Navigator.of(context).pop(
      Produto(id: widget.produto?.id ?? 0, nome: nome, preco: preco),
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
