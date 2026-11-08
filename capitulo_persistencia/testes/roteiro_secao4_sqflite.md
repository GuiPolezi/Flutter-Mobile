# Roteiro da seção 4 — `crud_sqflite`

> Testes da seção 4 do PDF ("Testes orientados"), feitos no app em execução.
> As colunas **Observado** e **Conferência manual** são preenchidas pelo aluno depois de executar.

## Como executar (Código 15)

```
cd crud_sqflite
flutter pub get
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Use **Android**: emulador (`emulator-5554`, por exemplo) ou celular. **Nunca** use `-d chrome` neste
projeto (seção 1.3 do PDF).

Para o teste 8, feche o app (botão de apps recentes → deslizar para cima, ou `q` no terminal) e abra de
novo pelo ícone, ou rode `flutter run` outra vez. **Não desinstale**, porque desinstalar apaga o `produtos.db`.

Dispositivo usado: ______________________

## Tabela

> Depois da A2, a mensagem do teste 4 passou a ser "Informe um preço válido (ex.: 19,90)." e o
> formulário também tem o campo Quantidade (preencher, por exemplo, `1`). Os demais resultados não mudam.

| # | Teste | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| 1 | Cadastro | Novo produto → nome `Caderno`, preço `12,50` → Salvar | O novo produto aparece na lista (`R$ 12,50`) e o SnackBar "Produto cadastrado." | | |
| 2 | Listagem | Novo produto → `Caneta`, `3,00` → Salvar | Os dois itens são apresentados (Caneta em cima, `ORDER BY id DESC`) | | |
| 3 | Validação — nome vazio | Novo produto → deixar o nome vazio (ou só espaços), preço `5` → Salvar | O formulário impede a operação: "Informe o nome." e o diálogo continua aberto | | |
| 4 | Validação — preço texto | Novo produto → nome `Lápis`, preço `abc` → Salvar | O formulário informa preço inválido: "Informe um preço válido (maior ou igual a zero)." | | |
| 5 | Atualização | Lápis (editar) do Caderno → preço `14,90` → Salvar | O valor novo aparece na lista (`R$ 14,90`); o ID do Caderno não muda | | |
| 6 | Exclusão cancelada | Lixeira da Caneta → Cancelar | O produto permanece cadastrado | | |
| 7 | Exclusão confirmada | Lixeira da Caneta → Excluir | Somente a Caneta desaparece; o Caderno continua | | |
| 8 | Persistência | Fechar e reabrir o app no mesmo dispositivo, sem desinstalar | Os dados restantes são recuperados do `produtos.db` (Caderno, R$ 14,90) | | |

## Observação do fim da seção 4 — ID depois de apagar o maior

Procedimento: com Caderno (ID 1) e Caneta (ID 2) cadastrados, excluir a **Caneta** (maior ID) e
cadastrar `Borracha`, `2,00`.

| Pergunta | Esperado pelo código | Observado |
|---|---|---|
| Qual ID a Borracha recebeu? | **3**. Com `AUTOINCREMENT`, o SQLite guarda o maior ID já emitido (tabela interna `sqlite_sequence`) e não o reutiliza, mesmo depois de excluído (seção 3.7, "Por que o ID é diferente?"). | |
