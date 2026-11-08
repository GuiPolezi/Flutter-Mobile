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
