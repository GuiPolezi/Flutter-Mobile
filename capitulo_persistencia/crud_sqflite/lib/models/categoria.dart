// A6: cada linha da tabela categorias vira um objeto Categoria.
class Categoria {
  final int id;
  final String nome;

  const Categoria({required this.id, required this.nome});

  // Conversão de mapa (linha do SQLite) para objeto Dart.
  factory Categoria.fromMap(Map<String, Object?> mapa) {
    return Categoria(
      id: (mapa['id'] as num).toInt(),
      nome: mapa['nome'] as String,
    );
  }
}
