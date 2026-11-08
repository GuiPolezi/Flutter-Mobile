# Registro de dúvidas

Modelo: dúvida · resultado esperado · resultado observado · trecho relacionado · como resolvi.
Antes de alterar código, consultei a seção 5 do PDF ("Problemas comuns e como investigá-los").

## Modelo

| Campo | Conteúdo |
|---|---|
| Dúvida | |
| Resultado esperado | |
| Resultado observado | |
| Trecho relacionado | |
| O que tentei / como resolvi | |

---

## 1. `flutter analyze` acusa `unnecessary_underscores` no Código 08

| Campo | Conteúdo |
|---|---|
| Dúvida | Por que o código do professor, copiado sem mudanças, gera aviso no `flutter analyze`? |
| Resultado esperado | `No issues found!` |
| Resultado observado | `info - Unnecessary use of multiple underscores. Try using '_' - lib\screens\produtos_page.dart:137:45 - unnecessary_underscores` |
| Trecho relacionado | `separatorBuilder: (_, __) => const Divider(height: 1),` |
| O que tentei / como resolvi | O `flutter create` atual usa Dart 3.13 e `flutter_lints` 6. A partir do Dart 3.7, `_` é um "curinga" e pode ser repetido em vários parâmetros. Troquei para `(_, _)` e deixei um comentário na linha. O comportamento é o mesmo: os dois parâmetros continuam ignorados. A troca foi feita no Projeto 1 e copiada para o Projeto 2, então os três arquivos continuam iguais. |

## 2. O teste gerado pelo `flutter create` deixou de compilar

| Campo | Conteúdo |
|---|---|
| Dúvida | Por que o `flutter analyze` mostra erro em `test/widget_test.dart`? |
| Resultado esperado | Nenhum erro. |
| Resultado observado | `error - The name 'MyApp' isn't a class` (o teste era do app contador). Ao trocar por um teste que abre o `MeuApp`: `Bad state: The SharedPreferencesAsyncPlatform instance must be set.` |
| Trecho relacionado | `await tester.pumpWidget(const MyApp());` / `final SharedPreferencesAsync _prefs = SharedPreferencesAsync();` |
| O que tentei / como resolvi | No `flutter test` não existe Chrome nem Android, então o `SharedPreferencesAsync` não tem onde gravar. Simular a plataforma exigiria outro pacote, fora da lista do capítulo. Por isso o teste automático confere só o `ProdutoDialog` (validação dos campos vazios), que não usa o repositório. O CRUD é testado pelo roteiro manual da seção 4. |

## 3. Aviso "Building with plugins requires symlink support"

| Campo | Conteúdo |
|---|---|
| Dúvida | O `flutter pub add shared_preferences` terminou com um aviso pedindo o "Developer Mode". Isso impede o projeto de funcionar? |
| Resultado esperado | Pacote adicionado sem avisos. |
| Resultado observado | `Building with plugins requires symlink support. Please enable Developer Mode in your system settings.` O pacote foi adicionado ao `pubspec.yaml` mesmo assim. |
| Trecho relacionado | `flutter pub add shared_preferences` (Código 03) |
| O que tentei / como resolvi | No Windows, o Flutter cria links simbólicos para os plugins, e isso exige o Modo de desenvolvedor (`start ms-settings:developers`). No Chrome o app funcionou normalmente. No Android, o `flutter run -d emulator-5554` do Projeto 2 também compilou e instalou (`Built build\app\outputs\flutter-apk\app-debug.apk`) mesmo com o Modo de desenvolvedor desligado, então não precisei mudar nada. Se em outro computador o build falhar com essa mensagem, a solução é ligar o Modo de desenvolvedor. |

## 4. Persistência no Chrome com `flutter run -d chrome`

| Campo | Conteúdo |
|---|---|
| Dúvida | Os dados somem ao fechar e rodar `flutter run -d chrome` de novo? |
| Resultado esperado | Caderno continua cadastrado (teste 8 da seção 4). |
| Resultado observado | _(preencher depois do teste)_ |
| Trecho relacionado | Seção 5: "Depois de fechar o app, os registros sumiram → confira se executou o mesmo projeto/origem". |
| O que tentei / como resolvi | O `flutter run -d chrome` abre um perfil temporário do Chrome e pode usar outra porta, ou seja, outra origem. Para testar na mesma origem: `flutter run -d web-server --web-port 8080` e abrir `http://localhost:8080` no Chrome normal. |

## 5. Não havia dispositivo Android

| Campo | Conteúdo |
|---|---|
| Dúvida | Como executar o Projeto 2 sem celular? |
| Resultado esperado | `flutter devices` listar um Android (Código 01). |
| Resultado observado | Só `windows`, `chrome` e `edge`; `flutter emulators` → "No emulators available". |
| Trecho relacionado | Seção 5: "O dispositivo Android não aparece → `flutter doctor` e `flutter devices`; confira emulador". |
| O que tentei / como resolvi | Criei um emulador pela linha de comando: `sdkmanager --licenses`, `sdkmanager "system-images;android-36;google_apis;x86_64"`, `avdmanager create avd -n pixel_api36 ...` e `emulator -avd pixel_api36`. Depois disso, `flutter devices` mostrou `emulator-5554`. |

## 6. `flutter run` mostrou erro de conexão, mas o app abriu

| Campo | Conteúdo |
|---|---|
| Dúvida | O app falhou ao rodar no emulador depois de desinstalar e instalar de novo? |
| Resultado esperado | `flutter run` mostrar os comandos (`r Hot reload`...) e o app abrir. |
| Resultado observado | `Error connecting to the service protocol: failed to connect to http://127.0.0.1:.../ ... O computador remoto recusou a conexão de rede`. O app foi instalado e abriu normalmente no emulador. |
| Trecho relacionado | `flutter run -d emulator-5554` (Código 15) |
| O que tentei / como resolvi | O erro é da conexão do terminal com o depurador (hot reload/DevTools), não do app. Rodar `flutter run` de novo resolve. Não é problema do código. |

## 7. Migração do banco: onCreate × onUpgrade

| Campo | Conteúdo |
|---|---|
| Dúvida | Se eu só acrescentar a coluna `quantidade` no `CREATE TABLE`, o app instalado passa a ter a coluna? |
| Resultado esperado (ingênuo) | Sim. |
| Resultado esperado (seção 3.6) | Não: "mudar apenas o SQL de onCreate não atualiza automaticamente os bancos já criados". |
| Trecho relacionado | `openDatabase(version: ..., onCreate: ..., onUpgrade: ...)` |
| O que tentei / como resolvi | Subi a `version` e acrescentei `onUpgrade` com `ALTER TABLE`. Teste no emulador: cadastrei Caderno e Caneta com a versão 1 (Etapa 4), rodei a versão 2 sem desinstalar e os dois apareceram com `Estoque: 0`. Depois rodei a versão 3 (A6) e eles continuaram, com "Sem categoria". Por último, desinstalei para testar o caminho do `onCreate` (instalação nova), que também funcionou. |
