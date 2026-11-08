class Produto {
  final int id;
  final String nome;
  final double preco;
  final int quantidade; // A1: quantidade em estoque.
  // A6 (só no Projeto 2): categoria do produto. Os dois podem ser null
  // porque produtos antigos (e os "Sem categoria") não têm categoria.
  final int? categoriaId; // coluna categoria_id da tabela produtos
  final String? categoriaNome; // vem do LEFT JOIN com a tabela categorias

  const Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
    this.categoriaId,
    this.categoriaNome,
  });

  // Conversão do objeto Dart para um mapa (JSON ou SQLite).
  // categoriaNome não entra: o nome fica só na tabela categorias.
  Map<String, Object?> toMap() => {
        'id': id,
        'nome': nome,
        'preco': preco,
        'quantidade': quantidade,
        'categoria_id': categoriaId,
      };

  // Conversão de mapa para objeto Dart.
  factory Produto.fromMap(Map<String, Object?> mapa) {
    return Produto(
      id: (mapa['id'] as num).toInt(),
      nome: mapa['nome'] as String,
      preco: (mapa['preco'] as num).toDouble(),
      // A1: um JSON gravado antes desta mudança não tem a chave 'quantidade'.
      // 'as num?' aceita null, '?.toInt()' só converte se houver valor
      // e '?? 0' usa zero quando a chave não existe.
      quantidade: (mapa['quantidade'] as num?)?.toInt() ?? 0,
      // A6: null quando o produto não tem categoria (LEFT JOIN sem par).
      categoriaId: (mapa['categoria_id'] as num?)?.toInt(),
      categoriaNome: mapa['categoria_nome'] as String?,
    );
  }
}
