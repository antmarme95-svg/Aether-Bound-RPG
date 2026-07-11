# Character Head/Bust Review v0.5 — humano base, ronda 5 (turnaround M9-r4)

> **Fuente RAW del director (Boris), 2026-07-10.** Depositado verbatim. No se
> edita. Checklist vivo: [[Task-Board]] §C6.

## Críticos

1. **Losa rectangular plana sobre la coronilla (frontal).** El pelo frontal
   es un prisma de cara plana que corona como tapa/birrete — regresión sobre
   la silueta frontal de ronda 3 ("bowl con tapa de caja"). El fix interpretó
   mal la nota: se pedía eliminar el plano huérfano, no absorberlo. Fix:
   eliminar el prisma; el tope del pelo debe ser el QUIFF — masa
   redondeada-angular con vector adelante-arriba-atrás, sin caras planas
   horizontales; contorno superior = curva ASIMÉTRICA más alta al frente.

2. **Marcas faciales regresionadas** a dos triángulos mínimos (píxeles en
   ¾/perfil). Ronda 3 ya había validado posición y lateralidad; solo se pedía
   rectificar la forma. Fix: restaurar tamaño de ronda 3 (frente ≈ largo de
   ceja; mejilla ≈ pómulo-a-mandíbula), franja diagonal recta de ancho
   constante. No iterar más sin comparar lado a lado con r3 y el concept.

3. **Geometría atravesando el mesh:** cejas visibles desde la espalda a
   través del cráneo; esclerótica visible por detrás del plano facial en
   perfil. Normales/culling/rasgos flotantes. Fix: conformar rasgos a la
   superficie del cráneo, verificar normales y culling, confirmar en órbita
   360° que ningún rasgo frontal se ve desde la nuca.

## Alta prioridad

4. **Oreja mal posicionada** — adelantada sobre la mejilla (lee piercing).
   Fix: retrasar a la vertical MEDIA del cráneo en perfil, banda ceja-nariz,
   semi-elipse vertical; en la trasera deben asomar ambas flanqueando.

5. **Pelo espalda/perfil sin cambio** (casquete con borde-repisa, 2ª ronda).
   Fix: el de ronda 3 — capa delgada en laterales/nuca, hairline que sube,
   masa adelante-arriba. Método sugerido: bloquear PRIMERO en perfil (ahí se
   define el vector del quiff), luego frontal y espalda.

## Media prioridad

6. **Cuña de geometría tras la cabeza** en perfil/¾ (higiene de mesh, con el
   crítico 3 confirma pase de limpieza pendiente).
7. **Hairline alta y recta** (frente ~45% de la cara; concept: ~⅓ superior
   con entradas suaves). Se resuelve con la reconstrucción del quiff.

## Baja prioridad

8. **Seams de mentón/mandíbula** — 3ª ronda sin verificación: confirmar en
   wireframe o marcar como intencional.

## Positivos

- **Cuello corregido — cerrado, no tocar.**
- **Decisión de vestuario documentada — issues de vestuario cerrados como
  deferred; contrato cuello-torso definido por el sistema modular.**
- Hombros/trapecio traseros más sólidos.
- Ojos, cejas y proyección Z de nariz/mentón estables on-model.

## Riesgo de producción

- **Control de regresiones (riesgo principal): dos elementos validados
  retrocedieron al aplicar fixes de otros issues. Cada entrega debe incluir
  diff visual contra la ronda anterior en los cuatro ángulos.**
- Caras atravesadas romperán el outline del cel-shading.
- LODs amplificarán la lectura de casco si se congela la silueta actual.
- Vestuario: mitigado; verificar en Fase 4 nuca-del-pelo vs borde-del-cowl.

## Puntuación

- Concept Fidelity: **5 / 10** (↓) · Production Readiness: **6 / 10** (↑) ·
  Technical Execution: **5 / 10** (↓) · **Overall: 5.5 / 10.**
- Bloqueantes ronda 5: (1) eliminar losa y reconstruir quiff — perfil
  primero, (2) restaurar marcas a estado r3 con forma de franja, (3) pase de
  limpieza de mesh (normales, rasgos atravesados, cuña), (4) reposicionar
  orejas. Cuello y vestuario fuera del tracking. Sin nuevas regresiones →
  **Approved with Minor Changes alcanzable.**
