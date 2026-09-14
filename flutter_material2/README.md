# Flutter — Material 2: Listas, ListView e Cards

Projeto com os exercícios do Material 2:

- `lib/acompanhados/` — Exercícios 1 a 5 (resolvidos em aula)
- `lib/fixacao/` — Exercícios de fixação 1 a 5 (desenvolvidos)

## Como executar pela primeira vez

Este pacote contém apenas o código-fonte. Para gerar os arquivos de
plataforma (android/, windows/, web/), rode UMA vez dentro da pasta:

```
flutter create .
flutter pub get
flutter run
```

O menu inicial dá acesso a todos os exercícios.

## Estrutura

- Cada exercício fica em um arquivo próprio, contendo apenas a tela
  (e suas classes de modelo, quando houver).
- O único ponto de entrada do app é `lib/main.dart`.
- Os imports no `main.dart` usam `show` para trazer apenas a classe da
  tela de cada arquivo, evitando conflito entre classes de modelo com o
  mesmo nome (ex.: `Produto` existe em três exercícios).
