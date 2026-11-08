# Respostas — rascunho em tópicos

> **Rascunho.** Os tópicos abaixo servem de roteiro. Reescrever com minhas palavras antes de entregar.

## Pergunta para reflexão (seção 3.3)

**"Como a mesma tela pode funcionar com dois mecanismos diferentes?"**

- A tela (`ProdutosPage`) só conhece a classe `ProdutoRepository` e os seus métodos públicos:
  `listar`, `inserir`, `atualizar`, `excluir`.
- Os dois projetos têm uma classe com o **mesmo nome** e as **mesmas assinaturas**. Só muda o que
  acontece *dentro* de cada método:
  - Projeto 1: lê/grava um texto JSON na chave `crud.produtos` (`SharedPreferencesAsync`).
  - Projeto 2: executa `INSERT`/`SELECT`/`UPDATE`/`DELETE` na tabela `produtos` do arquivo `produtos.db`.
- Os dois trabalham com o mesmo modelo `Produto`. O `toMap`/`fromMap` serve tanto para JSON quanto para
  as linhas do SQLite.
- Consequência: `produto.dart`, `produto_dialog.dart` e `produtos_page.dart` são **cópias idênticas**
  (conferido com `diff` até a A5). Trocar o armazenamento = trocar só `data/produto_repository.dart`.
- Ligação com a seção 1.5: "a interface não precisa conhecer os detalhes de como um produto é armazenado".
- Isso continua valendo nas atividades A1–A5: sempre que um repositório mudou de assinatura
  (`inserir(nome, preco, quantidade)`, `listar({ordenarPorNome, busca})`), o outro mudou igual.

## A1 — Quantidade em estoque: conversão no JSON e mudança de esquema no SQLite

- **JSON (Projeto 1):** o campo novo entra no `toMap` e no `fromMap`; não existe "esquema" para alterar.
- Problema: a chave `crud.produtos` pode ter JSON gravado **antes** da mudança, sem `"quantidade"`.
  `mapa['quantidade']` devolve `null` e `(null as num)` daria erro na hora de carregar a lista.
- Solução: `(mapa['quantidade'] as num?)?.toInt() ?? 0`
  - `as num?` aceita `null`;
  - `?.toInt()` só converte se não for `null`;
  - `?? 0` usa zero quando a chave não existe.
- **SQLite (Projeto 2):** a coluna precisa existir na tabela. A seção 3.6 avisa: mudar só o `onCreate`
  não atualiza bancos já criados, porque o `onCreate` só roda quando o arquivo `produtos.db` ainda não existe.
- Por isso há dois caminhos:
  - `onCreate` (instalação nova): já cria a tabela com `quantidade`.
  - `onUpgrade` (banco existente na versão 1): `ALTER TABLE produtos ADD COLUMN quantidade INTEGER NOT NULL DEFAULT 0`.
  - O `version` sobe de 1 para 2; o `sqflite` compara a versão gravada no arquivo com a do código e chama
    o `onUpgrade(db, oldVersion, newVersion)`.
  - `DEFAULT 0` é obrigatório: as linhas antigas precisam de um valor para uma coluna `NOT NULL`.

## A3 — Ordenar em Dart × `ORDER BY` do SQLite

- **Dart (Projeto 1):** carrega **toda** a lista e ordena na memória com `sort` + `compareTo`.
  - Nome: compara `a.nome.toLowerCase()` com `b.nome.toLowerCase()` (senão "caneta" ficaria depois de "Zebra").
  - ID decrescente: `b.id.compareTo(a.id)`.
- **SQLite (Projeto 2):** quem ordena é o banco, e o app já recebe as linhas na ordem certa.
  - `orderBy: 'nome COLLATE NOCASE ASC'` (o `COLLATE NOCASE` ignora maiúsculas/minúsculas) ou `'id DESC'`.
- Comparação:
  - Para poucos produtos, os dois são instantâneos.
  - Com muitos registros, o banco é mais adequado (pode usar índices e não precisa trazer tudo para a memória).
  - No Projeto 1 não há outra opção: o SharedPreferences não sabe consultar nem ordenar, só guarda o texto.
- Cuidado do Projeto 1: `inserir`/`atualizar`/`excluir` regravam a lista inteira. Se usassem a lista
  **filtrada** pela busca, apagariam os produtos que não apareceram no filtro. Por isso usam `_lerTodos()`.

## A4 — Busca: por que nunca concatenar o texto digitado no SQL

- Projeto 1: `where((p) => p.nome.toLowerCase().contains(termo))` sobre a lista já carregada.
- Projeto 2: `where: 'nome LIKE ?', whereArgs: ['%$busca%']`.
  - O `?` é preenchido pelo `sqflite` como **valor**, não como parte do comando (seção 3.7: "separa o valor
    da instrução SQL e evita concatenar entrada do usuário").
  - Se fosse `"nome LIKE '%$busca%'"`, digitar `'` quebraria o SQL; e um texto como `' OR 1=1 --`
    mudaria o comando (SQL injection).
  - O `%` antes e depois significa "qualquer coisa antes/depois" (contém).
- Diferença observada (para conferir): o `LIKE` do SQLite ignora maiúsculas só em letras sem acento
  (A–Z). O `toLowerCase()` do Dart também converte letras acentuadas (`Á` → `á`).
- Editar/excluir com a busca ativa usa o **objeto** (`produto.id`), não a posição na lista filtrada.
  Essa foi a lição da falha do Ex. 8 do capítulo anterior.

## A5 — Teste do identificador

Valores observados: ver `testes/atividades.md` (A5).

- **Projeto 1:** o ID é calculado pelo código: `maior ID existente + 1` (`fold` em `inserir`).
  Depois de apagar o 3, o maior é 2, então o quarto cadastro recebe **3 de novo** (ID reutilizado).
- **Projeto 2:** o ID é gerado pelo SQLite (`INTEGER PRIMARY KEY AUTOINCREMENT`). O banco guarda o maior
  ID já emitido (tabela interna `sqlite_sequence`) e **não reemite** IDs, então o quarto recebe **4**.
- O `AUTOINCREMENT` não promete uma sequência sem saltos (seção 3.7): só promete não repetir.
- Por que importa: se outro dado guardasse o ID 3 antigo (um pedido, por exemplo), no Projeto 1 ele
  passaria a apontar para o produto novo.

## A6 — Categorias: por que não é natural no SharedPreferences

- No SQLite: tabela `categorias` + coluna `categoria_id` em `produtos` com `REFERENCES categorias(id)`.
  - A listagem usa `LEFT JOIN` para trazer o nome da categoria junto do produto numa consulta só.
  - `LEFT` mantém os produtos sem categoria (antigos ou "Sem categoria").
  - `PRAGMA foreign_keys = ON` faz o banco recusar um `categoria_id` que não exista (integridade referencial).
- No SharedPreferences:
  - é só **chave → valor**: não existem tabelas, colunas, chaves estrangeiras nem `JOIN`;
  - daria para gravar uma segunda chave `crud.categorias` com outro JSON, mas o **código** teria que fazer
    tudo à mão: ler as duas listas, cruzar os IDs (o "JOIN"), impedir categoria inexistente e decidir o
    que fazer ao apagar uma categoria;
  - ou repetir o nome da categoria dentro de cada produto, e aí renomear uma categoria exigiria regravar
    todos os produtos (dado duplicado);
  - nada garante a consistência: o armazenamento aceita qualquer texto.
- Por isso a A6 foi feita só no Projeto 2. Aqui o modelo, o formulário e a tela do Projeto 2 passam a
  ser diferentes dos do Projeto 1 (divergência documentada no README).
