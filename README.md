# Desafio Kode, Rick And Morty - Guia do Projeto

> **Este projeto faz parte de um desafio técnico da empresa *Kobe*.**


Rick and Morty – REST client em Flutter. Este documento explica visão geral, requisitos, como rodar localmente (Android, iOS e Web), padrões do projeto e dicas de troubleshooting.

---

## 📦 Visão geral
- **Nome do pacote**: `rnm_app`
- **Descrição**: Cliente REST da API pública [Rick and Morty](https://rickandmortyapi.com/) com Flutter.
- **Gerenciador**: `flutter`/`pub`
- **Estado de publicação**: não publicável ( `publish_to: none` )
- **Suporte a plataformas**: Android, iOS, Web (e Desktop, se habilitado pelo Flutter SDK)

### Principais dependências
- **Flutter** (SDK)
- **Dart**: `>= 3.7.0 < 4.0.0`
- **dio** `^5.7.0` – HTTP client
- **flutter_riverpod** `^2.5.1` – gerenciamento de estado
- **go_router** `^14.2.0` – navegação declarativa
- **cached_network_image** `^3.4.1` – imagens com cache

### Dev dependencies
- **flutter_test** (SDK) – testes de widget/unit
- **flutter_lints** `^4.0.0` – regras de lint

> **Observação:** Não há chaves/segredos. A API Rick and Morty é pública, sem autenticação.

---

## 🛠️ Requisitos do ambiente

> **SDK Dart**: `>= 3.7.0 < 4.0.0` (já incluso quando você instala o Flutter compatível)

### Versões recomendadas (agosto/2025)
- **Flutter**: 3.22.x ou superior compatível com **Dart 3.7**
- **Android**: Android Studio Giraffe+ com **Android SDK 34** (ou superior) e **Java 17** para toolchain
- **iOS (opcional)**: Xcode 15+; macOS com CocoaPods (`gem install cocoapods`)
- **Web (opcional)**: Chrome atualizado

### Checagens rápidas
```bash
flutter --version
# verifique se o Dart é >= 3.7

flutter doctor -v
# instale/ajuste o que o doctor acusar
```

---

## ▶️ Rodando o projeto localmente

### 1) Clonar e instalar dependências
```bash
git clone <URL_DO_REPO>
navegue até a o diretorio do projeto ../projects/workshop/desafio_rick_and_morty
cd rnm_app
flutter pub get
```

### 2) Executar (Android/iOS/Web)
- **Android (emulador ou dispositivo):**
  ```bash
  flutter devices           # confirme que o dispositivo aparece
  flutter run -d emulator-5554  # exemplo de ID
  ```
- **iOS (apenas macOS):**
  ```bash
  cd ios && pod install && cd -
  flutter run -d <ID_DO_SIMULADOR>
  ```
- **Web (Chrome):**
  ```bash
  flutter run -d chrome
  ```

> **Dica:** use `flutter run -d <deviceId> -v` para logs detalhados.

### 3) Build de produção (opcional)
- **Android (APK release):**
  ```bash
  flutter build apk --release
  ```
- **Web:**
  ```bash
  flutter build web --release
  # saída em build/web
  ```

---

## 🧭 Arquitetura & organização

A app utiliza uma arquitetura enxuta com separação por camadas e features:

- **core/**: utilidades, classes base (ex.: cliente HTTP `dio`, mappers, helpers)
- **features/**: cada domínio (characters, episodes, locations) agrupa:
  - `data/` (models, services, DTOs)
  - `presentation/` (views/widgets)
  - `controllers/` (providers Riverpod/StateNotifiers)
- **routing/**: configuração do `go_router` (rotas nomeadas, guards, etc.)

### Fluxo (alto nível)
1. UI dispara uma ação (ex.: abrir lista de personagens).
2. Controller/Provider aciona **Service** da feature.
3. Service usa **Dio** (via `core/api_client`) para chamar a API REST.
4. Resposta JSON → **Model.fromJson**.
5. Provider expõe estado (loading/data/error) para a UI.

### Convenções
- **Riverpod** para estado (providers escopados por feature).
- **GoRouter** com rotas declarativas.
- **Dio** com `BaseOptions` (timeouts, baseUrl, headers `Accept: application/json`).
- **cached_network_image** para imagens de personagens/locais/episódios.

---

## 🔧 Comandos úteis de desenvolvimento
```bash
# atualizar dependências dentro das restrições do pubspec
flutter pub get
flutter pub upgrade --major-versions   # (use com cuidado)

# formatar e analisar
dart format .
dart analyze


```

---

## 🌐 Endpoints da API (referência rápida)
Base URL: `https://rickandmortyapi.com/api`

- **Characters**
  - `GET /character`
  - `GET /character/{id}` ou `/character/{id1,id2,...}`
- **Episodes**
  - `GET /episode`
  - `GET /episode/{id}` ou `/episode/{id1,id2,...}`
- **Locations**
  - `GET /location`
  - `GET /location/{id}` ou `/location/{id1,id2,...}`

> Os serviços usam paginação da própria API (links `info.next`/`info.prev`).

---

## 🧩 Dependências explicadas
- **dio**: cliente HTTP com interceptors, cancelamento, timeouts. Base para todos os serviços REST.
- **flutter_riverpod**: providers imutáveis, testáveis, sem necessidade de BuildContext para leitura de estado.
- **go_router**: rotas com declaratividade e deep-link, integração com Riverpod se necessário.
- **cached_network_image**: placeholder, cache e retry para imagens remotas.
- **flutter_lints**: conjunto oficial de boas práticas; roda com `dart analyze`.


---

## 🎯 Estilo de código & qualidade
- **Format**: `dart format .`
- **Analyze**: `dart analyze`
- **Lints**: `flutter_lints` (personalize em `analysis_options.yaml` se desejar)

Sugestão de `analysis_options.yaml` mínima:
```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    prefer_final_locals: true
    always_use_package_imports: true
    avoid_print: true
```

---

## 🐛 Troubleshooting
- **Versão do SDK/Dart incompatível**
  - Sintoma: erros de linguagem/compatibilidade.
  - Ação: `flutter --version` (garanta Dart >= 3.7); atualize com `flutter upgrade`.

- **Dispositivo não aparece no `flutter devices`**
  - Android: habilite *USB debugging*, aceite a autorização ADB.
  - iOS: abra o simulator pelo Xcode ou `open -a Simulator`.

- **Erro de CocoaPods (iOS)**
  - Rode `cd ios && pod repo update && pod install && cd -`.

- **Falha ao carregar imagens**
  - Verifique rede e URLs da API; em web, cheque CORS no DevTools.

---

## 📁 Estrutura sugerida (exemplo)
```
lib/
  core/
    api_client.dart
    utils.dart
  features/
    characters/
      data/
      presentation/
      controllers/
    episodes/
      data/
      presentation/
      controllers/
    locations/
      data/
      presentation/
      controllers/
  routing/
    app_router.dart
main.dart
```

---

## 🧭 Roadmap sugerido
- [ ] Tela de busca/filtro avançado
- [ ] Paginação com *infinite scroll*
- [ ] Favoritos offline (Hive/Drift)
- [ ] Dark mode total + theming customizado

---

## 📝 Licença
Projeto de estudo/demonstração. Por Thainara Christina Onofre

---

---

## ✅ Checklist de primeira execução
- [ ] `flutter --version` mostra Dart >= 3.7
- [ ] `flutter doctor -v` sem pendências críticas
- [ ] `flutter pub get` finalizado
- [ ] Dispositivo ativo (`flutter devices`)
- [ ] `flutter run -d <alvo>` ok


***

<h2 align="center">Arquitetura – visão geral</h2>


````mermaid
flowchart TD
    A((Start)) --> B["CharactersPage aberta (/characters)"]
    B --> C["CharactersController.refresh()"]
    C --> D["CharacterService.fetchCharacters(page=1,\nname/status/gender)"]
    D --> E["ApiClient GET /character?page=1&..."]
    E --> F{"200 OK?"}
    F -- Não --> G["ErrorRetry (mostrar erro)"]
    G -->|Retry| C
    F -- Sim --> H["PaginatedResponse(info, results)"]
    H --> I["state = AsyncValue.data(List<Character>)"]
    I --> J["ListView exibe cards"]
    J --> K{"Scroll ~final?"}
    K -- Sim --> L["CharactersController.loadMore()"]
    L --> M["fetchCharacters(page=n+1,\nmesmos filtros)"]
    M --> E
    K -- Não --> N[/"User interage (digita nome,\nchips de status/gender,\npressiona Apply)"/]
    N --> O["applyFilters(CharacterQuery)\n-> refresh() com novos filtros"]
    O --> D
    J --> P{Tap no card?}
    P -- Sim --> Q["GoRouter: /characters/detail/:id"]
    P -- Não --> J
    Q --> R((Stop))
````
