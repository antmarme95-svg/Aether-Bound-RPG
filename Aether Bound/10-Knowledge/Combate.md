---
status: ratificado
source: "GDD §4.2"
updated: 2026-07-04
---

# Combate — spec v1

## A. Arquitectura (genérica, data-driven, agnóstica de motor)

Cuatro componentes en TODO personaje (jugador, compañero, enemigo):
**CombatComponent** (combos, input buffer, ventanas AnimNotify) ·
**GuardComponent** (bloqueo, parry, barra de **Equilibrio**) ·
**EnergyComponent** (Aether) · **PushPullComponent** (impulsos/tracciones
vectoriales). Datos externos: `WeaponData` + `AbilityData`. Resolución por
**HitPayload** (Daño, DañoEquilibrio, VectorFuerza, Interrupción).

## B. Reglas canónicas de acople

1. **Las marcas son datos:** la co-dependencia ([[Acoplamientos]]) es el campo
   `MarkMultiplier` del HitPayload.
2. **Los links SON PushPull:** todos los [[Los 9 Links del Pivote|links]] son
   casos del PushPullComponent sobre aliados — un solo sistema físico para
   combate, links y traversal.
3. **El Equilibrio nace de la masa** (perfil 9-cell): Heavy = torre de
   postura; Light = frágil pero difícil de golpear.
4. **Parry con sabor racial** (+ time-dilation global 0.2 + sting del
   leitmotiv): **Elfo redirige** (el proyectil se vuelve tuyo) · **Enano
   absorbe-planta** (roba DañoEquilibrio) · **Humano roba-desarma** (usa el
   VectorFuerza del rival).
5. **Sprint↔arma es ley:** atacar cancela sprint/slide el mismo tick
   ([[Locomoción]]).
6. **[[Speck]] estadio 2+:** puentes = `AbilityData` inyectados; los links
   degradados post-traición son los mismos assets con parámetros reducidos.

## C. Matriz de verbos 3×3

Cada celda de la [[Matriz Raza x Rol]] tiene verbos dominantes propios (GDD
§4.2C para la tabla completa): del parry-redirect central del Elfo Vanguard a
las cadenas de combo más largas del juego del Humano Duelist. Los movesets
DERIVAN del esqueleto ([[Movilidad Realista]]).

## D. Semillas sensoriales (para la Game Feel Bible)

Parry: time-dilation + sting de dos notas ([[Bond y el Bond Vacío]]). Vivo del
prototipo: FOV-kick, landing stutter, cam-thump.

**Pendiente (❓):** DamageProfiles por celda; diseño de enemigos (mismos 4
componentes); hit-stop por peso; screen-shake budget; cámara lock-on vs.
libre. → Task-Board.
