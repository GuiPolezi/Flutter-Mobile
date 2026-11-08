# Dois CRUDs em Flutter: SharedPreferences e SQLite

Capítulo prático: persistência local. Prof. Clerivaldo Roccia.

**Aluno:** Guilherme Polezi Machado · **Turma:** Ciência da Computação

O mesmo cadastro de produtos (incluir, listar, editar e excluir) foi feito duas vezes, com a mesma
interface e dois mecanismos de armazenamento diferentes:

| Projeto | Armazenamento | Onde os dados ficam | Executar em |
|---|---|---|---|
| `crud_shared_preferences/` | `shared_preferences` (`SharedPreferencesAsync`), chave e valor | Uma chave `crud.produtos` com a lista inteira em **JSON** | **Chrome** (ou Android) |
| `crud_sqflite/` | `sqflite` + `path`, banco SQLite | Arquivo **`produtos.db`**, tabela `produtos` (uma linha por produto) | **Android** (emulador ou celular), **nunca Chrome** |

Pacotes usados: só os do capítulo (`shared_preferences`, `sqflite`, `path`), adicionados com
`flutter pub add`. Nenhum gerenciador de estado, rota nomeada ou pacote extra de teste.

## Como executar

**Projeto 1 (Chrome):**
```
cd crud_shared_preferences
flutter pub get
flutter run -d chrome
```
Para testar a persistência fechando e reabrindo (teste 8 da seção 4), use a **mesma origem**:
`flutter run -d web-server --web-port 8080` e abra `http://localhost:8080` no Chrome. O
`flutter run -d chrome` abre um perfil temporário a cada execução (ver `DUVIDAS.md`, item 4).

**Projeto 2 (Android):**
```
cd crud_sqflite
flutter pub get
flutter devices                 # anotar o ID do emulador/celular
flutter run -d emulator-5554    # ou o ID mostrado
```
Para reabrir com os dados, feche e abra o app **sem desinstalar** (desinstalar apaga o `produtos.db`).

**Nos dois:** `flutter analyze` (sem avisos) e `flutter test` (teste mínimo do formulário).

## Arquitetura (igual nos dois projetos)

```
lib/
  main.dart                      MaterialApp + tema (Códigos 09 e 14)
  models/produto.dart            Produto, toMap() e fromMap() (Código 04)
  data/produto_repository.dart   ÚNICO arquivo que conhece o armazenamento (Códigos 06 e 13)
  widgets/produto_dialog.dart    AlertDialog com Form para cadastrar e editar (Código 07)
  screens/produtos_page.dart     lista, estados, confirmação de exclusão (Código 08)
```

Os dois `ProdutoRepository` têm os **mesmos métodos públicos** (`listar`, `inserir`, `atualizar`,
`excluir`). Por isso `produto.dart`, `produto_dialog.dart` e `produtos_page.dart` são **cópias
idênticas** nos dois projetos da Etapa 4 até a A5 (conferido com `diff`). Só a A6 muda isso (abaixo).

## O que foi acrescentado nas atividades (seção 7)

| Atividade | P1 (SharedPreferences) | P2 (SQLite) |
|---|---|---|
| **A1** Quantidade em estoque | Campo novo no JSON; `fromMap` aceita JSON antigo sem a chave (`?? 0`) | `version: 2`; `onCreate` com a coluna + `onUpgrade` com `ALTER TABLE ... DEFAULT 0` |
| **A2** Validação de negócio | Preço > 0; quantidade inteira ≥ 0 (mesmo formulário nos dois) | igual |
| **A3** Ordenação nome × ID | `sort` + `compareTo` em Dart (nome em minúsculas) | `ORDER BY nome COLLATE NOCASE` / `id DESC` |
| **A4** Busca por nome | `where` + `toLowerCase().contains` em Dart | `WHERE nome LIKE ?` com `whereArgs` |
| **A5** Teste do identificador | ID = maior + 1 (reutiliza) | `AUTOINCREMENT` (não reutiliza) |
| **A6** Categorias | — (não se aplica, ver `RESPOSTAS.md`) | `version: 3`, tabela `categorias`, `REFERENCES`, `PRAGMA foreign_keys`, `LEFT JOIN`, `DropdownButtonFormField` |

Detalhes que valem para os dois:
- Ícone na AppBar alterna a ordem (A→Z / 1-2-3); a escolha fica numa variável de estado.
- Campo "Buscar por nome" acima da lista (`Column` + `Expanded`); mensagens
  `Nenhum produto cadastrado.` × `Nenhum produto encontrado.`
- Editar e excluir com a busca ativa usam o **objeto/ID** do produto, nunca a posição na lista
  filtrada (lição da falha do Ex. 8 do capítulo anterior).
- No P1, `inserir`/`atualizar`/`excluir` leem a lista completa com `_lerTodos()`. Se usassem
  `listar()` com filtro, os produtos fora do filtro seriam apagados ao regravar o JSON.

### Recursos usados nas atividades e onde já tinham aparecido

| Recurso | Usado em | Onde aparece no material |
|---|---|---|
| `TextFormField` + `validator`, `tryParse`, `isFinite` | A1, A2 | Código 07; Exercícios 21/08 (`int.tryParse`) |
| `TextEditingController` criado no `initState` e liberado no `dispose` | A1, A4 | Código 07; Exercícios 21/08 |
| `'R$ ... • Estoque: ...'` | A1 | Material 2 (exemplo de estoque) |
| `Column` + `Expanded` envolvendo a lista, `TextField` | A4 | Material 2 (seção 5) |
| `sort` + `compareTo`, `indexWhere`, `removeWhere`, `fold` | A3 | Código 06 |
| `where(...).toList()` em lista | A4 | Pedido no enunciado da atividade (filtrar a lista recuperada) |
| `db.query(where:, whereArgs:, orderBy:)` | A3, A4 | Código 13 e seção 3.7 |
| `IconButton` com `tooltip` | A3 | Código 08 (botões Editar/Excluir); aqui em `AppBar.actions` |
| `version` / `onUpgrade` (migração) | A1, A6 | Seção 3.6 ("estratégia de migração") e seção 5 |
| `rawQuery`, `LEFT JOIN`, `REFERENCES`, `PRAGMA foreign_keys`, `onConfigure` | A6 | Recursos novos pedidos pelo desafio (SQL padrão do SQLite, mesmo pacote `sqflite`) |
| `DropdownButtonFormField` | A6 | Widget do próprio Material, irmão do `TextFormField` dentro do `Form` |

### Divergência do Projeto 2 a partir da A6

A6 foi feita **só no SQLite**, em commit separado. Por isso, a partir dela, o P2 deixa de ter os três
arquivos idênticos ao P1:
- `models/produto.dart`: campos opcionais `categoriaId` / `categoriaNome`;
- `models/categoria.dart`: arquivo novo;
- `widgets/produto_dialog.dart`: recebe a lista de categorias e mostra o `DropdownButtonFormField`;
- `screens/produtos_page.dart`: carrega `listarCategorias()`, passa ao diálogo e mostra a categoria;
- `inserir(nome, preco, quantidade, categoriaId)` passa a ter 4 parâmetros.

Para ver os dois projetos ainda iguais, use o commit da A5 (`git log --oneline`).

### Histórico do esquema SQLite (`produtos.db`)

| Versão | Mudança | Como bancos antigos são atualizados (`onUpgrade`) |
|---|---|---|
| 1 | `produtos (id, nome, preco)` (Código 12) | — |
| 2 | + `quantidade INTEGER NOT NULL DEFAULT 0` (A1) | `if (oldVersion < 2) ALTER TABLE ... ADD COLUMN quantidade ...` |
| 3 | + tabela `categorias`; + `categoria_id REFERENCES categorias(id)` (A6) | `if (oldVersion < 3)` cria `categorias`, insere as iniciais e `ADD COLUMN categoria_id` |

O `onCreate` (instalação nova) já cria tudo na versão 3. A migração foi testada no emulador sobre um
banco criado na versão 1 (1 → 2 → 3); detalhes em `testes/atividades.md`.

## Comparação (seção 6 do PDF)

| Critério | SharedPreferences + JSON | SQLite + sqflite |
|---|---|---|
| Organização | Uma chave guarda uma lista serializada | Uma tabela guarda registros em linhas |
| Inclusão | Lê a lista, acrescenta, regrava o JSON | Executa `INSERT` / `db.insert` |
| Consulta | Lê e decodifica a lista inteira | Executa `SELECT` / `db.query` |
| Edição | Substitui na lista e regrava | Executa `UPDATE` por ID |
| Exclusão | Filtra a lista e regrava | Executa `DELETE` por ID |
| ID | Calculado no código (maior + 1) | Gerado pela tabela (`AUTOINCREMENT`) |
| Ordenar / buscar | Em Dart, depois de carregar tudo | No banco (`ORDER BY`, `WHERE ... LIKE ?`) |
| Mudança de estrutura | Só o `fromMap` precisa tolerar dados antigos | Migração de esquema (`version` + `onUpgrade`) |
| Relações (A6) | Não há tabelas nem `JOIN` | Chave estrangeira + `LEFT JOIN` |
| Evolução | Conveniente para poucos dados simples | Mais adequado para registros e relações |
| Plataformas deste capítulo | Web e Android, entre outras | Android, iOS e macOS |

## Limites

- Os dois projetos guardam **dados só locais**: não há servidor, login nem sincronização entre aparelhos.
- `shared_preferences` **não serve para dados críticos**. É indicado para preferências e poucos dados
  simples. Limpar os dados do site (Chrome) ou do app (Android) apaga tudo.
- O P1 regrava a lista inteira a cada operação; não é um banco transacional.
- O SQLite deste capítulo não roda no Chrome (exigiria outra configuração, fora do escopo).
- O preço usa `double`; um sistema real usaria uma representação monetária exata.

## Estrutura da entrega

```
capitulo_persistencia/
  crud_shared_preferences/     Projeto 1 (Códigos 03–10 + A1–A5)
  crud_sqflite/                Projeto 2 (Códigos 11–15 + A1–A6)
  testes/
    roteiro_secao4_shared_preferences.md
    roteiro_secao4_sqflite.md
    atividades.md              testes de A1–A6
  RESPOSTAS.md                 pergunta para reflexão (3.3) + explicações das atividades
  DUVIDAS.md                   registro de dúvidas/problemas
  USO_DE_IA.txt                declaração de uso de IA
```

Cada etapa e cada atividade tem um commit próprio (`git log --oneline`).

## Fontes

- **Material do professor:** `Capitulo_Flutter_Dois_CRUDs_Passo_a_Passo.pdf` e os zips
  `crud_shared_preferences.zip` / `crud_sqflite.zip` (código-base idêntico aos Códigos 04–14);
  `Flutter_Material_2_Listas_ListView_Cards.pdf` (lista, `Column` + `Expanded`, preço • estoque);
  `Flutter_Exercicios_Continuacao_Aula_21-08-2026.pdf` (`StatefulWidget`, controllers, `tryParse`).
- **Documentação citada no capítulo:** [Persist data with SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite),
  [shared_preferences](https://pub.dev/packages/shared_preferences), [sqflite](https://pub.dev/packages/sqflite).
- **IA:** ver `USO_DE_IA.txt`.
