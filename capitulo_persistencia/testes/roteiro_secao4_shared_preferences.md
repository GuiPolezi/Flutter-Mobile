# Roteiro da seção 4 — `crud_shared_preferences`

> Testes da seção 4 do PDF ("Testes orientados"), feitos no app em execução.
> As colunas **Observado** e **Conferência manual** são preenchidas pelo aluno depois de executar.

## Como executar

```
cd crud_shared_preferences
flutter pub get
flutter run -d chrome
```

**Atenção ao teste 8 (persistência) no Chrome:** o `flutter run -d chrome` abre um perfil
temporário do Chrome a cada execução, e a porta pode mudar. Se você fechar (`q`) e rodar de novo, os
dados podem parecer perdidos, porque o navegador está em **outra origem** (seção 5 do PDF: "Depois de
fechar o app, os registros sumiram"). Para testar a persistência na **mesma origem**:

```
flutter run -d web-server --web-port 8080
```

Abra `http://localhost:8080` no Chrome normal, faça os testes, feche a aba e encerre o `flutter run`
(`q`). Rode o mesmo comando de novo e abra o mesmo endereço. No Android, basta fechar e reabrir o app
sem desinstalar.

Ambiente usado: ______________________ (Chrome/web-server ou Android)

## Tabela

| # | Teste | Procedimento | Resultado esperado | Observado | Conferência manual |
|---|---|---|---|---|---|
| 1 | Cadastro | Novo produto → nome `Caderno`, preço `12,50` → Salvar | O novo produto aparece na lista (`R$ 12,50`) e o SnackBar "Produto cadastrado." | | |
| 2 | Listagem | Novo produto → `Caneta`, `3,00` → Salvar | Os dois itens são apresentados (Caneta em cima, por ID decrescente) | | |
| 3 | Validação — nome vazio | Novo produto → deixar o nome vazio (ou só espaços), preço `5` → Salvar | O formulário impede a operação: "Informe o nome." e o diálogo continua aberto | | |
| 4 | Validação — preço texto | Novo produto → nome `Lápis`, preço `abc` → Salvar | O formulário informa preço inválido: "Informe um preço válido (maior ou igual a zero)." | | |
| 5 | Atualização | Lápis (editar) do Caderno → preço `14,90` → Salvar | O valor novo aparece na lista (`R$ 14,90`); o ID do Caderno não muda | | |
| 6 | Exclusão cancelada | Lixeira da Caneta → Cancelar | O produto permanece cadastrado | | |
| 7 | Exclusão confirmada | Lixeira da Caneta → Excluir | Somente a Caneta desaparece; o Caderno continua | | |
| 8 | Persistência | Fechar e reabrir o app no mesmo ambiente (ver "Atenção" acima) | Os dados restantes são recuperados (Caderno, R$ 14,90) | | |

## Observação do fim da seção 4 — ID depois de apagar o maior

Procedimento: com Caderno (ID 1) e Caneta (ID 2) cadastrados, excluir a **Caneta** (maior ID) e
cadastrar `Borracha`, `2,00`.

| Pergunta | Esperado pelo código | Observado |
|---|---|---|
| Qual ID a Borracha recebeu? | **2**. O `inserir()` calcula `maior ID + 1` com `fold`, e o maior restante é 1. O número 2 é reutilizado (seção 2.5, "Inclusão — Create"). | |
