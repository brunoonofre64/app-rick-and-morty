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
