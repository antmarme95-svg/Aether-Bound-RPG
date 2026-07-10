# Character Head/Bust Review v0.4 — humano base, ronda 4 (turnaround M9-r3)

> **Fuente RAW del director (Boris), 2026-07-10.** Depositado verbatim (sobre
> el turnaround frente/¾/perfil/espalda de M9-r3). No se edita. Checklist
> vivo: [[Task-Board]] §C6.

## Evaluación General

Ronda tres entrega por fin el turnaround solicitado, primera evaluación real
de la construcción craneal en 360°. Cierres de ronda dos verificables: las
dos marcas faciales existen con lateralidad correcta, el top knot fue
eliminado, ojos/cejas on-model. El problema dominante es unívoco: **el
volumen del pelo** — desde atrás y en perfil lee como casco/hongo (casquete
bowl con borde-repisa duro) en vez del quiff barrido. Las vistas nuevas
exponen: ausencia total de orejas en perfil/espalda, cuello notablemente
largo desde atrás, y un plano rectangular flotante sobre la coronilla.
**Veredicto: Needs Revision** — la cara converge; el cráneo posterior y el
pelo no.

## Críticos

1. **Pelo = casco/bowl en espalda y perfil.** Casquete semiesférico uniforme
   con borde duro parejo y "shelf" sobre frente y sienes. El concepto define
   laterales cortos pegados y masa arriba-adelante con barrido atrás. La
   nuca es EL ángulo del jugador en tercera persona; hoy comunica casco o
   corte de hongo. Fix: (1) laterales y nuca = capa delgada que siga el
   cráneo, dejando ver la transición a piel (fade corto); (2) masa principal
   a la coronilla frontal con vector de barrido atrás; (3) eliminar el
   borde-repisa continuo — la línea sube en las sienes, no visera de 360°.

2. **Orejas ausentes en perfil y espalda.** En ¾ trasero (cámara estándar de
   gameplay) la cabeza lee maniquí; la oreja es el anclaje de pelo lateral,
   mandíbula y rig facial. Fix: colocar los primitivos de oreja ANTES de
   iterar más el pelo (el pelo lateral se construye alrededor de ellas).

## Alta prioridad

3. **Cuello off-model confirmado** (~¾ de la altura de cabeza; estándar
   ⅓–½). Tercera ronda abierto → **PROMOVIDO: si no se corrige en la
   próxima ronda pasa a Crítico/Bloqueante.** Fix: −30% de longitud, base
   más ancha con transición al trapecio.

4. **Plano rectangular flotante sobre la coronilla** (frontal y esquina
   beige en trasera). Geometría huérfana o cap mal posicionado; artefactos
   de silueta contra el cielo. Fix: identificar y eliminar/fusionar.

5. **Vestuario ausente por tercera ronda sin documentación en el PR.**
   Dependencia circular nuca-del-pelo ↔ borde-del-cowl sin resolver. Fix:
   decisión REQUERIDA en el PR — o base-body modular por escrito, o bloquear
   el cowl. Sin eso no se cierran cuello ni nuca.

## Media prioridad

6. **Marca de mejilla en "L"/gusano segmentado** en vez de franja diagonal
   recta (posición y lateralidad ya correctas). Fix: franja recta de ancho
   constante, paralela en ángulo a la de la frente.

7. **El borde frontal del pelo invade sien y ojo derecho en perfil/¾**; la
   cara queda hundida bajo el voladizo. Se resuelve con la reconstrucción:
   la línea frontal retrocede por encima de la ceja.

## Baja prioridad

8. **Nariz con valor más oscuro** que la piel circundante (el perfil
   confirma que la forma ya proyecta bien). Igualar valor.
9. **Seams rectangulares en mentón/mandíbula** — confirmar en wireframe
   (pendiente de ronda dos).

## Hallazgos positivos

- Turnaround completo entregado — estándar correcto, mantener.
- Ambas marcas con lateralidad correcta ✓ (cierre del crítico #2 de r2).
- Top knot eliminado ✓ (cierre parcial del crítico #1 de r2).
- Ojos y cejas estables on-model por segunda ronda — no tocar.
- El perfil confirma proyección correcta de nariz y mentón.
- La mandíbula en ¾ muestra el quiebre de plano pedido; adiós ovoide puro.

## Riesgo de producción

- Legibilidad (crítico): la vista trasera es la default del jugador —
  casquete-casco sin orejas = maniquí genérico en el ángulo de mayor
  exposición.
- Rigging: cuello largo tercera ronda; trabajo de cabeza en riesgo.
- Equipamiento: cowl indefinido = riesgo de calendario (dependencias
  circulares).
- Higiene de mesh: plano flotante sugiere geometría sin fusionar; pase de
  limpieza recomendado.

## Puntuación

- Concept Fidelity: **6 / 10** · Production Readiness: **5 / 10** ·
  Technical Execution: **6.5 / 10** · **Overall: 6 / 10.**
- Bloqueantes próximos, en orden: (1) reconstrucción del pelo (laterales
  cortos + barrido), (2) orejas, (3) cuello −30%, (4) decisión documentada
  del cowl, (5) limpieza del plano flotante. Si cierran, la ronda cuatro
  puede aspirar a **Approved with Minor Changes**.
