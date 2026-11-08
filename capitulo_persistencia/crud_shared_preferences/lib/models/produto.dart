class Produto {
  final int id;
  final String nome;
  final double preco;

  const Produto({required this.id, required this.nome, required this.preco});

  // Conversão do objeto Dart para um mapa (JSON ou SQLite).
  Map<String, Object?> toMap() => {
        'id': id,
        'nome': nome,
        'preco': preco,
      };

  // Conversão de mapa para objeto Dart.
  factory Produto.fromMap(Map<String, Object?> mapa) {
    return Produto(
      id: (mapa['id'] as num).toInt(),
      nome: mapa['nome'] as String,
      preco: (mapa['preco'] as num).toDouble(),
    );
  }
}
