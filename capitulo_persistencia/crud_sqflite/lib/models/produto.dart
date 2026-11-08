class Produto {
  final int id;
  final String nome;
  final double preco;
  final int quantidade; // A1: quantidade em estoque.

  const Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  // Conversão do objeto Dart para um mapa (JSON ou SQLite).
  Map<String, Object?> toMap() => {
        'id': id,
        'nome': nome,
        'preco': preco,
        'quantidade': quantidade,
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
    );
  }
}
