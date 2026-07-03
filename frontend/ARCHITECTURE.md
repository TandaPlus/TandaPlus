# Arquitectura del frontend

Estructura **layered** alineada con `ceoy_movies_app`. Cada capa vive en su
folder y expone su API publica mediante un archivo barrel.

## Capas

```
frontend/lib/
├── config/           configuracion (constants, helpers, router, theme)
├── domain/           entidades e interfaces puras (sin Flutter, sin dio)
├── infrastructure/   impl de datasource, mappers, DTOs y repositories
└── presentation/     providers, screens, views y widgets
```

## Reglas duras

1. `domain/` **no** importa de `infrastructure/` ni de Flutter.
2. `presentation/` consume `domain/` a traves de providers. Nunca instancia
   implementaciones de `infrastructure/` directamente.
3. `infrastructure/` es el unico lugar donde se usa `dio` y se ven DTOs
   crudos.
4. `presentation/` **jamas** ve un DTO crudo, solo entidades del dominio.
5. Todos los imports internos usan `package:frontend/...`. Prohibido usar
   imports relativos (`../` o `./`).

## Barrels

Cada capa tiene un archivo barrel que reexporta su API publica:

- `config/config.dart`
- `domain/domain.dart`
- `infrastructure/infrastructure.dart`
- `presentation/providers/providers.dart`
- `presentation/screens/screens.dart`
- `presentation/widgets/widgets.dart`

## Providers de Riverpod

| Tipo                    | Cuando usar                              |
| ----------------------- | ---------------------------------------- |
| `Provider`              | Singletons sin estado (configs, repos)   |
| `StateNotifierProvider` | Features con estado mutable y logica     |
| `FutureProvider`        | Datos async puros sin logica adicional   |