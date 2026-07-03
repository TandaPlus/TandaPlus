# Arquitectura backend

Arquitectura por capas con separacion estricta de responsabilidades.

## Capas

- `lib/src/domain/` — Entidades puras y contratos (interfaces de repositorios y servicios). Solo Dart puro, sin dependencias externas.
- `lib/src/application/` — Use cases y logica de negocio. Coordina domain sin conocer infraestructura.
- `lib/src/infrastructure/` — Implementaciones concretas: Postgres, FCM, PayPal. Unico lugar con dependencias externas.
- `lib/src/middleware/` — Handlers cross-cutting: JWT, RBAC, rate limit, logging, CORS.
- `lib/src/shared/` — Utilidades compartidas: errores, validators, utils, constants.

## Reglas duras

- `domain/` no importa de `infrastructure/` ni de ningun paquete externo (salvo `package:meta`, `package:equatable`).
- `application/` importa de `domain/`, nunca de `infrastructure/`.
- `infrastructure/` implementa las interfaces de `domain/`. Puede usar cualquier dependencia externa.
- `routes/` solo orquesta: parsea request, llama use case, devuelve response. Nunca contiene logica de negocio.
- `middleware/` se reutiliza entre rutas; sin logica de dominio.

## Patrones documentados en codigo

- **Repository**: `domain/repositories/` interfaces, `infrastructure/repositories/` impl.
- **Strategy**: `application/fines/fine_calculator_strategy.dart` (Sprint 4).
- **Observer**: `application/events/event_bus.dart` (Sprint 4).
- **Singleton**: `infrastructure/database/postgres_pool.dart` (Issue #6).

## Referencia completa

Ver `contexto.md` seccion 8 (Arquitectura backend) para el detalle y el diagrama.
