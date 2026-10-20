# CarTable – Estrutura do projeto


`curved_labeled_navigation_bar` e `shared_preferences`.

```
lib/
├── main.dart                      # Ponto de entrada (só chama runApp)
├── app.dart                       # MaterialApp: junta tema + rotas
│
├── core/                          # Configurações globais
│   ├── app_colors.dart            # Paleta de cores
│   ├── app_theme.dart             # Tema escuro e estilo dos campos
│   └── app_routes.dart            # Nomes das rotas e mapa de telas
│
├── widgets/                       # Componentes reutilizáveis
│   ├── app_logo.dart
│   ├── primary_button.dart
│   ├── app_text_field.dart
│   └── app_bottom_navigation.dart
│
└── screens/                       # Uma pasta por tela
    ├── home/   (home_screen, route_painter)
    ├── car/    (car_screen)
    ├── map/    (map_screen, map_painter, vehicle_marker, status_item)
    ├── login/  (login_screen)
    └── about/  (about_screen, feature_item)
```

## Regras para trabalhar em grupo

- Cada pessoa mexe em uma pasta de `screens/` → menos conflito no Git.
- Cores só em `core/app_colors.dart`. Nada de `Color(0x...)` solto nas telas.
- Nomes de rota só em `core/app_routes.dart`.
- Widget usado em mais de uma tela vai para `widgets/`.
- Widget usado em uma tela só fica na pasta dela.
