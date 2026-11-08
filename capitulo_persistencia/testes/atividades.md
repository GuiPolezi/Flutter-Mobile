# Testes das atividades da seção 7

> No PDF as atividades aparecem numeradas de 4 a 9 (erro de formatação). Aqui: A1 a A6.
> As colunas **Observado** e **Conferência manual** são preenchidas pelo aluno depois de executar.
> P1 = `crud_shared_preferences` (Chrome) · P2 = `crud_sqflite` (Android).

## A1 — Quantidade em estoque

| # | Projeto | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| A1.1 | P1 e P2 | Novo produto → `Régua`, `4,50`, quantidade `10` → Salvar | Lista mostra `R$ 4,50 • Estoque: 10` | | |
| A1.2 | P1 e P2 | Editar a Régua → quantidade `7` → Salvar | `Estoque: 7`; o ID da Régua não muda | | |
| A1.3 | P1 e P2 | Novo produto → quantidade `abc` (ou vazio) → Salvar | "Informe a quantidade (número inteiro)."; diálogo continua aberto | | |
| A1.4 | P1 e P2 | Novo produto → quantidade `2,5` → Salvar | Mesma mensagem: `int.tryParse` não aceita decimal | | |
| A1.5 | P1 | **JSON antigo:** com produtos gravados *antes* da A1 (versão do commit da Etapa 3), abrir a versão nova na mesma origem | Produtos antigos aparecem com `Estoque: 0` (chave ausente → `?? 0`), sem "Falha ao carregar" | | |
| A1.6 | P2 | **Migração v1 → v2:** com produtos gravados pela versão 1 (Etapa 4), executar a versão nova **sem desinstalar** | Produtos antigos aparecem com `Estoque: 0` (`onUpgrade` + `DEFAULT 0`) | | |
| A1.7 | P2 | **Instalação nova:** desinstalar o app (apaga `produtos.db`) e executar de novo; cadastrar um produto com quantidade `3` | Funciona igual (`onCreate` já cria a coluna `quantidade`) | | |

Como voltar à versão antiga para os testes A1.5/A1.6: `git checkout <commit da etapa> -- <projeto>/lib`,
executar e cadastrar; depois `git checkout HEAD -- <projeto>/lib` e executar de novo **sem desinstalar**
(no Chrome, na mesma origem: `flutter run -d web-server --web-port 8080`).

## A2 — Validação de negócio

| # | Projeto | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| A2.1 | P1 e P2 | Novo produto → preço `0` → Salvar | "O preço deve ser maior que zero." | | |
| A2.2 | P1 e P2 | Novo produto → preço `-5` → Salvar | "O preço deve ser maior que zero." | | |
| A2.3 | P1 e P2 | Novo produto → preço `0,01` e quantidade `0` → Salvar | Aceito: o preço é maior que zero e estoque zero é permitido | | |
| A2.4 | P1 e P2 | Novo produto → quantidade `-1` → Salvar | "A quantidade não pode ser negativa." | | |
| A2.5 | P1 e P2 | Novo produto → preço `abc` → Salvar | "Informe um preço válido (ex.: 19,90)." | | |
| A2.6 | P1 e P2 | Editar um produto antigo e salvar sem mudar nada | Salva normalmente (as regras valem também na edição) | | |

Teste automático: `flutter test` (grupo "A2: preço zero e quantidade negativa são rejeitados").

## A3 — Ordenação

Ícone na AppBar: **A→Z** (`sort_by_alpha`, tooltip "Ordenar por nome") quando a lista está por ID e
**1-2-3** (`format_list_numbered`, tooltip "Ordenar por ID") quando está por nome.

| # | Projeto | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| A3.1 | P1 e P2 | Cadastrar, nesta ordem, `caneta`, `Borracha`, `Apontador` (preço 1, qtd 1) | Lista por ID decrescente: Apontador, Borracha, caneta | | |
| A3.2 | P1 e P2 | Tocar no ícone A→Z | Apontador, Borracha, caneta (o "c" minúsculo **não** vai para o fim) | | |
| A3.3 | P1 e P2 | Com a lista por nome, cadastrar `Agenda` | Agenda aparece no topo (a ordem escolhida continua valendo) | | |
| A3.4 | P1 e P2 | Com a lista por nome, editar e excluir um item | Só o item escolhido muda; nenhum outro produto some | | |
| A3.5 | P1 e P2 | Tocar no ícone 1-2-3 | Volta para ID decrescente | | |
| A3.6 | P1 e P2 | Fechar e reabrir o app | Volta para ID decrescente (a escolha fica só em memória, numa variável de estado) | | |

## A4 — Busca por nome

| # | Projeto | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| A4.1 | P1 e P2 | Lista vazia (nada cadastrado), campo de busca vazio | "Nenhum produto cadastrado." | | |
| A4.2 | P1 e P2 | Com Caderno e Caneta cadastrados, digitar `CAN` | Só a Caneta aparece (ignora maiúsculas) | | |
| A4.3 | P1 e P2 | Digitar `xyz` | "Nenhum produto encontrado." | | |
| A4.4 | P1 e P2 | Apagar o texto da busca | Todos os produtos voltam | | |
| A4.5 | P2 | Digitar `x' OR 1=1 --` | "Nenhum produto encontrado.", sem erro: o texto vai em `whereArgs` como valor, não como SQL | | |
| A4.6 | P1 e P2 | Busca + ordenação: com a busca `ca` ativa, alternar A→Z / 1-2-3 | O filtro continua aplicado nas duas ordens | | |
| A4.7 | P1 e P2 | Acentos: cadastrar `Álbum`, buscar `álb` | P1: encontra (`toLowerCase` converte `Á`). P2: **pode não encontrar**, porque o `LIKE` do SQLite só ignora maiúsculas em A–Z. Anotar o que acontecer. | | |

### Lição do capítulo anterior (falha do Ex. 8): editar/excluir com a busca ativa

A tela passa o **objeto** `produto` para `_abrirFormulario(produto)` e `_excluir(produto)`, e o
repositório usa `produto.id`. O `indice` do `itemBuilder` (posição na lista **filtrada**) não é usado.

| # | Projeto | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| A4.8 | P1 e P2 | Cadastrar `Mouse`, `Teclado`, `Monitor` (nessa ordem). Buscar `teclado` (aparece na posição 0 da lista filtrada) → Editar | O formulário abre com **Teclado** (não com Monitor, que é o 1º da lista completa por ID decrescente) | | |
| A4.9 | P1 e P2 | Ainda com a busca `teclado`: mudar a quantidade para `9` → Salvar → apagar a busca | Só o Teclado tem `Estoque: 9`; Mouse e Monitor não mudaram | | |
| A4.10 | P1 e P2 | Buscar `mouse` → Excluir | O diálogo pergunta "Deseja excluir \"Mouse\"?"; ao confirmar, só o Mouse some | | |
| A4.11 | P1 | Com a busca `mouse` ativa, cadastrar `Caneca` → apagar a busca | Todos os produtos continuam gravados (as escritas usam `_lerTodos()`, não a lista filtrada) | | |

## A5 — Teste do identificador

Começar com a lista **vazia** nos dois projetos (P1: limpar os dados do site ou excluir todos os produtos;
P2: excluir todos ou desinstalar antes). Atenção: no P2, excluir todos **não** zera o contador do
`AUTOINCREMENT`. Para começar do 1, desinstale o app.

Procedimento: cadastrar `Item A`, `Item B`, `Item C` (preço 1, quantidade 1) → excluir o **terceiro**
(`Item C`) → cadastrar `Item D`.

| Passo | P1 esperado | P1 observado | P2 esperado | P2 observado |
|---|---|---|---|---|
| ID do Item A | 1 | | 1 | |
| ID do Item B | 2 | | 2 | |
| ID do Item C | 3 | | 3 | |
| Excluir Item C | some | | some | |
| **ID do Item D** | **3** (maior restante = 2; `2 + 1`) | | **4** (`AUTOINCREMENT` não reemite o 3) | |

Explicação: `RESPOSTAS.md`, seção A5.

Conferência manual: ______

## A6 — Desafio: categorias (somente P2)

Esquema versão 3: tabela `categorias (id, nome UNIQUE)` com Papelaria, Escritório e Informática;
coluna `produtos.categoria_id REFERENCES categorias(id)`; `PRAGMA foreign_keys = ON` no `onConfigure`.

| # | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|
| A6.1 | **Migração v2 → v3:** com produtos gravados pela versão da A5, executar a versão da A6 **sem desinstalar** | Produtos antigos continuam com preço e estoque e aparecem com "Sem categoria" | | |
| A6.2 | **Migração v1 → v3:** com um banco da Etapa 4 (versão 1), executar a versão da A6 | O `onUpgrade` aplica os dois passos: `Estoque: 0` e "Sem categoria" | | |
| A6.3 | **Instalação nova:** desinstalar e executar; Novo produto → `Mouse`, `50`, `2`, categoria **Informática** | Lista mostra `Mouse` / `R$ 50,00 • Estoque: 2` / `Informática` | | |
| A6.4 | Abrir o dropdown "Categoria" | Opções: Sem categoria, Escritório, Informática, Papelaria (nome crescente) | | |
| A6.5 | Editar um produto "Sem categoria" → escolher Papelaria → Salvar | A lista passa a mostrar "Papelaria" (nome vindo do `LEFT JOIN`) | | |
| A6.6 | Editar um produto com categoria → o dropdown já abre com a categoria atual | Mostra a categoria gravada (`initialValue`) | | |
| A6.7 | Editar → escolher "Sem categoria" → Salvar | Volta para "Sem categoria" (`categoria_id` = NULL) | | |
| A6.8 | Busca e ordenação continuam funcionando com a categoria | Mesmos resultados de A3/A4, agora com a linha da categoria | | |

### Divergência entre os projetos a partir da A6

`diff` dos três arquivos que eram iguais até a A5 (commit `6db9f63`):

- `models/produto.dart`: P2 tem `categoriaId` e `categoriaNome` (opcionais) e `categoria_id` no `toMap`.
- `widgets/produto_dialog.dart`: P2 recebe `categorias` e tem o `DropdownButtonFormField`.
- `screens/produtos_page.dart`: P2 carrega `listarCategorias()`, passa a lista ao diálogo, envia
  `categoriaId` ao `inserir` e mostra a categoria (`isThreeLine`).
- Novo arquivo só no P2: `models/categoria.dart`.
