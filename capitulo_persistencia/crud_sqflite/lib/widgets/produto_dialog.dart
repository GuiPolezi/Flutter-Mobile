import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/produto.dart';

class ProdutoDialog extends StatefulWidget {
  final Produto? produto;
  // A6: categorias que aparecem no DropdownButtonFormField.
  // A tela busca a lista no repositório; o diálogo só a exibe.
  final List<Categoria> categorias;

  const ProdutoDialog({super.key, this.produto, this.categorias = const []});

  @override
  State<ProdutoDialog> createState() => _ProdutoDialogState();
}

class _ProdutoDialogState extends State<ProdutoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _quantidadeController; // A1
  int? _categoriaId; // A6: null = "Sem categoria".

  @override
  void initState() {
    super.initState();
    _categoriaId = widget.produto?.categoriaId;
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
        categoriaId: _categoriaId,
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
                    if (preco == null || !preco.isFinite) {
                      return 'Informe um preço válido (ex.: 19,90).';
                    }
                    // A2: regra de negócio, o preço precisa ser maior que zero.
                    if (preco <= 0) {
                      return 'O preço deve ser maior que zero.';
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
                    // A2: regra de negócio, não existe estoque negativo.
                    if (quantidade < 0) {
                      return 'A quantidade não pode ser negativa.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // A6: escolha da categoria (widget do próprio Material).
                // O valor de cada item é o ID da categoria; null = sem categoria.
                DropdownButtonFormField<int?>(
                  initialValue: _categoriaId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Sem categoria'),
                    ),
                    for (final categoria in widget.categorias)
                      DropdownMenuItem<int?>(
                        value: categoria.id,
                        child: Text(categoria.nome),
                      ),
                  ],
                  onChanged: (valor) => setState(() => _categoriaId = valor),
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
